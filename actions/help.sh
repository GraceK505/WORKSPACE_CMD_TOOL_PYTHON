
echo
echo "Available actions:"
echo
ACTION_DIR="$HOME/TEST_workSpace/actions"
        echo "Usage:"
for action in "$ACTION_DIR"/*; do
    if [ -f "$action" ]; then
        name=$(basename "$action" | sed 's/\.[^.]*$//')
        echo
        echo " ws $name [arguments...]"
    fi
done
