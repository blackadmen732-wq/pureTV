#!/bin/bash
# Builds dist/PureTV.zip (manifest at the zip root) and its SHA256.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/make_images.py
mkdir -p dist
rm -f dist/PureTV.zip
(cd roku && zip -qr -X ../dist/PureTV.zip manifest source components images)
sha256sum dist/PureTV.zip > dist/PureTV.sha256
echo "Built dist/PureTV.zip"
cat dist/PureTV.sha256
