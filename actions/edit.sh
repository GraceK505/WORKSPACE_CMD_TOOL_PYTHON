#!/bin/bash

# 1. Check for argument first
if [ -z "$1" ]; then
    echo "Usage: $0 <action-name>"
    exit 1
fi

ACTIONS="$HOME/TEST_workSpace/actions"
PATH_TO_ACTION="$ACTIONS/$1"

echo "=================================="
echo "======= YOU ARE ABOUT TO ========="
echo "======== EDIT $1 ACTION =========="
echo "=================================="

nano "$PATH_TO_ACTION"


