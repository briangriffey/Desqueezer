local LrTasks = import("LrTasks")
local LrDialogs = import("LrDialogs")
local LrLogger = import("LrLogger")
local LrPathUtils = import("LrPathUtils")
local LrFileUtils = import("LrFileUtils")
local LrApplication = import("LrApplication")
local LrFunctionContext = import("LrFunctionContext")
local LrView = import("LrView")
local LrBinding = import("LrBinding")

local myLogger = LrLogger("exportLogger")
myLogger:enable("print")

local function outputToLog(message)
	myLogger:trace(message)
end

local function callDesqueezeBashScript(squeezeFactor, axis)
	LrTasks.startAsyncTask(function()
		local catalog = LrApplication.activeCatalog()
		local selectedPhotos = catalog:getTargetPhotos()

		if #selectedPhotos == 0 then
			LrDialogs.message("No Photos Selected", "Please select one or more ARW or DNG files.", "info")
			return
		end

		local function shellQuote(str)
			return "'" .. str:gsub("'", "'\\''") .. "'"
		end

		-- DNGs are edited in place; ARW files get a new DNG created next to them.
		local quotedPaths = {}
		local newDngPaths = {}
		for _, photo in ipairs(selectedPhotos) do
			local path = photo:getRawMetadata("path")
			local lower = path:lower()
			if lower:match("%.dng$") then
				table.insert(quotedPaths, shellQuote(path))
			elseif lower:match("%.arw$") then
				table.insert(quotedPaths, shellQuote(path))
				table.insert(newDngPaths, (path:gsub("%.[^./\\]+$", ".dng")))
			end
		end

		if #quotedPaths == 0 then
			LrDialogs.message(
				"No supported files",
				"Selected photos do not include any DNG or Sony ARW files.",
				"info"
			)
			return
		end

		local scriptPath = LrPathUtils.child(_PLUGIN.path, "scripts/desqueezer.sh")

		if not LrFileUtils.exists(scriptPath) then
			LrDialogs.message("Error", "The bash script was not found.", "critical")
			outputToLog("Error: Script not found at " .. scriptPath)
			return
		end

		LrDialogs.showBezel("Desqueezing photos… please wait")

		local command = '/bin/bash "'
			.. scriptPath
			.. '" '
			.. squeezeFactor
			.. " "
			.. axis
			.. " "
			.. table.concat(quotedPaths, " ")
		outputToLog("Running command: " .. command)

		local result = LrTasks.execute(command)

		-- Import the DNGs that were created from ARW files.
		local imported = 0
		catalog:withWriteAccessDo("Add desqueezed DNGs", function()
			for _, dngPath in ipairs(newDngPaths) do
				if LrFileUtils.exists(dngPath) and not catalog:findPhotoByPath(dngPath) then
					catalog:addPhoto(dngPath)
					imported = imported + 1
				end
			end
		end)

		if result == 0 then
			local msg = "Desqueeze complete."
			if imported > 0 then
				msg = msg .. "\n\n" .. imported .. " new DNG file(s) were created next to your ARW files and added to the catalog."
			end
			if #quotedPaths > #newDngPaths then
				msg = msg .. "\n\nFor existing DNGs, select them and use Metadata → Read Metadata from Files."
			end
			LrDialogs.message("Desqueeze Complete", msg, "info")
		else
			LrDialogs.message("Error", "Script execution failed.")
			outputToLog("Script failed with exit code: " .. tostring(result))
		end
	end)
end

local function showCustomDialogWithTransform()
	LrFunctionContext.callWithContext("RadioAndToggle", function(context)
		local f = LrView.osFactory()
		local props = LrBinding.makePropertyTable(context)

		props.selectedRatio = "1.5"
		props.verticalMode = false

		local ratioRow = f:row({
			spacing = f:control_spacing(),
			f:radio_button({
				title = "1.33",
				value = LrView.bind("selectedRatio"),
				checked_value = "1.33",
				group = "ratio",
			}),
			f:radio_button({
				title = "1.5",
				value = LrView.bind("selectedRatio"),
				checked_value = "1.5",
				group = "ratio",
			}),
			f:radio_button({
				title = "1.6",
				value = LrView.bind("selectedRatio"),
				checked_value = "1.6",
				group = "ratio",
			}),
			f:radio_button({
				title = "1.8",
				value = LrView.bind("selectedRatio"),
				checked_value = "1.8",
				group = "ratio",
			}),
			f:radio_button({
				title = "2.0",
				value = LrView.bind("selectedRatio"),
				checked_value = "2.0",
				group = "ratio",
			}),
		})

		local axisToggle = f:checkbox({
			title = "Vertical Anamorphic",
			value = LrView.bind("verticalMode"),
		})

		local axisNote = f:static_text({
			title = "If checked, the photo will get desqueezed along the shorter edge.",
			font = "<system/small>",
			alignment = "left",
		})

		local result = LrDialogs.presentModalDialog({
			title = "Select lens squeeze factor & axis",
			contents = f:column({
				bindToObject = props,
				spacing = f:control_spacing(),

				f:static_text({ title = "Choose squeeze ratio:" }),
				ratioRow,
				f:spacer({ height = 10 }),
				f:static_text({ title = "Choose desqueeze axis:" }),
				axisToggle,
				axisNote,
			}),
		})

		if result == "ok" then
			local axis = props.verticalMode and "Vertical" or "Horizontal"
			callDesqueezeBashScript(props.selectedRatio, props.verticalMode and "Vertical" or "Horizontal")
		end
	end)
end

showCustomDialogWithTransform()
