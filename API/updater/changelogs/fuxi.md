# PixelOS for Xiaomi 13 (fuxi)

11.11.2026:
- November 2026 security patch (2026-11-01): fixes for a lock-screen bypass through the default USB functions, a shell command vulnerability in the window manager, background foreground-service starts and permission checks for activities inside a task
- Play Integrity: reworked spoofing stack; Device and Strong Integrity can pass again with a valid keybox. Configure it in Settings > System > Developer options > Spoofing (Keybox, Play Integrity Fix, advanced Play Store fingerprint spoofing)
- Updater: sync with the current PixelOS Updater; support for incremental OTA feeds, update checks when the app opens, fixed changelog loading, and removal of the obsolete Certified properties section
- OTA: the fuxi feed and changelog URLs now live in a device overlay, and fuxi builds are always tagged as official
- Kernel: update to Linux 5.15.223 (LineageOS 24.0); KernelSU Next v3.4.2 stable and SuSFS 2.3.0 are retained
- Update the shared sm8550 vendor blobs and firmware from HyperOS OS3.0.312.0.WMBCNXM
- Update CarrierConfig from OS3.0.304.0.WMKCNXM and use the stock signal-strength thresholds, so the bars match stock for LTE and NR
- Dolby Atmos: use the fuxi stock tuning instead of the Nuwa tuning, fixing IEQ, virtualization and volume levels
- Recovery: load the touchscreen driver in recovery, so touch works there
- Camera: remove the old MiuiCamera and Google Camera inherit entries and keep the current MiuiCamera
- Remove the deprecated ATFWD and irsc_util services, unused properties and the unused AVB key setup
- Full platform changelog: https://blog.pixelos.net/blogs/2026-11-09-November-Update

30.10.2026:
- KernelSU Next: switch from dev builds to the official stable v3.4.2 release, so the manager APK from GitHub releases works without the UAPI warning
- SuSFS: update to the latest stable 2.3.0 revision (e30f1502), including the priority UID filter and fixes
- FuxiParts: add a new HBM-only parts app with manual and automatic HBM controls, ambient-light threshold, timing settings and quick settings tiles
- FuxiParts: fix Auto HBM exit hysteresis and prevent stale manual brightness from being restored
- Dolby Atmos: sync with the latest LunarisDolby upstream; refreshed Material 3 UI, compact navigation, more translations and profile/effect/AutoEQ fixes
- Update the display power profile entries for Android 17

25.10.2026:
- Bluetooth: restore LHDC support, falling back to the software encoder when the hardware path is unavailable
- Fix the rounded corner overlay to match the stock display shape
- Remove the XiaomiParts app and DSP volume synchronizer

24.10.2026:
- https://blog.pixelos.net/blogs/2026-10-19-October-Update

20.10.2026:
- Dolby Atmos: new app with a redesigned interface, AutoEQ profiles, per-app profiles, per-device settings memory and preset import/export
- Dolby Atmos: the app has been replaced, so its settings start from defaults
- Fix the incoming caller number not being parsed on VoLTE and VoWiFi
- Fingerprint: use the legacy enrollment screen, the "Do it later" button overlapped the sensor
- Enable Always On Display wallpapers
- Use the stock shape for the rounded corners of the display
- Remove the unused mtd, mfidoca and tidaservice services
- Update the kernel to the current LineageOS source (Linux 5.15.220)
- Update to the October 2026 security patch level
- OTA updates now include init_boot

15.10.2026:
- Update KernelSU Next + SuSFS

13.10.2026:
- Add KernelSU Next + SuSFS

09.10.2026-2:
- Fix no sound from Bluetooth headphones on headsets that support the LHDC codec
- Remove LHDC from the Bluetooth codec list, this device has no encoder for it

09.10.2026:
- Fix one-way calls on speakerphone, the other party could not hear you

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
