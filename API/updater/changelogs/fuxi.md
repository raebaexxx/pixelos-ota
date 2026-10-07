# PixelOS for Xiaomi 13 (fuxi)

07.10.2026:
- Update vendor blobs to OS3.0.307.0.WMCCNXM
- Add HDR flash support on the rear camera
- Raise the camera memory reclaim thresholds, so it stops dropping its buffer when memory is tight
- Fix haptic feedback replaying ringtone patterns, which made light feedback about twice as loud as intended

06.10.2026-3:
- Switch to official release keys, so builds can be verified as authentic
- Install this update manually: devices on a previous test-keys build cannot take it over the air
- Fix the Updater reporting an update check error instead of checking, on devices that installed over a build with different signing keys
- Devices hitting this can run "adb shell cmd package uninstall-system-updates net.pixelos.ota", or format data
- powerhint: Add lowest OPP to GPU min frequency powerhint lists

06.10.2026-2:
- Update kernel to current LineageOS source, includes September 2026 security patches
- Remove PASR (Power-Aware Suspend/Resume)

06.10.2026:
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
