#!/bin/bash
# 用法: build-apk-index.sh <apk二进制路径> <签名私钥pem路径> <公钥所在目录> <目标目录（内含该架构的所有.apk）>
# 在目标目录下生成签名过的 packages.adb 索引
set -euo pipefail

APK_BIN="$1"
SIGN_KEY="$2"
KEYS_DIR="$3"
TARGET_DIR="$4"

if ! ls "$TARGET_DIR"/*.apk >/dev/null 2>&1; then
  echo "目录 $TARGET_DIR 下没有 apk 文件，跳过" >&2
  exit 0
fi

(
  cd "$TARGET_DIR"
  "$APK_BIN" mkndx \
    --keys-dir "$KEYS_DIR" \
    --allow-untrusted \
    --sign "$SIGN_KEY" \
    --output packages.adb \
    ./*.apk
)

echo "已生成软件源索引: $TARGET_DIR/packages.adb"
