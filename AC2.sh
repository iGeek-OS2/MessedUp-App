#!/bin/bash
apt install unzip plistbuddy wget

# ダウンロードするURLを指定
URL="https://github.com/iGeek-OS2/MessedUp-App/raw/main/mes.zip"

# 作業ディレクトリを指定（任意の作業ディレクトリ）
WORK_DIR="/var/mobile/work_dir"
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
    
    # 一つのappフォルダを検索
    APP_DIR=$(find "$EXTRACTED_DIR" -maxdepth 1 -name "*.app" -type d | head -n 1)
    
    if [ -n "$APP_DIR" ]; then
        # Info.plistファイルを検索
        INFO_PLIST="$APP_DIR/Info.plist"
        
        # CFBundleIdentifierの値を変更
        if [ -f "$INFO_PLIST" ]; then
            /var/jb/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier wq.av.d$i" "$INFO_PLIST"
        else
            echo "Error: $INFO_PLISTが見つかりませんでした。"
            continue
        fi
    else
        echo "Error: .appフォルダが見つかりませんでした。"
        continue
    fi
    
    # フォルダ名を変更
    NEW_DIR="$WORK_DIR/1945$i.app"
    mv "$EXTRACTED_DIR" "$NEW_DIR"
    
    # フォルダをコピー
    cp -r "$NEW_DIR" "$DEST_DIR"
    
    # 作業ディレクトリをクリーンアップ
    rm -rf "$WORK_DIR/unzipped_$i" "$ZIP_FILE"
done

# 作業ディレクトリを削除
rm -rf "$WORK_DIR"

echo "全ての処理が完了しました。"

uicache --all --respring
