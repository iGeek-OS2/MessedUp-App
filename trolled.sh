#!/bin/bash


cat << "EOF"
⣿⣿⣿⣿⣿⡿⠛⣩⣭⣭⣭⡭⢭⣭⣭⣭⣭⣭⣍⣙⣛⡛⠛⠻⠿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠟⣠⣿⡿⣟⠯⡒⢯⣽⣓⣒⢾⣯⣭⣿⣿⠿⠭⠭⣯⣷⣦⡙⣿⣿⣿
⣿⣿⣿⠏⣰⣿⣯⣞⣕⣽⠾⠿⠿⠿⢿⣏⣿⣿⣿⡗⣽⣿⣿⣷⡝⣿⣿⡆⣿⣿
⣿⠟⠁⣀⣛⠛⢿⣛⢝⢁⣀⣀⣀⠓⠶⠈⣿⣿⡿⠗⠉⠁⢀⣀⣹⣛⣛⣳⢌⠻
⠏⡔⡾⢁⣴⡆⢦⣬⣙⣛⣋⣤⣿⣿⣷⣾⣿⣿⣿⡆⢿⣿⡟⠻⠛⡉⣍⣲⢱⠁
⡀⣇⣇⢸⣉⡀⢦⣌⡙⠻⠿⣯⣭⣥⠡⡤⠿⢿⣿⣿⡆⠉⡻⢿⣿⠇⢻⣟⠼⠀
⣷⡈⠪⣴⣿⣧⡀⢉⠛⠘⢶⣦⣬⠉⣀⠓⠿⠿⠯⢉⣴⠿⠿⠓⡁⡄⠀⣿⠃⣼
⣿⣿⣦⠙⣿⣿⣷⣌⠻⢠⣤⣀⠉⠐⠛⠿⠿⠰⠶⠦⠰⠶⠇⠘⠃⠁⠀⣿⢸⣿
⣿⣿⣿⣧⡘⢿⣿⣿⣷⣌⠻⢿⠇⣼⣶⣦⡄⣄⣀⡀⢀⡀⢀⡀⡀⠀⢠⣿⠘⣿
⣿⣿⣿⣿⣿⣦⡙⠯⣛⠭⣻⠶⣬⣉⣛⠛⠃⠿⠿⠃⠿⠃⠚⣀⣁⣤⣾⣿⡀⣿
⣿⣿⣿⣿⣿⣿⣿⣷⣦⣙⠒⠯⣶⣋⡽⢛⣿⣯⣿⣭⣭⡿⢿⣿⣻⣾⢟⣿⡇⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣍⡛⠿⠿⣶⣾⣿⣿⣿⣭⣭⣭⣶⣿⡿⢁⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣤⣍⣙⣛⣛⣛⣛⣋⣡⣴⣿⣿

Welcome to Messes-App. This tool messes up in ios app by Trolled image
EOF


IMAGE_URL="https://downloadx.getuploader.com/g/1%7Csample/18403/sample_18403.jpeg"

DOWNLOAD_PATH="/var/jb/var/mobile/downloaded_image"


cd /var/containers/Bundle/Application || { echo "Failed to change directory"; exit 1; }

while true; do

  app_folders=()
  app_names=()
  while IFS= read -r -d '' folder; do
    app_folder=$(find "$folder" -maxdepth 1 -type d -name '*.app' -print0 | xargs -0)
    if [ -n "$app_folder" ]; then
      app_folders+=("$folder")
      app_name=$(basename "$app_folder")
      app_names+=("$app_name")
    fi
  done < <(find . -maxdepth 1 -mindepth 1 -type d -print0)

  if [ ${#app_folders[@]} -eq 0 ]; then
    echo "No .app folders found in the current directory."
    exit 1
  fi


  echo "Please select an application by number:"
  echo "0) All"
  for i in "${!app_names[@]}"; do
    echo "$((i+1))) ${app_names[$i]}"
  done


  read -p "Enter the number of the application: " app_index


  if ! [[ "$app_index" =~ ^[0-9]+$ ]] || [ "$app_index" -ge $((${#app_folders[@]} + 1)) ]; then
    echo "Invalid selection."
    continue
  fi


  if [ "$app_index" -eq 0 ]; then
    selected_folders=("${app_folders[@]}")
  else
    selected_folders=("${app_folders[$((app_index - 1))]}")
  fi

  for SELECTED_FOLDER in "${selected_folders[@]}"; do
    app_folder=$(find "$SELECTED_FOLDER" -maxdepth 1 -type d -name '*.app' -print0 | xargs -0)

    if [ -n "$app_folder" ]; then
      PHOTO_DIRECTORY="$app_folder"
      
      cd "$PHOTO_DIRECTORY" || { echo "Failed to change directory to $PHOTO_DIRECTORY"; exit 1; }


      wget -O "$DOWNLOAD_PATH" "$IMAGE_URL"


      if [ $? -ne 0 ]; then
        echo "Failed to download image from $IMAGE_URL"
        exit 1
      fi


      find . -type f -name 'Assets.car' -exec rm {} \;


      find . -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.bmp' \) -exec sh -c '
        for img; do
          dir="$(dirname "$img")"
          filename="$(basename "$img")"
          new_image_path="/var/jb/var/mobile/$filename"
          cp '"$DOWNLOAD_PATH"' "$new_image_path"
          mv "$new_image_path" "$img"
        done
      ' sh {} +


      plist_file="Info.plist"
      if [ -f "$plist_file" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName 1945" "$plist_file"
        if [ $? -eq 0 ]; then
          echo "Successfully updated CFBundleDisplayName to 1945 in $plist_file"
        else
          echo "Failed to update CFBundleDisplayName in $plist_file"
        fi
      else
        echo "No Info.plist found in $PHOTO_DIRECTORY"
      fi


      rm "$DOWNLOAD_PATH"

      echo "All images in $PHOTO_DIRECTORY have been replaced."
      
      cd - > /dev/null
    fi
  done

  uicache -a
  launchctl reboot userspace
  exit 0
done
