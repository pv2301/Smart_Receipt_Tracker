#!/bin/bash
# install-flutter.sh
set -e

# Clone Flutter if not exists
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "Flutter SDK exists."
fi

# Add to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Pre-warm Flutter for web (flutter doctor fails on CI without Android/Xcode — ignore)
flutter config --enable-web
flutter doctor --version 2>/dev/null || true

cd frontend
flutter pub get
