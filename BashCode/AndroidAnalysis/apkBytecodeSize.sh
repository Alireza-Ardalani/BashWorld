# Bytecode size extraction from apk file ( size of dex files). 
# Put apk files in inputFolder, and set outputFolder where the final result will be saved.

inputFolder="--"
outputFolder="--"

mkdir -p "$outputFolder"
resultFile="$outputFolder/result.txt"
echo "" > "$resultFile"

for apkFile in "$inputFolder"/*.apk; do
    if [ ! -f "$apkFile" ]; then
        continue  # Skip if no APK files found
    fi
    apkName=$(basename "$apkFile")
    tempFolder="$outputFolder/temp"
    mkdir -p "$tempFolder"
    unzip -o -q "$apkFile" -d "$tempFolder"
    dexSize=$(stat -f "%z" "$tempFolder"/classes*.dex 2>/dev/null | awk '{sum += $1} END {print sum/1024/1024 " MB"}')
    if [ -z "$dexSize" ]; then
        dexSize="0 MB"
    fi
    echo "$apkName, $dexSize" >> "$resultFile"
    rm -rf "$tempFolder"

    echo "Processed: $apkName -> $dexSize"
done

echo "All APKs processed. Results saved in $resultFile"
