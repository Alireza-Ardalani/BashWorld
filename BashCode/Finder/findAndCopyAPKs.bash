#!/bin/bash

# === CONFIG VARIABLES ===
NAMES_FILE="Names.txt"
SOURCE_DIR="FileForTest"
DEST_DIR="110APKS"
MISSING_FILE="missing.txt"

# === CHECK: Create destination directory if it doesn't exist ===
if [ ! -d "$DEST_DIR" ]; then
    echo "Creating destination directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
fi

# === CHECK: Create (or clear) missing.txt file ===
if [ ! -f "$MISSING_FILE" ]; then
    echo "Creating missing file log: $MISSING_FILE"
    touch "$MISSING_FILE"
else
    echo "Clearing existing missing file log: $MISSING_FILE"
    > "$MISSING_FILE"
fi

# === MAIN COPY LOOP ===
while read -r apk; do
    if [ -f "$SOURCE_DIR/$apk" ]; then
        cp "$SOURCE_DIR/$apk" "$DEST_DIR/"
    else
        echo "$apk" >> "$MISSING_FILE"
    fi
done < "$NAMES_FILE"

echo "Done. Check '$MISSING_FILE' for any missing APKs."
