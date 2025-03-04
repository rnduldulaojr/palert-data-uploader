#!/bin/bash

# Detect target architecture
read -p "Select target Raspberry Pi version (3/4 for 64-bit, 0/1/2 for 32-bit) [3]: " pi_version
pi_version=${pi_version:-3}

if [[ "$pi_version" == "3" || "$pi_version" == "4" ]]; then
    echo "Building for Raspberry Pi 3/4 (64-bit)..."
    GOOS=linux GOARCH=arm64 go build -o palert-uploader
else
    echo "Building for Raspberry Pi ${pi_version} (32-bit)..."
    GOOS=linux GOARCH=arm GOARM=6 go build -o palert-uploader
fi

if [ $? -eq 0 ]; then
    echo "Build successful! Binary: palert-uploader"
    ls -lh palert-uploader
else
    echo "Build failed!"
    exit 1
fi
