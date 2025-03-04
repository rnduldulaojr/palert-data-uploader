#!/bin/bash

# Exit on any error
set -e

# URL where the package will be hosted
PACKAGE_URL="YOUR_PACKAGE_URL_HERE"

echo "Downloading PAlert Data Uploader..."
wget "$PACKAGE_URL" -O palert-uploader.tar.gz

echo "Extracting package..."
tar xzf palert-uploader.tar.gz

echo "Installing..."
cd palert-uploader
./install.sh

# Cleanup
cd ..
rm -rf palert-uploader palert-uploader.tar.gz

echo "Installation complete!"
