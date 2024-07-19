#!/bin/bash
git submodule update --remote --merge
# Base directory containing all repositories
BASE_REPO_DIR="repositories"

# Base directory where package files will be copied
DESTINATION_DIR="packageFiles"

# Create the base destination directory if it doesn't exist
mkdir -p "$DESTINATION_DIR"

# Function to copy package files if they exist
copy_package_files() {
    local src_dir=$1
    local dest_dir=$2

    # Copy the package files if they exist
    if [ -f "$src_dir/package.json" ]; then
        cp "$src_dir/package.json" "$dest_dir"
    fi
    if [ -f "$src_dir/package-lock.json" ]; then
        cp "$src_dir/package-lock.json" "$dest_dir"
    fi
    if [ -f "$src_dir/yarn.lock" ]; then
        cp "$src_dir/yarn.lock" "$dest_dir"
    fi
}

# Initialize an array to hold the paths for the JSON file
paths=()

# Iterate over each subdirectory in the base repository directory
for REPO in "$BASE_REPO_DIR"/*/; do
    # Extract the repository name
    REPO_NAME=$(basename "$REPO")

    # Create a corresponding directory in the destination
    DEST_DIR="$DESTINATION_DIR/$REPO_NAME"
    mkdir -p "$DEST_DIR"

    # Flag to check if package files are found
    package_files_found=false

    # Check for package files at the top level
    if [ -f "$REPO/package.json" ] || [ -f "$REPO/package-lock.json" ] || [ -f "$REPO/yarn.lock" ]; then
        copy_package_files "$REPO" "$DEST_DIR"
        package_files_found=true
    else
        # Search for package files in subdirectories
        for SUBDIR in "$REPO"*/; do
            if [[ "$SUBDIR" != *test* ]] && [ "$package_files_found" = false ]; then
                if [ -f "$SUBDIR/package.json" ] || [ -f "$SUBDIR/package-lock.json" ] || [ -f "$SUBDIR/yarn.lock" ]; then
                    copy_package_files "$SUBDIR" "$DEST_DIR"
                    package_files_found=true
                fi
            fi
        done
    fi

    # If package files were found, add the path to the paths array
    if [ "$package_files_found" = true ]; then
        paths+=("$(realpath "$DEST_DIR")")
    fi
done
