#!/usr/bin/env bash
# deploy.sh — Build dforge.ca with Hugo and deploy to cPanel via FTP
# Usage: ./deploy.sh [--dry-run]

set -euo pipefail

SITE_DIR="$(cd "$(dirname "$0")" && pwd)"
PUBLIC_DIR="$SITE_DIR/public"
FTP_HOST="dforge.ca"
FTP_USER="deploy@dforge.ca"
FTP_PASS="${DFORGE_FTP_PASS:-aYURyjIF6YUa74RIWC}"
FTP_REMOTE="/public_html"
DRY_RUN="${1:-}"

echo "=== dforge.ca Hugo deploy ==="
echo "Site: $SITE_DIR"
echo "Target: ftp://$FTP_HOST$FTP_REMOTE"
echo ""

# 1. Build
echo "--- Building..."
cd "$SITE_DIR"
hugo --minify --gc
echo "Built: $(ls $PUBLIC_DIR | wc -l | tr -d ' ') items in public/"

if [[ "$DRY_RUN" == "--dry-run" ]]; then
  echo "Dry run — skipping upload"
  exit 0
fi

# 2. Upload recursively via curl FTP
echo ""
echo "--- Uploading..."

upload_dir() {
  local local_dir="$1"
  local remote_path="$2"

  # Upload files in this directory
  for f in "$local_dir"/*; do
    [[ -e "$f" ]] || continue
    local name
    name="$(basename "$f")"

    if [[ -d "$f" ]]; then
      # Recurse into subdirectory
      upload_dir "$f" "$remote_path/$name"
    else
      echo "  $remote_path/$name"
      curl -s -T "$f" \
        "ftp://$FTP_HOST$remote_path/$name" \
        --user "$FTP_USER:$FTP_PASS" \
        --ssl -k --ftp-pasv \
        --ftp-create-dirs \
        --connect-timeout 15 \
        2>&1 || echo "  WARN: failed to upload $name"
    fi
  done
}

upload_dir "$PUBLIC_DIR" "$FTP_REMOTE"

echo ""
echo "=== Deploy complete ==="
echo "Live at: https://dforge.ca"
