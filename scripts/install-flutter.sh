#!/bin/bash
# install-flutter.sh

# Exit on error
set -e

# Define Flutter version (or 'stable')
FLUTTER_CHANNEL="stable"

if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  curl -C - -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz
  tar xf flutter_linux_3.29.0-stable.tar.xz
  rm flutter_linux_3.29.0-stable.tar.xz
else
  echo "Flutter SDK already exists, skipping download."
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Pre-download binaries
flutter doctor
flutter config --enable-web

# Build the project
echo "Building Flutter Web..."
cd frontend
flutter pub get
flutter build web --release
