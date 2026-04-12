#!/bin/bash
# build-web.sh
set -e

# Add to PATH (path from install script)
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running build..."
cd frontend
flutter build web --release
