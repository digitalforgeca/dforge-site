#!/usr/bin/env bash
# deploy.sh — Build dforge.ca with Hugo
# Old FTP deploy to WHM is dead (decommissioned 2026-03-20).
# Site is now served by Dionysus (nginx) on the Forge VPS.
# TODO: Wire up deployment to Forge VPS via Hephaestus or scp.

set -euo pipefail

SITE_DIR="$(cd "$(dirname "$0")" && pwd)"
PUBLIC_DIR="$SITE_DIR/public"

echo "=== dforge.ca Hugo build ==="
echo "Site: $SITE_DIR"
echo ""

# Build
echo "--- Building..."
cd "$SITE_DIR"
hugo --minify --gc
echo "Built: $(ls $PUBLIC_DIR | wc -l | tr -d ' ') items in public/"

echo ""
echo "=== Build complete ==="
echo "NOTE: Deploy to Forge VPS not yet wired. Built files in: $PUBLIC_DIR"
echo "TODO: Deploy via Hephaestus or direct copy to Dionysus on the Forge VPS."
