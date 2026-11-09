# Desqueezer

**Desqueezer** is a Lightroom plugin that batch-applies an anamorphic desqueeze factor to selected DNG files (and, in this fork, Sony ARW files) by modifying DNG metadata using `exiftool`.

**❗Please note: This plugin irreversibly changes the metadata. Please backup your photos before use.**

![Animated logotype](https://raw.githubusercontent.com/adriankulik/Desqueezer/aacdfea07d6af846b4a4357e2cb841df042e3236/assets/Desqueezer_logo.gif)

> **Fork note:** This is a fork of [adriankulik/Desqueezer](https://github.com/adriankulik/Desqueezer) that adds support for Sony `.ARW` files (tested design target: Sony a7II with a 1.6x anamorphic lens). Huge thanks to **Adrian Kulik** for creating the original plugin and releasing it under the MIT license. All the core idea and structure here is his work.
> The ARW support has not been verified end to end in Lightroom yet; please test on copies of your files first.

---

## ⚙️ Prerequisites

Before running the plugin, make sure the following setup steps are completed:

### 1. Install `exiftool`

This plugin uses `exiftool` to set the DNG `DefaultScale` metadata tag, which Lightroom uses to desqueeze.  
Install it via [Homebrew](https://formulae.brew.sh/formula/exiftool):

```bash
brew install exiftool
```

### 2. Make the Bash Script Executable

From the root of the plugin directory, run:

```bash
chmod +x ./scripts/desqueezer.sh
```

### 3. Install Adobe DNG Converter (needed for Sony ARW and other non-DNG raws)

Lightroom only honors the desqueeze tag on DNG files, so ARW files must first be converted to DNG.
This fork does that for you using the free Adobe DNG Converter:

1. Download **Adobe DNG Converter** for macOS from the
   [Adobe download page](https://helpx.adobe.com/camera-raw/using/adobe-dng-converter.html) (free, Adobe account not required).
2. Run the installer. The app must end up at exactly:
   `/Applications/Adobe DNG Converter.app`
   (the plugin calls `/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter`).
3. Open the app once so macOS can approve it, then quit it. You never need to use its window; the plugin runs it in the background.

How ARW handling works:

- For each selected `.arw`, the plugin creates `<same name>.dng` in the **same folder** (e.g. `DSC06241.ARW` → `DSC06241.dng`).
- The desqueeze factor is written to the new DNG, and the DNG is added to your Lightroom catalog automatically.
- Your original ARW is **never modified**.
- If `<name>.dng` already exists, that file is skipped (nothing is overwritten). Delete the old DNG if you want to redo it.
- Selected `.dng` files are still edited in place, as in the original plugin.

### 4. (Optional) Install other required `brew` packages

Run the `brew:install` script located in the `package.json` file. Those scripts are required for keeping the repository neatly formatted and cleanly written.

## 🧩 Installing the Plugin in Lightroom

To install **Desqueezer** in Lightroom Classic:

0. Download the newest release of this Plugin.
1. Locate or create your **Lightroom Plugins folder**. This is usually located in:
   - **macOS:** `~/Library/Application Support/Adobe/Lightroom/Modules/`
   - **Windows:** `C:\Users\<YourName>\AppData\Roaming\Adobe\Lightroom\Modules\`
2. Copy the entire `Desqueezer.lrdevplugin` folder (including all its contents) into that `Modules` directory.
3. Open Lightroom Classic.
4. Go to: `File → Plug-in Manager...`
5. Click **"Add"** (or **"Reload Plug-in"** if updating), then navigate to the `Desqueezer.lrdevplugin` folder.

6. Click **Done** when the plugin is successfully loaded.

You should now see **"Adrian Kulik Anamorphic Utilities → Desqueezer"** as an option under:

- `Library → Plug-in Extras`
- `File → Plug-in Extras`

> 💡 If you make changes to the plugin code, you can simply reload it from the Plug-in Manager.

## 🏃 Running the Plugin

![Plugin Interface showcase](https://raw.githubusercontent.com/adriankulik/Desqueezer/aacdfea07d6af846b4a4357e2cb841df042e3236/assets/Desqueezer_ui.gif)
1. Select the photos you want to desqueeze (Sony `.ARW` and/or `.dng`).
2. Run **"Adrian Kulik Anamorphic Utilities → Desqueezer"** by clicking one of the following options:
   - `Library → Plug-in Extras`.
   - `File → Plug-in Extras`.
3. Choose:
   - Your squeeze factor (e.g. `1.6` for a Sirui Saturn 1.6x).
   - Whether the photo is shot as vertical anamorphic or not.
4. Click `Ok` and wait for the plugin to finish.
5. **ARW files:** the new desqueezed DNGs appear in your catalog automatically (in the same folder as the ARWs). Your ARWs are unchanged.
6. **DNG files edited in place:** in the `Library` tab, select them and use `Metadata → Read Metadata from Files`.
7. Photos in the `Develop` tab are now desqueezed.

### Troubleshooting

- **"Adobe DNG Converter not found"**: check that the app is at `/Applications/Adobe DNG Converter.app`.
- **"exiftool not found"**: run `brew install exiftool`.
- **Nothing happens for an ARW**: a `.dng` with the same name may already exist in that folder; delete it and run again.
- **Image looks the wrong shape**: re-run with the correct squeeze factor and axis on a fresh copy of the DNG.

## 🚧 Next Steps / Roadmap

- [x] **UI for Squeeze Factor**  
       Allow users to input custom squeeze ratios.  
       _(Currently hardcoded to `1.5x`, suitable for lenses like Blazar Remus and Atlas Mercury.)_

- [x] **Orientation Handling**  
       Add support for both horizontal and vertical images.  
       _(Currently assumes vertical anamorphic, resulting in square 1:1 output.)_

- [x] **Add linting to .sh and .lua files**  
       Unify the code formatting.

- [x] **Add a README GIF to ilustrate how this plugin works**  
       Show users how to install and use this plugin in a visual manner.

- [x] **Sony ARW support** (this fork)  
       Convert ARW to DNG with Adobe DNG Converter, then apply the desqueeze factor.

- [ ] **Windows Compatibility**  
       Make the plugin functional on Windows machines using PowerShell or `.bat` alternatives.

## 📄 License

Licensed under the MIT License.
Please retain original author attribution in any distributions or derivatives.

© 2025 Adrian Kulik
