#!/bin/bash
# Backup script for Podman volumes
# Usage: ./backup-volumes.sh [backup-directory] [--stop-containers]

set -euo pipefail

# Parse arguments
BACKUP_DIR="${1:-./backups}"
STOP_CONTAINERS=false

if [[ "${1:-}" == "--stop-containers" ]] || [[ "${2:-}" == "--stop-containers" ]]; then
  STOP_CONTAINERS=true
  if [[ "${1:-}" == "--stop-containers" ]]; then
    BACKUP_DIR="${2:-./backups}"
  fi
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"

# Create backup directory
mkdir -p "${BACKUP_PATH}"

echo "Starting volume backup to ${BACKUP_PATH}..."

# Check if containers are running
if podman compose ps 2>/dev/null | grep -q "Up\|running" 2>/dev/null; then
  if [ "${STOP_CONTAINERS}" = false ]; then
    echo ""
    echo "⚠️  WARNING: Containers are currently running!"
    echo "   File-level backups of database volumes (db_data, redis_data) while"
    echo "   containers are running may result in inconsistent backups."
    echo ""
    echo "   Options:"
    echo "   1. Stop containers first: podman compose stop"
    echo "   2. Use --stop-containers flag: ./backup-volumes.sh --stop-containers"
    echo "   3. Continue anyway (not recommended for production)"
    echo ""
    read -p "Continue anyway? (yes/no): " confirm
    if [ "${confirm}" != "yes" ]; then
      echo "Backup cancelled."
      exit 0
    fi
  fi
fi

# Stop containers if requested
if [ "${STOP_CONTAINERS}" = true ]; then
  echo "Stopping containers for consistent backup..."
  podman compose stop
  trap 'echo "Restarting containers..."; podman compose start' EXIT
fi

# Get the project name (directory name)
PROJECT_NAME=$(basename "$(pwd)")

# List of volumes to backup (from docker-compose.yml)
VOLUMES=("db_data" "nginx_logs" "wp_data" "redis_data")

# Function to find the actual volume name (with project prefix)
find_volume_name() {
  local volume_base=$1
  # Podman Compose prefixes volumes with project name
  local prefixed_name="${PROJECT_NAME}_${volume_base}"
  
  # Check if volume exists with prefix
  if podman volume exists "${prefixed_name}" 2>/dev/null; then
    echo "${prefixed_name}"
  # Check if volume exists without prefix (fallback)
  elif podman volume exists "${volume_base}" 2>/dev/null; then
    echo "${volume_base}"
  else
    echo ""
  fi
}

# Backup each volume
for volume_base in "${VOLUMES[@]}"; do
  volume_name=$(find_volume_name "${volume_base}")
  
  if [ -z "${volume_name}" ]; then
    echo "Warning: Volume '${volume_base}' not found, skipping..."
    continue
  fi
  
  echo "Backing up volume: ${volume_name}"
  
  # Use absolute path for backup directory and ensure it's writable
  BACKUP_ABS_PATH=$(cd "${BACKUP_PATH}" && pwd)
  
  podman run --rm \
    --userns=keep-id \
    --mount "type=volume,source=${volume_name},destination=/volume" \
    -v "${BACKUP_ABS_PATH}:/backup:Z" \
    busybox \
    tar -czf "/backup/${volume_base}.tar.gz" -C /volume .
  
  if [ $? -eq 0 ]; then
    echo "✓ Successfully backed up ${volume_name} -> ${volume_base}.tar.gz"
  else
    echo "✗ Failed to backup ${volume_name}"
    exit 1
  fi
done

# Create a manifest file with metadata
cat > "${BACKUP_PATH}/manifest.txt" <<EOF
Backup created: $(date)
Project: ${PROJECT_NAME}
Containers stopped: ${STOP_CONTAINERS}
Volumes backed up:
$(for volume_base in "${VOLUMES[@]}"; do echo "  - ${volume_base}"; done)
EOF

echo ""
echo "Backup completed successfully!"
echo "Backup location: ${BACKUP_PATH}"
echo ""
echo "To restore, use: ./restore-volumes.sh ${BACKUP_PATH}"

