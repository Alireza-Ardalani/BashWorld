#!/usr/bin/env bash

# Usage:
#   ./bytecode_size.sh /path/to/apk_dir apk_list.txt
#
# apk_list.txt should contain one APK name per line.
# Lines may be either "foo.apk" or "foo" (".apk" will be added automatically).

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <apk_directory> <apk_list_file>" >&2
    exit 1
fi

apkDir="$1"
apkList="$2"

if [ ! -d "$apkDir" ]; then
    echo "Error: APK directory not found: $apkDir" >&2
    exit 1
fi

if [ ! -f "$apkList" ]; then
    echo "Error: APK list file not found: $apkList" >&2
    exit 1
fi

resultFile="bytecode_sizes.txt"
: > "$resultFile"   # truncate/create result file

while IFS= read -r line || [ -n "$line" ]; do
    # Trim spaces and possible Windows \r
    apkName=$(echo "$line" | tr -d '\r' | xargs)

    # Skip empty lines and comments
    if [ -z "$apkName" ]; then
        continue
    fi
    case "$apkName" in
        \#*) continue ;;  # skip lines starting with '#'
    esac

    # Add .apk if missing
    if [[ "$apkName" != *.apk ]]; then
        apkName="$apkName.apk"
    fi

    apkPath="$apkDir/$apkName"

    if [ ! -f "$apkPath" ]; then
        echo "Warning: APK not found for '$apkName' in '$apkDir', skipping." >&2
        continue
    fi

    # Temporary extraction directory
    tempDir=$(mktemp -d)

    unzip -o -q "$apkPath" -d "$tempDir"

    # Sum size of all classes*.dex files in bytes (Linux: stat -c %s)
    dexBytes=$(find "$tempDir" -maxdepth 1 -name 'classes*.dex' -printf '%s\n' 2>/dev/null | \
               awk '{sum += $1} END {print sum}')

    if [ -z "$dexBytes" ]; then
        dexSize="0 MB"
    else
        dexSize=$(awk -v b="$dexBytes" 'BEGIN {printf "%.2f MB", b/1024/1024}')
        dexSize="$dexSize MB"
    fi

    echo "$apkName, $dexSize" >> "$resultFile"

    # Remove only the extracted files, keep APKs intact
    rm -rf "$tempDir"

    echo "Processed: $apkName -> $dexSize"
done < "$apkList"

echo "All APKs processed. Results saved in $resultFile"