#!/bin/bash

echo "=================================="
echo "=====    DELETE ACTION      ======"
echo "=================================="

if [ -z "$1" ]; then
    echo "Usage: ws delete_action <action-name>"
    exit 1
fi

WORKSPACE_ACTIONS="$HOME/TEST_workSpace/actions"
ACTION_TO_DELETE="$1"
TARGET_FILE="$WORKSPACE_ACTIONS/$ACTION_TO_DELETE"

if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: Action '$ACTION_TO_DELETE' does not exist in $WORKSPACE_ACTIONS"
    exit 1
fi

# Custom y/n confirmation
read -p "Are you sure you want to delete '$ACTION_TO_DELETE'? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm "$TARGET_FILE"
    echo "Successfully deleted $ACTION_TO_DELETE"
else
    echo "Deletion canceled."
fi

exit 0
