#!/bin/sh

# Fail eagerly.
set -e

# Needed because if it is set, cd may print the path it changed to.
unset CDPATH

# Ensure this script is running on a macOS host.
if [ "$(uname -s)" != "Darwin" ]; then
  echo "This script is intended to run on macOS only." >&2
  exit 1
fi

# Clone and checkout the current version of Flutter into vendor/flutter.
FLUTTER_SHA="0444dda50838685faf9c729ea7f225da71507223"
FLUTTER_DIR="vendor/flutter"

# If the SDK is already installed, skip the installation.
# Check vendor/flutter/bin/cache/flutter.version to FLUTTER_SHA.
# "engineRevision": "..."
if [ -f "$FLUTTER_DIR/bin/cache/flutter.version.json" ]; then
  INSTALLED_FLUTTER_SHA=$(cat "$FLUTTER_DIR/bin/cache/flutter.version.json" | grep -o '"engineRevision": ".*"' | cut -d'"' -f4)
  if [ "$INSTALLED_FLUTTER_SHA" = "$FLUTTER_SHA" ]; then
    echo "Flutter SDK is already installed ($FLUTTER_SHA)."
    exit 0
  fi
fi

FLUTTER_ORIGIN="https://github.com/flutter/flutter"

# Remove the existing Flutter directory.
rm -rf "$FLUTTER_DIR"

# Shallow clone the Flutter repository.
git clone "$FLUTTER_ORIGIN" "$FLUTTER_DIR"
git -C "$FLUTTER_DIR" checkout $FLUTTER_SHA

# Set the engine prebuilt.
export FLUTTER_PREBUILT_ENGINE_VERSION="$FLUTTER_SHA"

# Initialize the Dart SDK.
"$FLUTTER_DIR/bin/dart" --version

# Initialize the Flutter SDK.
"$FLUTTER_DIR/bin/flutter" --version
