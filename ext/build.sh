#!/bin/sh
set -e

EXT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LAME_DIR="$EXT_DIR/lame-4.0"
DIST_DIR="$EXT_DIR/lib"

mkdir -p "$DIST_DIR"

echo "==> Configuring LAME"

cd "$LAME_DIR"

./configure \
  --disable-shared \
  --enable-static \
  --disable-frontend \
  --disable-decoder

echo "==> Building LAME"

make -j"$(sysctl -n hw.ncpu)"

echo "==> Copying LAME library"
cp libmp3lame/.libs/libmp3lame.a "$DIST_DIR/"

echo "==> Building mp3encoder"

clang \
  -O2 \
  -c \
  "$EXT_DIR/mp3encoder.c" \
  -I"$LAME_DIR/include" \
  -o "$DIST_DIR/mp3encoder.o"

echo "==> Creating libmp3encoder.a"

ar rcs \
  "$DIST_DIR/libmp3encoder.a" \
  "$DIST_DIR/mp3encoder.o"

echo "==> Done"
echo "    $DIST_DIR/libmp3encoder.a"
