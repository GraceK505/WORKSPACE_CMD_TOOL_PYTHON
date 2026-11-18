#!/bin/bash

echo "=================================="
echo "===== INSTALL DEPENDENCY URL ====="
echo "=================================="

# 1. Require a URL parameter
URL="$1"
if [ -z "$URL" ]; then
    echo "Usage: ws install_dep <https-url> [install-dir]"
    echo "Example: ws install_dep https://example.com/tool.sh"
    exit 1
fi

# 2. Enforce HTTPS for security
if [[ "$URL" != https://* ]]; then
    echo "Error: Only secure 'https://' protocols are allowed."
    exit 1
fi

# 3. Destination folder (defaults to ~/bin or second argument)
TARGET_DIR="${2:-$HOME/bin}"
mkdir -p "$TARGET_DIR"

# 4. Extract filename from URL
FILE_NAME=$(basename "$URL" | cut -d'?' -f1)
TEMP_FILE="/tmp/$FILE_NAME"

echo "Downloading $URL ..."
if ! curl -sSL "$URL" -o "$TEMP_FILE"; then
    echo "Error: Failed to download file from $URL"
    exit 1
fi

echo "Installing to $TARGET_DIR ..."

# 5. Handle installation based on file extension
case "$FILE_NAME" in
    *.sh)
        # Bash script: set execute permissions and copy to target
        chmod +x "$TEMP_FILE"
        mv "$TEMP_FILE" "$TARGET_DIR/$FILE_NAME"
        echo "Script installed to: $TARGET_DIR/$FILE_NAME"
        ;;
    *.tar.gz|*.tgz)
        # Compressed Tarball: extract into target directory
        tar -xzf "$TEMP_FILE" -C "$TARGET_DIR"
        rm -f "$TEMP_FILE"
        echo "Extracted tarball contents to: $TARGET_DIR"
        ;;
    *.zip)
        # Zip Archive: unzip into target directory
        unzip -q "$TEMP_FILE" -d "$TARGET_DIR"
        rm -f "$TEMP_FILE"
        echo "Extracted zip contents to: $TARGET_DIR"
        ;;
    *)
        # Executable Binary / General File
        chmod +x "$TEMP_FILE"
        mv "$TEMP_FILE" "$TARGET_DIR/$FILE_NAME"
        echo "Binary installed to: $TARGET_DIR/$FILE_NAME"
        ;;
esac

echo "Done!"
exit 0
