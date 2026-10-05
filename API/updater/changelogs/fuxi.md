# PixelOS for Xiaomi 13 (fuxi)

05.10.2026:
- Fix Dolby Vision recording (the camera crashed or wrote nothing with Dolby Vision enabled)
- Fix silent AC-3, E-AC-3 and AC-4 audio
- Keep recovery and init_boot out of OTA updates
- powerhint: Add lowest OPP to CPU min frequency powerhint lists
- Allow device-specific media profiles
- Import WiFi Display (WFD) system blobs from A171WEH.20

04.10.2026: 
- Add OTA updates

03.10.2026:
- Switch to Vulkan UI renderer
- Import missing libjnihelper.so for CACertService app
- Adapt powerhint for kalama
- Lower down schedutil down rate limit for prime CPU
- Update powerhint.json nodes to kalama
- Import powerhint.json from taro
- init: Enable powerhint parsing after boot completion
- sepolicy: Address powerhal denials
- Add back ro.vendor.extension_library definition
- Migrate to common libqti-perfd-client and power-libperfmgr
- Remove QTI perfd
- Revert "Set force_sysfs_fallback=1 sysctl via cmdline"
- Drop duplicate mkbootimg header version args
- init: Fix qcom-battery permissions
- fastbootd is now enabled by default
- sepolicy: Add coredomain for esimswitcher app
- sepolicy: Replace vendor_sysfs_usb_c with sysfs_typec
- Update from OS3.0.311.0.WMBCNXM
