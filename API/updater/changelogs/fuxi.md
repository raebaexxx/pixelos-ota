# PixelOS for Xiaomi 13 (fuxi)

20.10.2026:
- Fix Dolby Vision video playback: recordings play again, and the phone no longer slows to a crawl while watching them
- Fix the phone heating up and draining the battery while playing music: the Dolby audio effects kept three CPU cores busy at all times, they are disabled for now (the Dolby Atmos effects are unavailable as a result)

19.10.2026:
- Rework the Dolby stack: Dolby Atmos and Dolby audio in a dedicated repository, Dolby Vision with the camera
- Fix the Dolby and Qualcomm Codec2 services crashing on Android 17
- Ship the complete media codec configuration, some codecs were unavailable without it
- Camera: restore the quick camera HAL
- Camera: fix recorded videos never being saved, they stayed as ".pending-" files and did not appear in the gallery
- Camera: the thumbnail button now opens your own gallery app (Google Photos and others) instead of failing
- Fix the incoming caller number not being parsed on VoLTE and VoWiFi
- Fingerprint: use the legacy enrollment screen, the "Do it later" button overlapped the sensor
- Enable Always On Display wallpapers
- Use the stock shape for the rounded corners of the display
- Update the build fingerprint and attestation properties to the current global build
- Spoof the stock brand and product properties
- Add alternative captive portal check URLs for regions without access to Google
- Report OEM unlocking as unsupported
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
