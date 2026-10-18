#!/bin/sh
set -e

EXT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LAME_DIR="$EXT_DIR/lame-4.0"
DIST_DIR="$EXT_DIR/lib"

mkdir -p "$DIST_DIR"

echo "==> Configuring LAME"

cd "$LAME_DIR"

# Clean any previous architecture build state if re-running
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

echo "==> Building mp3encoder"

# Include both the LAME include directory and the root directory so <lame/lame.h> resolves correctly
clang \
  -O2 \
  -c \
  "$EXT_DIR/mp3encoder.c" \
  -I"$LAME_DIR" \
  -I"$LAME_DIR/include" \
  -I"$LAME_DIR/libmp3lame" \
  -o "$DIST_DIR/mp3encoder.o"

echo "==> Creating libmp3encoder.a"

ar rcs \
  "$DIST_DIR/libmp3encoder.a" \
  "$DIST_DIR/mp3encoder.o"

echo "==> Done"
echo "    $DIST_DIR/libmp3encoder.a"
