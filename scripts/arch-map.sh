#!/bin/bash
# 架构映射表：一个 go-target 对应一组 OpenWrt opkg Architecture 名称
# 因为 Go 静态编译不依赖 libc/内核头文件，同一个 go-target 编出的二进制
# 可以直接复用给多个 opkg 架构名，不需要每个架构单独编译一次。
#
# go-target 格式: GOOS,GOARCH,GOARM,GOMIPS  (用 - 占位表示不设置)
#
# 用法: source arch-map.sh 后遍历 GO_TARGETS，再查 OPKG_ARCHES_<go_target> 里的架构列表

declare -A GO_TARGETS=(
  [arm64]="linux,arm64,-,-"
  [armv7]="linux,arm,7,-"
  [armv6]="linux,arm,6,-"
  [armv5]="linux,arm,5,-"
  [mips_sf]="linux,mips,-,softfloat"
  [mipsle_sf]="linux,mipsle,-,softfloat"
  [x86]="linux,386,-,softfloat"
  [amd64]="linux,amd64,-,-"
)

declare -A OPKG_ARCHES=(
  [arm64]="aarch64_cortex-a53 aarch64_cortex-a72 aarch64_generic"
  [armv7]="arm_cortex-a7 arm_cortex-a7_neon-vfpv4 arm_cortex-a9 arm_cortex-a9_neon arm_cortex-a15_neon-vfpv4"
  [armv6]="arm_arm1176jzf-s_vfp arm_fa526"
  [armv5]="arm_mpcore arm_xscale"
  [mips_sf]="mips_24kc mips_4kec mips_mips32"
  [mipsle_sf]="mipsel_24kc mipsel_74kc mipsel_mips32"
  [x86]="i386_pentium4 i386_pentium-mmx i386_geode"
  [amd64]="x86_64"
)
