#!/bin/bash

echo "=================================="
echo "=====   UPDATE ACTION NAME  ======"
echo "=================================="

# 1. Check for required arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <old-action-name> <new-action-name>"
    exit 1
fi

OLD_INPUT="$1"
NEW_INPUT="$2"

# 2. Define workspace path
ACTIONS_SPACE="$HOME/TEST_workSpace/actions"

if [ ! -d "$ACTIONS_SPACE" ]; then
    echo "Error: Directory $ACTIONS_SPACE does not exist."
    exit 1
fi

# Function to find existing file path (handling typed or omitted extensions)
resolve_existing_file() {
    local input_name="$1"
    
    # If file exists exactly as typed
    if [ -f "$ACTIONS_SPACE/$input_name" ]; then
        echo "$ACTIONS_SPACE/$input_name"
        return 0
    fi
    
    # Check for .sh extension
    if [ -f "$ACTIONS_SPACE/${input_name}.sh" ]; then
        echo "$ACTIONS_SPACE/${input_name}.sh"
        return 0
    fi
    
    # Check for .py extension
    if [ -f "$ACTIONS_SPACE/${input_name}.py" ]; then
        echo "$ACTIONS_SPACE/${input_name}.py"
        return 0
    fi

    return 1
}

# 3. Resolve old file path
OLD_FILE=$(resolve_existing_file "$OLD_INPUT")

if [ $? -ne 0 ] || [ -z "$OLD_FILE" ]; then
    echo "Error: Source action '$OLD_INPUT' (or .sh / .py variant) was not found in $ACTIONS_SPACE"
    exit 1
fi

# Extract file extension from old file (.sh or .py)
EXT="${OLD_FILE##*.}"

# 4. Construct new file target path
# Keep existing extension if new name doesn't specify one
if [[ "$NEW_INPUT" == *.* ]]; then
    NEW_FILE="$ACTIONS_SPACE/$NEW_INPUT"
else
    NEW_FILE="$ACTIONS_SPACE/${NEW_INPUT}.${EXT}"
fi

# 5. Check if target filename already exists
if [ -e "$NEW_FILE" ]; then
    echo "Error: Target action '$NEW_FILE' already exists."
    exit 1
fi

# 6. Rename file
mv "$OLD_FILE" "$NEW_FILE"

echo "Success: Renamed action:"
echo "  From: $OLD_FILE"
echo "  To:   $NEW_FILE"