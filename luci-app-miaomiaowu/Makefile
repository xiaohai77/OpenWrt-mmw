include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-miaomiaowu

# Same logic as the miaomiaowu backend Makefile: dynamically fetch the current 
# actual released version number of this package from your published Packages index 
# during compilation, avoiding manual updates every time.
# Although this package itself is arch:all, the index file is distributed by specific 
# architecture directories. We can simply use the one corresponding to ARCH_PACKAGES, 
# which also contains the record for luci-app-miaomiaowu 
# (build-ipk-repo.sh will copy this package into each architecture directory during packaging).
PKG_VERSION:=$(strip $(shell wget -qO- "https://miaomiaowu-openwrt.445568.xyz/openwrt-ipk/$(ARCH_PACKAGES)/Packages" 2>/dev/null | \
	awk '/^Package: luci-app-miaomiaowu$$/{f=1;next} f&&/^Version:/{print $$2;exit} /^$$/{f=0}'))
ifeq ($(PKG_VERSION),)
  # If fetching fails, assign an obviously invalid dummy value so that the compilation 
  # will fail with an error later, rather than silently publishing the package with an incorrect version.
  PKG_VERSION:=0.0.0-VERSION-FETCH-FAILED
endif
PKG_RELEASE:=1

PKG_MAINTAINER:=第十六夜月
PKG_LICENSE:=MIT

LUCI_TITLE:=LuCI support for miaomiaowu (妙妙屋)
LUCI_DEPENDS:=+miaomiaowu

# luci.mk will automatically pack ./root and ./htdocs from the same directory as this 
# Makefile into the final ipk as-is. There is no need to write Build/Prepare, 
# handle downloads, or define Package/install.
# This perfectly matches the existing luci-app-miaomiaowu/root and 
# luci-app-miaomiaowu/htdocs in your repository.
include $(TOPDIR)/feeds/luci/luci.mk

ifeq ($(PKG_VERSION),0.0.0-VERSION-FETCH-FAILED)
  # Lesson learned from the previous substore issue: arch:all packages using luci.mk 
  # will skip the Build/Prepare stage, meaning any checks written there won't execute. 
  # Instead, we use Make's $(error) to fail and terminate immediately during Makefile 
  # parsing, ensuring the check actually takes effect.
  $(error Failed to fetch the version number from https://miaomiaowu-openwrt.445568.xyz/openwrt-ipk/$(ARCH_PACKAGES)/Packages. Please check if the URL is accessible and if the luci-app-miaomiaowu entry actually exists in the Packages index)
endif

$(eval $(call BuildPackage,luci-app-miaomiaowu))
