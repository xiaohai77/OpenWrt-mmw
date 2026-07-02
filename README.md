# miaomiaowu OpenWrt 全架构打包方案

## 思路

不走 OpenWrt SDK，因为 miaomiaowu 是 `CGO_ENABLED=0` 的纯 Go 静态二进制，
直接用 `GOARCH`/`GOARM`/`GOMIPS` 组合交叉编译，然后手工拼装标准 ipk 结构
（`debian-binary` + `control.tar.gz` + `data.tar.gz`，用 `ar` 打包）。

一个 go-target 编一次，复用给多个 opkg 架构名（因为静态二进制不区分具体
CPU 型号），见 `scripts/arch-map.sh`：

| go-target  | 编译参数                        | 覆盖的 opkg 架构（举例） |
|-----------|----------------------------------|--------------------------|
| arm64     | GOARCH=arm64                     | aarch64_cortex-a53、aarch64_cortex-a72、aarch64_generic |
| armv7     | GOARCH=arm GOARM=7                | arm_cortex-a7/a9/a15 等 |
| armv6     | GOARCH=arm GOARM=6                | arm_arm1176jzf-s_vfp 等 |
| armv5     | GOARCH=arm GOARM=5                | arm_mpcore、arm_xscale |
| mips_sf   | GOARCH=mips GOMIPS=softfloat      | mips_24kc、mips_4kec |
| mipsle_sf | GOARCH=mipsle GOMIPS=softfloat    | mipsel_24kc、mipsel_74kc |
| x86       | GOARCH=386 GO386=softfloat        | i386_pentium4 等 |
| amd64     | GOARCH=amd64                      | x86_64 |

## 两个包

- `miaomiaowu`：Go 二进制 + init.d + 默认 UCI 配置，**每个架构一个 ipk**
- `luci-app-miaomiaowu`：纯 JS/JSON 的 LuCI 界面，`Architecture: all`，只打一份，
  依赖 `miaomiaowu`

## 使用

1. 把这个仓库整个推到你自己 GitHub（或者合并进你现有 substore 的打包仓库）
2. Actions → `Build miaomiaowu ipk (all archs)` → 手动触发，填 `mmw_ref`（要编译
   的 miaomiaowu 分支/tag）和 `version`
3. 想正式发布就打 tag（`v1.0.0` 这种），会自动跑完整矩阵并创建 Release，
   所有架构的 ipk + `luci-app-miaomiaowu_xxx_all.ipk` + `checksums.txt` 都在里面

## 安装到路由器

```sh
opkg install miaomiaowu_1.0.0_aarch64_cortex-a53.ipk
opkg install luci-app-miaomiaowu_1.0.0_all.ipk
