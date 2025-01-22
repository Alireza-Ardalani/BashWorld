# Find all files in 'Origin' that are listed in 'Names.txt' and copy them to 'Destination'.

#/path/to/start/directory

Names="Data.txt"
Origin="FileForTest"
Destination="FileForTest1"


if [ ! -f "$Names" ]; then
  echo "Error: $Names does not exist."
  exit 1
fi

if [ ! -d "$Origin" ]; then
  echo "Error: Start directory $Origin does not exist."
  exit 1
fi

if [ ! -d "$Destination" ]; then
  echo "End directory $Destination does not exist. Creating it..."
  mkdir -p "$Destination"
fi

while IFS= read -r file_name; do
  # Trim whitespace from file name
  file_name=$(echo "$file_name" | xargs)

  # Full path of the source file
  src_file="$Origin/$file_name"

  if [ -f "$src_file" ]; then
    echo "Copying $file_name to $Destination..."
    cp "$src_file" "$Destination"
  else
    echo "Warning: File $file_name does not exist in $Origin."
  fi
done < "$Names"

echo "File copying completed."
