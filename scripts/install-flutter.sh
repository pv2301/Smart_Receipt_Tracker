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
export PATH="$PATH:`pwd`/flutter/bin"

# Pre-warm
flutter doctor
flutter config --enable-web

cd frontend
flutter pub get
