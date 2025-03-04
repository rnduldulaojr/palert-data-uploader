#!/bin/bash

# Exit on any error
set -e

echo "Building PAlert Data Uploader package..."

# Create build and dist directories
mkdir -p build dist

# Build for ARM (Raspberry Pi)
echo "Building binary..."
GOOS=linux GOARCH=arm GOARM=7 go build -o build/palert-uploader

# Create a temporary packaging directory
PACKAGE_DIR=$(mktemp -d)
mkdir -p "$PACKAGE_DIR/palert-uploader"

# Copy files to package directory
echo "Copying files..."
cp build/palert-uploader "$PACKAGE_DIR/palert-uploader/"
cp install.sh "$PACKAGE_DIR/palert-uploader/"
cp .env.example "$PACKAGE_DIR/palert-uploader/"
cp palert-uploader.service "$PACKAGE_DIR/palert-uploader/"
cp README.md "$PACKAGE_DIR/palert-uploader/"

# Create tarball
echo "Creating package..."
cd "$PACKAGE_DIR"
tar czf palert-uploader.tar.gz palert-uploader/
cd "$OLDPWD"
mv "$PACKAGE_DIR/palert-uploader.tar.gz" dist/

# Cleanup
cd ..
rm -rf "$PACKAGE_DIR"

echo "Package created at dist/palert-uploader.tar.gz"
