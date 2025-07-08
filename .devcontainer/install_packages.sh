#!/bin/bash

# 1. Get loacation of current ansible interpreter
targetLibraryPath=$(ansible --version | grep 'ansible python module location' | awk -F' = ' '{print $2}' | sed 's#/ansible$##')
echo "Target library path: $targetLibraryPath"

# 2. Get current pip installation path
currentLibraryPath=$(python3 -m site --user-site)
echo "Current library path: $currentLibraryPath"

# 3. Copy
echo "Copying libraries from $currentLibraryPath to $targetLibraryPath ..."
sudo cp -r "$currentLibraryPath"/* "$targetLibraryPath"

echo "✅ Done."
