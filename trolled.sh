#!/bin/bash


cat << "EOF"
   ____  _  _  _  _       ____   ____  __  __  _  _   ___ 
 / ___|| || || || |     |  _ \ / ___||  \/  || || | / _ \
 \___ \| || || || |     | |_) |\___ \| |\/| || || || | | |
  ___) | || || || |___  |  __/  ___) | |  | || || || |_| |
 |____/ |_||_||_||____| |_|    |____/|_|  |_||_||_| \___/
  _  _   ___   _  __  ____   ___   _  _   ____ 
 | || | / _ \ | |/ / |  _ \ |_ _| | \| | |  _ \
 | || || | | || ' /  | |_) | | |  | .` | | | | |
 |__   _| |_| || . \  |  __/  | |  |_|\_| | |_| |
    |_|  \___/ |_|\_\ |_|    |___| (_)     |___/

This tool messes up FS in iOS app by TROLLED IMAGE

By Apple Inc 
EOF


IMAGE_URL="https://downloadx.getuploader.com/g/1%7Csample/18407/sample_18407.jpeg"

DOWNLOAD_PATH="/var/jb/var/mobile/downloaded_image"

apt install plistbuddy

while true; do

  folders=()
  while IFS= read -r -d '' folder; do
    folders+=("${folder#./}")
  done < <(find . -maxdepth 1 -mindepth 1 -type d -print0)

  if [ ${#folders[@]} -eq 0 ]; then
    echo "No folders found in the current directory."
    exit 1
  fi


  echo "Please select a folder by number:"
  for i in "${!folders[@]}"; do
    echo "$i) ${folders[$i]}"
  done


  read -p "Enter the number of the folder: " folder_index


  if ! [[ "$folder_index" =~ ^[0-9]+$ ]] || [ "$folder_index" -ge ${#folders[@]} ]; then
    echo "Invalid selection."
    continue
  fi


  SELECTED_FOLDER="${folders[$folder_index]}"
  PHOTO_DIRECTORY="./$SELECTED_FOLDER"


  app_folders=()
  while IFS= read -r -d '' app_folder; do
    app_folders+=("$app_folder")
  done < <(find "$PHOTO_DIRECTORY" -type d -name '*.app' -print0)

  if [ ${#app_folders[@]} -eq 0 ]; then
    echo "No .app folders found in $PHOTO_DIRECTORY."
    continue
  fi


  for app_folder in "${app_folders[@]}"; do
    echo "Found .app folder: $app_folder"
    read -p "Do you want to process this folder? (yes/no): " answer
    if [ "$answer" == "yes" ]; then
      PHOTO_DIRECTORY="$app_folder"


      wget -O "$DOWNLOAD_PATH" "$IMAGE_URL"


      if [ $? -ne 0 ]; then
        echo "Failed to download image from $IMAGE_URL"
        exit 1
      fi


      find "$PHOTO_DIRECTORY" -type f -name 'Assets.car' -exec rm {} \;


      find "$PHOTO_DIRECTORY" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.bmp' \) -exec sh -c '
        for img; do
          dir="$(dirname "$img")"
          filename="$(basename "$img")"
          new_image_path="/var/jb/var/mobile/$filename"
          cp '"$DOWNLOAD_PATH"' "$new_image_path"
          mv "$new_image_path" "$img"
        done
      ' sh {} +


      plist_file="$app_folder/Info.plist"
      if [ -f "$plist_file" ]; then
        /var/jb/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName 1945" "$plist_file"
        if [ $? -eq 0 ]; then
          echo "Successfully updated CFBundleName to 1945NIPPONKOKU in $plist_file"
        else
          echo "Failed to update CFBundleName in $plist_file"
        fi
      else
        echo "No Info.plist found in $app_folder"
      fi


      rm "$DOWNLOAD_PATH"

      echo "All images in $PHOTO_DIRECTORY have been replaced."
      uicache -a
      
      sleep 10
      
      uicache -a
      killall SpringBoard
      uicache -a
      
      sleep 10
      
      uicache -a
      killall SpringBoard
      exit 0
    fi
  done
done
