import argparse
import os
import sys
import time
from pathlib import Path

DEFAULT_NETWORK_PATH = Path(Path.cwd().anchor)
FILE_EXTENSIONS = ["*.csv", "*.txt", "*.log", "*.pdf"]

def search_network_share(path: Path, search_str: str):
    path = path.resolve()
    print(f"Searching for '{search_str}' starting from root: {path}")
    print("Press Ctrl+C at any time to interrupt the search.\n")

    matches_found = 0
    files_scanned = 0
    spinner_frames = ["|", "/", "-", "\\"]
    
    try:
        for ext in FILE_EXTENSIONS:
            for file in path.rglob(ext):
                # --- DO...WHILE LOADER BLOCK ---
                frame_idx = 0
                while True:
                    # Update status line with current animation frame
                    char = spinner_frames[frame_idx % len(spinner_frames)]
                    sys.stdout.write(f"\r[{char}] Scanning ({files_scanned} files checked)...")
                    sys.stdout.flush()
                    
                    # File search check
                    try:
                        if search_str in file.read_text(encoding="utf-8", errors="ignore"):
                            # Clear status line before printing match output
                            sys.stdout.write("\r" + " " * 80 + "\r")
                            print(f"Found match in: {file.resolve()}")
                            matches_found += 1
                    except (PermissionError, OSError):
                        pass

                    files_scanned += 1
                    
                    # Exit loop (emulating do...while condition)
                    break

    except KeyboardInterrupt:
        # Clear spinner line on exit
        sys.stdout.write("\r" + " " * 80 + "\r")
        print("\n[!] Search interrupted by user (Ctrl+C). Exiting safely.")
        print(f"Total files scanned: {files_scanned}")
        print(f"Total matches found: {matches_found}")
        sys.exit(0)

    # Clear line when scan finishes naturally
    sys.stdout.write("\r" + " " * 80 + "\r")
    print(f"Scan complete. Checked {files_scanned} files. Total matches found: {matches_found}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Network Search Tool")
    
    parser.add_argument(
        "-s", "--search",
        type=str,
        nargs="+",
        required=True,
        help="The string to search for"
    )
    
    parser.add_argument(
        "-p", "--path",
        type=str,
        default=str(DEFAULT_NETWORK_PATH),
        help=f"Optional custom path to search (defaults to root: {DEFAULT_NETWORK_PATH})"
    )

    args = parser.parse_args()
    
    search_query = " ".join(args.search) if isinstance(args.search, list) else args.search
    expanded_str = os.path.expandvars(args.path)
    target_path = Path(expanded_str).expanduser().resolve()
    
    search_network_share(target_path, search_query)
