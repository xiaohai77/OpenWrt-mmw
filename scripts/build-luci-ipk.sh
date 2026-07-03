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

# ---- postinst：装完自动清 LuCI 缓存 + reload rpcd，网页刷新一下就能看到新菜单和权限 ----
cat > "$CTRL/postinst" <<'POSTINST_EOF'
#!/bin/sh
[ -n "$IPKG_INSTROOT" ] && exit 0

# 清理 LuCI 索引/模块缓存，让新菜单立即显示，不用等重启
rm -f /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache/

# 重新加载 rpcd，让新装的 acl.d/*.json 立即生效
# （不这么做的话，在 miaomiaowu 之后装本包时，ACL 权限要等下次
#  rpcd 重启/路由器重启才会被识别，网页上可能会短暂出现权限相关报错）
[ -x /etc/init.d/rpcd ] && /etc/init.d/rpcd reload >/dev/null 2>&1

exit 0
POSTINST_EOF
chmod 0755 "$CTRL/postinst"

tar --numeric-owner --owner=0 --group=0 -C "$CTRL" -czf "$WORK/control.tar.gz" .
echo "2.0" > "$WORK/debian-binary"

mkdir -p "$OUTDIR"
OUT="$OUTDIR/${PKG_NAME}_${VERSION}_all.ipk"
# ---- 最终 ipk = tar.gz 归档 ----
# 成员名同样必须带 "./" 前缀，原因见 build-ipk.sh 里的注释
(cd "$WORK" && tar --numeric-owner --owner=0 --group=0 -czf "$OUT" ./debian-binary ./control.tar.gz ./data.tar.gz)

echo "生成: $OUT"
