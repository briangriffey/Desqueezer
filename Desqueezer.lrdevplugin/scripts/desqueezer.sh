#!/bin/bash

# desqueezer.sh
# Applies an anamorphic desqueeze factor using exiftool (DNG DefaultScale tag).
#  - DNG files are modified in place (metadata only).
#  - Raw files that are not DNG (e.g. Sony .ARW) are first converted to a new
#    .dng next to the original using Adobe DNG Converter; the original is left
#    untouched and only the new .dng gets the DefaultScale tag.

echo "Starting anamorphic desqueeze..."

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DNG_CONVERTER="/Applications/Adobe DNG Converter.app/Contents/MacOS/Adobe DNG Converter"

if ! command -v exiftool &>/dev/null; then
    echo "Error: exiftool not found."
    exit 1
fi

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <squeezeFactor> <axis: Horizontal|Vertical> <raw/dng files...>"
    exit 1
fi

squeezeFactor="$1"
axis="$2"
shift 2

if [ "$axis" = "Horizontal" ]; then
    scale="$squeezeFactor 1"
elif [ "$axis" = "Vertical" ]; then
    scale="1 $squeezeFactor"
else
    echo "Error: axis must be 'Horizontal' or 'Vertical'."
    exit 1
fi

failures=0

for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Skipping (not found): $file"
        continue
    fi

    lower="$(printf '%s' "$file" | tr '[:upper:]' '[:lower:]')"
    target="$file"

    if [[ "$lower" != *.dng ]]; then
        if [ ! -x "$DNG_CONVERTER" ]; then
            echo "Error: Adobe DNG Converter not found at: $DNG_CONVERTER"
            failures=$((failures + 1))
            continue
        fi
        dir="$(dirname "$file")"
        base="$(basename "$file")"
        target="$dir/${base%.*}.dng"
        if [ -e "$target" ]; then
            echo "Skipping (DNG already exists, delete it to redo): $target"
            failures=$((failures + 1))
            continue
        fi
        echo "Converting to DNG: $file"
        # -c lossless compression, -p1 medium preview, -d output dir
        if ! "$DNG_CONVERTER" -c -p1 -d "$dir" "$file" || [ ! -f "$target" ]; then
            echo "Failed to convert: $file"
            failures=$((failures + 1))
            continue
        fi
    fi

    echo "Desqueezing: $target with factor $squeezeFactor on axis $axis"
    if exiftool -DefaultScale="$scale" -overwrite_original "$target"; then
        echo "Success: $target"
    else
        echo "Failed to desqueeze: $target"
        failures=$((failures + 1))
    fi
done

echo "Done."
[ "$failures" -eq 0 ] && exit 0 || exit 1
