#!/bin/bash
# 用法: build-luci-ipk.sh <version> <output_dir>
set -euo pipefail

VERSION="$1"
OUTDIR="$2"
PKG_NAME="luci-app-miaomiaowu"
SRC="luci-app-miaomiaowu"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

DATA="$WORK/data"
mkdir -p "$DATA"
cp -r "$SRC/root/." "$DATA/"
mkdir -p "$DATA/www/luci-static"
cp -r "$SRC/htdocs/luci-static/." "$DATA/www/luci-static/"

tar --numeric-owner --owner=0 --group=0 -C "$DATA" -czf "$WORK/data.tar.gz" .

CTRL="$WORK/control"
mkdir -p "$CTRL"
INSTALLED_SIZE=$(du -sb "$DATA" | cut -f1)

cat > "$CTRL/control" <<EOF
Package: $PKG_NAME
Version: $VERSION
Architecture: all
Maintainer: 第十六夜月
Section: luci
Category: LuCI
Depends: luci-base, miaomiaowu
Installed-Size: $INSTALLED_SIZE
Description: LuCI support for 妙妙屋 (miaomiaowu)
EOF

tar --numeric-owner --owner=0 --group=0 -C "$CTRL" -czf "$WORK/control.tar.gz" .
echo "2.0" > "$WORK/debian-binary"

mkdir -p "$OUTDIR"
OUT="$OUTDIR/${PKG_NAME}_${VERSION}_all.ipk"
# ---- 最终 ipk = tar.gz 归档 ----
# 成员名同样必须带 "./" 前缀，原因见 build-ipk.sh 里的注释
(cd "$WORK" && tar --numeric-owner --owner=0 --group=0 -czf "$OUT" ./debian-binary ./control.tar.gz ./data.tar.gz)

echo "生成: $OUT"
