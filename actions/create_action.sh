#!/bin/bash

echo "=================================="
echo "=====    CREATE NEW ACTION  ======"
echo "=================================="

# 1. Check for argument first
if [ -z "$1" ]; then
    echo "Usage: $0 <action-name> [py|sh]"
    exit 1
fi

# 2. Define paths
WORKSPACE_ACTIONS="$HOME/TEST_workSpace/actions"
ACTIONS_SPACE="$WORKSPACE_ACTIONS"

# Assign extension based on $2 (defaults to .sh if $2 is missing or unrecognised)
if [ "$2" == "py" ]; then
    NEW_ACTION_NAME="$1.py"
elif [ "$2" == "sh" ]; then
    NEW_ACTION_NAME="$1.sh"
else
    NEW_ACTION_NAME="$1.sh"
fi

# Ensure target directory exists before creating files
mkdir -p "$ACTIONS_SPACE"

# 3. Check for existing file
if [ -e "$ACTIONS_SPACE/$NEW_ACTION_NAME" ]; then
    echo "Error: $ACTIONS_SPACE/$NEW_ACTION_NAME already exists."
    exit 1
fi

# 4. Create file and open nano
touch "$ACTIONS_SPACE/$NEW_ACTION_NAME"
echo "Created $ACTIONS_SPACE/$NEW_ACTION_NAME"

nano "$ACTIONS_SPACE/$NEW_ACTION_NAME"
