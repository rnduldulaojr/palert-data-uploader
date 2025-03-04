package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/joho/godotenv"
	"github.com/jlaffaye/ftp"
)

var (
	ftpConn *ftp.ServerConn
)

func init() {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		fmt.Printf("Warning: .env file not found. Using environment variables.\n")
	}
}

func connectFTP() error {
	var err error
	ftpConn, err = ftp.Dial(
		fmt.Sprintf("%s:%s", os.Getenv("FTP_HOST"), os.Getenv("FTP_PORT")),
		ftp.DialWithTimeout(5*time.Second),
	)
	if err != nil {
		return fmt.Errorf("failed to connect to FTP server: %v", err)
	}

	err = ftpConn.Login(os.Getenv("FTP_USER"), os.Getenv("FTP_PASSWORD"))
	if err != nil {
		return fmt.Errorf("failed to login to FTP server: %v", err)
	}

	log.Printf("Successfully connected to FTP server")
	return nil
}

func uploadFile(filePath string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer file.Close()

	// Ensure FTP connection is alive
	if ftpConn == nil {
		if err := connectFTP(); err != nil {
			return err
		}
	}

	// Change to the preconfigured upload directory
	ftpUploadDir := os.Getenv("FTP_UPLOAD_DIR")
	if ftpUploadDir != "" {
		if err := ftpConn.ChangeDir(ftpUploadDir); err != nil {
			return fmt.Errorf("failed to change to upload directory %s: %v", ftpUploadDir, err)
		}
	}

	// Upload the file
	filename := filepath.Base(filePath)
	err = ftpConn.Stor(filename, file)
	if err != nil {
		// Try to reconnect once if the upload fails
		log.Printf("Upload failed, attempting to reconnect...")
		if connectFTP() == nil {
			// Change directory again after reconnect
			if ftpUploadDir != "" {
				if err := ftpConn.ChangeDir(ftpUploadDir); err != nil {
					return fmt.Errorf("failed to change to upload directory after reconnect: %v", err)
				}
			}
			// Reset file position to start
			file.Seek(0, 0)
			err = ftpConn.Stor(filename, file)
		}
	}

	if err != nil {
		return fmt.Errorf("failed to upload file: %v", err)
	}

	log.Printf("File uploaded successfully: %s to directory %s", filename, ftpUploadDir)
	return nil
}

// watchForNewFiles uses fsnotify to watch for new files
func watchForNewFiles(dir string) error {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return fmt.Errorf("error creating watcher: %v", err)
	}
	defer watcher.Close()

	// Add the directory to watch
	if err := watcher.Add(dir); err != nil {
		return fmt.Errorf("error watching directory: %v", err)
	}

	log.Printf("Watching for new files in directory: %s", dir)

	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				return fmt.Errorf("watcher channel closed")
			}
			// Only handle file creation events
			if event.Op&fsnotify.Create == fsnotify.Create {
				// Small delay to ensure file is completely written
				time.Sleep(100 * time.Millisecond)
				
				// Check if it's a regular file (not a directory)
				info, err := os.Stat(event.Name)
				if err != nil {
					log.Printf("Error checking file: %v", err)
					continue
				}
				if info.IsDir() {
					continue
				}

				log.Printf("New file detected: %s", event.Name)
				if err := uploadFile(event.Name); err != nil {
					log.Printf("Error uploading file: %v", err)
				}
			}
		case err, ok := <-watcher.Errors:
			if !ok {
				return fmt.Errorf("watcher error channel closed")
			}
			log.Printf("Watcher error: %v", err)
		}
	}
}

// checkDirPermissions verifies the program has necessary permissions
func checkDirPermissions(dir string) error {
	// Check if directory exists
	info, err := os.Stat(dir)
	if err != nil {
		return fmt.Errorf("error accessing directory: %v", err)
	}

	// Check if it's a directory
	if !info.IsDir() {
		return fmt.Errorf("%s is not a directory", dir)
	}

	// Try to create a temporary file to verify write permissions
	tempFile := filepath.Join(dir, ".permissions_check")
	f, err := os.Create(tempFile)
	if err != nil {
		return fmt.Errorf("directory is not writable: %v", err)
	}
	f.Close()
	os.Remove(tempFile)

	return nil
}

func main() {
	log.Printf("Starting PAlert Data Uploader...")

	// Initial FTP connection
	if err := connectFTP(); err != nil {
		log.Printf("Error: %v", err)
	}

	// Get watch directory
	watchDir := os.Getenv("WATCH_DIR")
	if watchDir == "" {
		log.Fatal("WATCH_DIR environment variable not set")
	}

	// Verify directory permissions
	if err := checkDirPermissions(watchDir); err != nil {
		log.Fatalf("Directory permission error: %v", err)
	}

	// Start watching for new files
	if err := watchForNewFiles(watchDir); err != nil {
		log.Fatalf("Error watching directory: %v", err)
	}
}
