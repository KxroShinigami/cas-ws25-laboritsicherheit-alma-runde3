#!/bin/bash
# Restore script for Podman volumes
# Usage: ./restore-volumes.sh <backup-directory>

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <backup-directory>"
  echo "Example: $0 ./backups/20240101_120000"
  exit 1
fi

BACKUP_PATH="$1"

if [ ! -d "${BACKUP_PATH}" ]; then
  echo "Error: Backup directory '${BACKUP_PATH}' not found!"
  exit 1
fi

echo "WARNING: This will overwrite existing volumes!"
echo "Backup location: ${BACKUP_PATH}"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "${confirm}" != "yes" ]; then
  echo "Restore cancelled."
  exit 0
fi

# Get the project name
PROJECT_NAME=$(basename "$(pwd)")

# List of volumes to restore
VOLUMES=("db_data" "nginx_logs" "wp_data" "redis_data")

# Function to find or create the volume name
find_or_create_volume() {
  local volume_base=$1
  local prefixed_name="${PROJECT_NAME}_${volume_base}"
  
  # Check if volume exists with prefix
  if podman volume exists "${prefixed_name}" 2>/dev/null; then
    echo "${prefixed_name}"
  # Check if volume exists without prefix
  elif podman volume exists "${volume_base}" 2>/dev/null; then
    echo "${volume_base}"
  else
    # Create volume with prefix (Podman Compose convention)
    echo "Creating volume: ${prefixed_name}"
    podman volume create "${prefixed_name}" > /dev/null
    echo "${prefixed_name}"
  fi
}

# Restore each volume
for volume_base in "${VOLUMES[@]}"; do
  backup_file="${BACKUP_PATH}/${volume_base}.tar.gz"
  
  if [ ! -f "${backup_file}" ]; then
    echo "Warning: Backup file '${backup_file}' not found, skipping..."
    continue
  fi
  
  volume_name=$(find_or_create_volume "${volume_base}")
  
  echo "Restoring volume: ${volume_name} from ${volume_base}.tar.gz"
  
  podman run --rm \
    --mount "type=volume,source=${volume_name},destination=/volume" \
    -v "$(pwd)/${BACKUP_PATH}:/backup" \
    busybox \
    sh -c "rm -rf /volume/* /volume/..?* /volume/.[!.]* 2>/dev/null || true && tar -xzf /backup/${volume_base}.tar.gz -C /volume"
  
  if [ $? -eq 0 ]; then
    echo "✓ Successfully restored ${volume_name}"
  else
    echo "✗ Failed to restore ${volume_name}"
    exit 1
  fi
done

echo ""
echo "Restore completed successfully!"
echo "You may need to restart your containers: podman compose restart"

