#!/bin/bash

# Exit on any error
set -e

# GitHub configuration
GITHUB_USER="rnduldulaojr"
GITHUB_REPO="palert-data-uploader"

# Get the latest release URL
echo "Getting latest release information..."
RELEASE_URL=$(curl -s "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest" | \
    grep "browser_download_url.*tar.gz" | \
    cut -d '"' -f 4)

if [ -z "$RELEASE_URL" ]; then
    echo "Error: Could not find release package"
    exit 1
fi

echo "Downloading PAlert Data Uploader..."
curl -L -o palert-uploader.tar.gz "$RELEASE_URL"

echo "Extracting package..."
tar xzf palert-uploader.tar.gz

echo "Installing..."
cd palert-uploader
./install.sh

# Cleanup
cd ..
rm -rf palert-uploader palert-uploader.tar.gz

echo "Installation complete!"
