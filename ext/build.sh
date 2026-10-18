#!/bin/sh
set -e

EXT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LAME_DIR="$EXT_DIR/lame-4.0"
DIST_DIR="$EXT_DIR/lib"

mkdir -p "$DIST_DIR"

echo "==> Configuring LAME"

cd "$LAME_DIR"

if [ -f "Makefile" ]; then
    make distclean || true
fi

./configure \
  --disable-shared \
  --enable-static \
  --disable-frontend \
  --disable-decoder

echo "==> Building LAME"

make -j"$(sysctl -n hw.ncpu)"

echo "==> Copying LAME library"
cp libmp3lame/.libs/libmp3lame.a "$DIST_DIR/"

echo "==> Setting up local include directory for lame/lame.h"
# Create a local 'lame' directory under $DIST_DIR/include and copy/symlink lame.h into it
mkdir -p "$DIST_DIR/include/lame"
cp "$LAME_DIR/include/lame.h" "$DIST_DIR/include/lame/"

echo "==> Building mp3encoder"

clang \
  -O2 \
  -c \
  "$EXT_DIR/mp3encoder.c" \
  -I"$DIST_DIR/include" \
  -o "$DIST_DIR/mp3encoder.o"

echo "==> Creating libmp3encoder.a"

ar rcs \
  "$DIST_DIR/libmp3encoder.a" \
  "$DIST_DIR/mp3encoder.o"

echo "==> Done"
echo "    $DIST_DIR/libmp3encoder.a"
