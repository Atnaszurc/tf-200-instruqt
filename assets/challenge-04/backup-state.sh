#!/bin/bash
# State Backup Script
# Creates timestamped backups of Terraform state files

set -e

# Get the directory to backup (default to current directory)
BACKUP_DIR="${1:-.}"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Error: Directory $BACKUP_DIR does not exist"
  exit 1
fi

cd "$BACKUP_DIR"

# Check if terraform.tfstate exists
if [ ! -f "terraform.tfstate" ]; then
  echo "No terraform.tfstate file found in $BACKUP_DIR"
  exit 1
fi

# Create backup with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="backup-${TIMESTAMP}.tfstate"

echo "Creating state backup..."
cp terraform.tfstate "$BACKUP_FILE"

if [ -f "$BACKUP_FILE" ]; then
  echo "✅ State backed up to: $BACKUP_FILE"
  echo ""
  echo "Backup details:"
  echo "  Location: $(pwd)/$BACKUP_FILE"
  echo "  Size: $(du -h "$BACKUP_FILE" | cut -f1)"
  echo "  Timestamp: $TIMESTAMP"
  echo ""
  echo "To restore this backup:"
  echo "  cp $BACKUP_FILE terraform.tfstate"
else
  echo "❌ Failed to create backup"
  exit 1
fi

# List all backups
BACKUP_COUNT=$(ls -1 backup-*.tfstate 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
  echo ""
  echo "All backups in this directory:"
  ls -lh backup-*.tfstate | awk '{print "  " $9 " (" $5 ")"}'
fi

# Made with Bob
