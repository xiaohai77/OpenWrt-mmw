#!/bin/sh
# 妙妙屋 (miaomiaowu) 一键安装
# 用法: wget -O - https://miaomiaowu-openwrt.445568.xyz/install.sh | ash
set -e
REPO_URL="https://miaomiaowu-openwrt.445568.xyz"

echo "=== 妙妙屋 (miaomiaowu) 一键安装 ==="

if command -v opkg >/dev/null 2>&1; then
    echo "检测到 opkg（OpenWrt 23.05 及更早版本）"
    ARCH=$(opkg print-architecture | awk '$1=="arch" && $2!="all" && $2!="noarch" {print $3, $2}' | sort -n -r | head -n1 | awk '{print $2}')
    [ -z "$ARCH" ] && { echo "错误: 无法识别本机架构" >&2; exit 1; }
    echo "识别到架构: $ARCH"

    FEED_LINE="src/gz miaomiaowu $REPO_URL/openwrt-ipk/$ARCH"

    wget -q -O /tmp/mmw-ipk.pub "$REPO_URL/miaomiaowu-ipk.pub"
    opkg-key add /tmp/mmw-ipk.pub
    rm -f /tmp/mmw-ipk.pub

    mkdir -p /etc/opkg
    touch /etc/opkg/customfeeds.conf
    # 按包名做整行去重，重装/换架构时会把旧的一行替换掉，而不是无限累加
    sed -i '/^src\/gz miaomiaowu /d' /etc/opkg/customfeeds.conf
    echo "$FEED_LINE" >> /etc/opkg/customfeeds.conf

    opkg update
    opkg install miaomiaowu luci-app-miaomiaowu

elif command -v apk >/dev/null 2>&1; then
    echo "检测到 apk（OpenWrt 25.12 及更新版本）"
    ARCH=$(apk --print-arch)
    [ -z "$ARCH" ] && { echo "错误: 无法识别本机架构" >&2; exit 1; }
    echo "识别到架构: $ARCH"

    mkdir -p /etc/apk/keys
    wget -q -O /etc/apk/keys/miaomiaowu-apk.pem "$REPO_URL/miaomiaowu-apk.pem"

    mkdir -p /etc/apk/repositories.d
    echo "$REPO_URL/openwrt-apk/$ARCH/packages.adb" > /etc/apk/repositories.d/miaomiaowu.list

    apk update
    apk add miaomiaowu luci-app-miaomiaowu

else
    echo "错误: 未检测到 opkg 或 apk" >&2
    exit 1
fi

echo "=== 安装完成 ==="
