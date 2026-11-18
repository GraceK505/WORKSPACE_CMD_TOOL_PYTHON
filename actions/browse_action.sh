#!/bin/bash

echo "======================="
echo "=Browse folder in disk="
echo "======================="

# 1. Configurable exclusion list (space-separated folder names to ignore)
# Edit this variable whenever you want to search inside AppData or other folders!
EXCLUDE_DIRS=".*"  # To include AppData, just leave '.*' or remove AppData from exclusions

FILTER="$1"
BASE_DIR="$HOME"

# 2. Allow passing an absolute path directly (e.g., ws browse_action /c/Users)
if [ -d "$FILTER" ]; then
    BASE_DIR="$FILTER"
    FILTER=""
fi

# 3. Build the find prune clause dynamically from EXCLUDE_DIRS
PRUNE_EXPR=()
for exc in $EXCLUDE_DIRS; do
    if [ ${#PRUNE_EXPR[@]} -gt 0 ]; then
        PRUNE_EXPR+=("-o")
    fi
    PRUNE_EXPR+=("-name" "$exc")
done

# 4. Search directories dynamically
mapfile -t DIRS < <(find "$BASE_DIR" -maxdepth 3 \( "${PRUNE_EXPR[@]}" \) -prune -o -type d -print 2>/dev/null)

if [ ${#DIRS[@]} -eq 0 ]; then
    echo "No directories found in '$BASE_DIR'"
    exit 1
fi

# 5. Filter search results if an argument was passed
if [ -n "$FILTER" ]; then
    MATCHING_DIRS=()
    for dir in "${DIRS[@]}"; do
        if [[ "${dir,,}" == *"${FILTER,,}"* ]]; then
            MATCHING_DIRS+=("$dir")
        fi
    done
    DIRS=("${MATCHING_DIRS[@]}")
fi

if [ ${#DIRS[@]} -eq 0 ]; then
    echo "No directories matching '$FILTER' found."
    exit 1
fi

# 6. Auto-open if only one match is found
if [ ${#DIRS[@]} -eq 1 ]; then
    TARGET_DIR="${DIRS[0]}"
    WIN_PATH=$(cygpath -w "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")
    echo "Opening: $WIN_PATH"
    explorer.exe "$WIN_PATH" 2>/dev/null
    exit 0
fi

# 7. Interactive selection menu for multiple matches
echo "Select a directory to open in File Explorer:"
select TARGET_DIR in "${DIRS[@]}"; do
    if [ -n "$TARGET_DIR" ]; then
        WIN_PATH=$(cygpath -w "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")
        echo "Opening: $WIN_PATH"
        explorer.exe "$WIN_PATH" 2>/dev/null
        break
    else
        echo "Invalid selection."
    fi
done

exit 0
