#!/bin/sh
# Samlar exakt de filer som ska upp på servern i mappen dist/ och i donkeystories-server.zip.
# Kör från repots rot:  sh server/paketera.sh
set -eu
cd "$(dirname "$0")/.."

FILER="index.html 404.html style.css app.js robots.txt .htaccess img fonts"

for f in $FILER; do
  [ -e "$f" ] || { echo "Saknas: $f" >&2; exit 1; }
done

rm -rf dist donkeystories-server.zip
mkdir dist
cp -R $FILER dist/

if command -v zip >/dev/null 2>&1; then
  (cd dist && zip -qr ../donkeystories-server.zip .)
  echo "Klart: dist/ och donkeystories-server.zip"
else
  echo "Klart: dist/ (zip saknas, packa mappen själv)"
fi
