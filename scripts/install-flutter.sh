#!/bin/bash
# install-flutter.sh
set -e

# Clone Flutter FORA do diretório do projeto para não entrar no bundle da Lambda
FLUTTER_HOME="/tmp/flutter-sdk"

if [ ! -d "$FLUTTER_HOME" ]; then
  echo "Cloning Flutter SDK para $FLUTTER_HOME..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME"
else
  echo "Flutter SDK já existe em $FLUTTER_HOME."
fi

export PATH="$PATH:$FLUTTER_HOME/bin"

flutter config --enable-web
flutter --version 2>/dev/null || true

cd frontend
flutter pub get
