#!/bin/bash
# build-web.sh
set -e

# Flutter foi instalado em /tmp/flutter-sdk pelo install script
FLUTTER_HOME="/tmp/flutter-sdk"
export PATH="$PATH:$FLUTTER_HOME/bin"

echo "Running build..."
cd frontend
flutter build web --release
