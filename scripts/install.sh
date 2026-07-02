#!/bin/sh
# 妙妙屋 (miaomiaowu) 一键安装
# 用法: wget -O - https://miaomiaowu-openwrt.445568.xyz/install.sh | ash
set -e
REPO_URL="https://miaomiaowu-openwrt.445568.xyz"

echo "=== 妙妙屋 (miaomiaowu) 一键安装 ==="

if [ -x /bin/opkg ]; then
    ARCH=$(opkg print-architecture | awk '$1=="arch" && $2!="all" && $2!="noarch" {print $3, $2}' | sort -n -r | head -n1 | awk '{print $2}')
    [ -z "$ARCH" ] && { echo "错误: 无法识别本机架构" >&2; exit 1; }
    echo "识别到架构: $ARCH"

    wget -q -O /tmp/mmw-ipk.pub "$REPO_URL/miaomiaowu-ipk.pub"
    opkg-key add /tmp/mmw-ipk.pub
    rm -f /tmp/mmw-ipk.pub

    if ! grep -q "miaomiaowu" /etc/opkg/customfeeds.conf 2>/dev/null; then
        echo "src/gz miaomiaowu $REPO_URL/openwrt-ipk/$ARCH" >> /etc/opkg/customfeeds.conf
    fi

    opkg update
    opkg install miaomiaowu luci-app-miaomiaowu

elif [ -x /usr/bin/apk ]; then
    echo "apk 软件源还没做，下一阶段补" >&2
    exit 1
else
    echo "错误: 未检测到 opkg 或 apk" >&2
    exit 1
fi

echo "=== 安装完成 ==="
