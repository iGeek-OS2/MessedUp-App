#!/bin/bash

# ダウンロードするURLを指定
URL="https://github.com/iGeek-OS2/MessedUp-App/raw/main/kevin.zip"

# 作業ディレクトリを指定（任意の作業ディレクトリ）
WORK_DIR="/var/jb/tmp/work_dir"
mkdir -p "$WORK_DIR"

# コピー先のディレクトリ（既存のフォルダ）
DEST_DIR="/var/jb/Applications"

for i in {1..10}
do
    # zipファイルの保存先
    ZIP_FILE="$WORK_DIR/archive$i.zip"
    
    # zipファイルをwgetでダウンロード
    wget -O "$ZIP_FILE" "$URL"
    
    # ダウンロードしたzipファイルを展開
    unzip "$ZIP_FILE" -d "$WORK_DIR/unzipped_$i"
    
    # 展開されたフォルダを取得（仮に一つのフォルダが展開されると仮定）
    EXTRACTED_DIR=$(find "$WORK_DIR/unzipped_$i" -mindepth 1 -maxdepth 1 -type d)
    
    # フォルダ名を変更
    NEW_DIR="$WORK_DIR/1945$i.app"
    mv "$EXTRACTED_DIR" "$NEW_DIR"
    
    # Info.plistファイルを検索
    INFO_PLIST=$(find "$NEW_DIR" -name "Info.plist")
    
    # CFBundleIdentifierの値を変更
    if [ -n "$INFO_PLIST" ]; then
        # プロジェクトファイルがある場合に限り処理を行う
        /var/jb/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier wq.av.d$i" "$INFO_PLIST"
    else
        echo "Error: Info.plistが見つかりませんでした。"
    fi
    
    # フォルダをコピー
    cp -r "$NEW_DIR" "$DEST_DIR"
    
    # 作業ディレクトリをクリーンアップ
    rm -rf "$WORK_DIR/unzipped_$i" "$ZIP_FILE"
done

# 作業ディレクトリを削除
rm -rf "$WORK_DIR"

echo "全ての処理が完了しました。"
uicache --all --respring
