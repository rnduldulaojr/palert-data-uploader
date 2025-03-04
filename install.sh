#!/bin/bash

# Exit on any error
set -e

echo "Installing PAlert Data Uploader..."

# Check for inotify support
if [ ! -f /proc/sys/fs/inotify/max_user_watches ]; then
    echo "Error: inotify is not supported on this system"
    exit 1
fi

# Check inotify limits
MAX_WATCHES=$(cat /proc/sys/fs/inotify/max_user_watches)
if [ "$MAX_WATCHES" -lt "8192" ]; then
    echo "Warning: inotify watch limit is low ($MAX_WATCHES)"
    echo "Increasing inotify watch limit..."
    echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

# Create necessary directories
echo "Creating directories..."
sudo mkdir -p /usr/local/bin
sudo mkdir -p /etc/palert-uploader
sudo mkdir -p /var/log/palert-uploader

# Copy binary
echo "Installing binary..."
sudo cp build/palert-uploader /usr/local/bin/
sudo chmod +x /usr/local/bin/palert-uploader

# Copy service file
echo "Installing systemd service..."
sudo cp palert-uploader.service /etc/systemd/system/
sudo systemctl daemon-reload

# Copy and configure environment file
echo "Setting up environment file..."
if [ ! -f /etc/palert-uploader/.env ]; then
    sudo cp .env.example /etc/palert-uploader/.env
    echo "Please edit /etc/palert-uploader/.env with your configuration"
fi

# Set permissions
echo "Setting permissions..."
sudo chown -R pi:pi /etc/palert-uploader
sudo chmod 600 /etc/palert-uploader/.env

echo "Installation complete!"
echo "Next steps:"
echo "1. Edit /etc/palert-uploader/.env with your configuration"
echo "2. Start the service: sudo systemctl start palert-uploader"
echo "3. Enable service on boot: sudo systemctl enable palert-uploader"
echo "4. Check status: sudo systemctl status palert-uploader"
