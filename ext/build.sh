#!/bin/sh
set -e

mkdir -p lib

clang \
  -c \
  -O2 \
  -o lib/libmp3encoder.o \
  ext/mp3encoder.c

ar rcs \
  lib/libmp3encoder.a \
  lib/libmp3encoder.o
