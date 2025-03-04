# PAlert Data Uploader

A lightweight service that monitors a directory for new files and automatically uploads them to an FTP server. Designed to run on Raspberry Pi devices.

## Features

- Efficient file system monitoring using inotify
- Automatic FTP upload of new files
- Configurable through environment variables
- Runs as a systemd service
- Low resource usage

## Requirements

- Raspberry Pi running Linux (tested on Raspberry Pi 3 Model B)
- Go 1.22 or later (only for building from source)

## Quick Install

```bash
wget -O - https://raw.githubusercontent.com/rnduldulaojr/palert-data-uploader/main/download-and-install.sh | bash
```

## Manual Installation

1. Download the latest release from the releases page
2. Extract the package:
   ```bash
   tar xzf palert-uploader.tar.gz
   cd palert-uploader
   ```
3. Run the installation script:
   ```bash
   ./install.sh
   ```
4. Configure the service:
   ```bash
   sudo nano /etc/palert-uploader/.env
   ```
5. Start the service:
   ```bash
   sudo systemctl start palert-uploader
   sudo systemctl enable palert-uploader
   ```

## Configuration

Configure the following environment variables in `/etc/palert-uploader/.env`:

- `WATCH_DIR`: Directory to monitor for new files
- `FTP_HOST`: FTP server hostname
- `FTP_PORT`: FTP server port
- `FTP_USER`: FTP username
- `FTP_PASSWORD`: FTP password
- `FTP_UPLOAD_DIR`: Remote directory for uploads (must exist on server)

## Building from Source

```bash
# Clone the repository
git clone https://github.com/rnduldulaojr/palert-data-uploader.git
cd palert-data-uploader

# Build the package
./package.sh
```

## Service Management

```bash
# Start the service
sudo systemctl start palert-uploader

# Stop the service
sudo systemctl stop palert-uploader

# Check service status
sudo systemctl status palert-uploader

# View logs
journalctl -u palert-uploader -f
```

## License

MIT License
