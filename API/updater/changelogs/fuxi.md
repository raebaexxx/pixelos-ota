# PixelOS for Xiaomi 13 (fuxi)

**Build date:** 03.10.2026
**Version:** fuxi-17.0-20261003
**Platform:** Android 17 (API 37)
**Upstream:** `xiaomi-sm8550-devs/android_device_xiaomi_sm8550-common` @ `lineage-24.0`

---

## Platform update

LineageOS 23.2 (Android 16) → `lineage-24.0` (Android 17). 17 upstream commits, plus 3 local sepolicy fixes.

### Upstream

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

Notable consequences of the power stack migration: the QTI perf blobs (~50 files under `vendor/etc/perf`, `vendor/etc/pwr`, plus `libqti-perfd*`, `poweropt-service`, `perf-hal-service`) and qspmhal (4 files) are no longer in the vendor blobs. `power-service.lineage-libperfmgr` and `libqti-perfd-client` replace `power-service-qti`, and `configs/power/powerhint.json` replaces the stock QTI `powerhint.xml`.

Vendor security patch level is now `2026-08-01`.

---

## Dolby Atmos

Three fixes from `lofx-lee/android_packages_apps_DolbyAtmos`:

- **Stereo widening setting was ineffective.** `setCurrentProfile()` only reapplied the profile index, so per-profile settings were lost when the audio route changed or playback started. Replaced with `restoreCurrentProfile()`, which restores the profile and all of its settings, and treats the persisted value as the source of truth
- **Profile-specific list preferences showed "Unknown" on first boot.** Defaults now come from `DolbyConstants` (`STEREO_WIDENING_DEFAULT`, `IEQ_PRESET_DEFAULT`, `DIALOGUE_ENHANCER_DEFAULT`) instead of reading back the live effect state. `entryValues.contains()` switched to `findIndexOfValue() >= 0`
- Added the `dolby_volume_leveler_supported` config flag, off by default, so the setting is hidden when the blobs do not support it

Also: removed a duplicate `vendor.dolby.hardware.dms::IDms` declaration in `sm8550-common-dolby/sepolicy/vendor/hwservice_contexts` — the same service was listed twice in that single file.

---

## Local fixes

Three sepolicy conflicts surfaced during the merge. The upstream `lineage-24.0` files assume a device tree without `fuxi-miuicamera`, so they collided with it:

- **`hal_quickcamera.te`** — dropped `hal_attribute(quickcamera)`. The attributes are already declared in `fuxi-miuicamera/sepolicy/vendor/attributes`; the second declaration failed with `Duplicate declaration of type`
- **`property_contexts`** — dropped the camera prefixes `persist.vendor.EnableP3ColorSpace` and `vendor.camera.sensor.*`, already declared in `fuxi-miuicamera`. Failed with `Duplicate prefix match detected`
- **`hwservice_contexts`** — dropped four entries that were byte for byte identical to `fuxi-miuicamera/sepolicy/vendor/hwservice_contexts`. Failed with `Multiple same specifications`

The property and attribute types remain declared in `sepolicy/vendor/property.te` and `hal_camera_default.te`; only the duplicate context entries were removed.

---

## Build infrastructure

- Restored `external/chromium-webview/Android.bp`. The file defines the `webview` module and was missing from the working tree, so kati aborted with `non-existent modules in PRODUCT_PACKAGES`
- `packages/apps/DolbyAtmos` moved to the symlink `.git` layout used by the rest of the tree, and is pinned to `raebaexxx/android_packages_apps_DolbyAtmos` @ `bp4a` via `.repo/local_manifests/dolby.xml`. The manifest previously pointed at PixelOS-AOSP, which caused every `repo sync` to overwrite the local Dolby changes

---

## Retained customisations

- `parts/` — `com.xiaomi.settings` overlay app: Auto HBM tiles, thermal profiles, clear speaker (58 files)
- `XiaomiParts`, `DSPVolumeSynchronizer`, Dolby Atmos via `sm8550-common-dolby`
- eSIM hooking blobs
- `lineage.dependencies` removed (local kernel sources)

---

## Reverted

The following were briefly applied and then reverted, so the vendor blobs are byte for byte identical to upstream `lineage-24.0`:

- `odm/etc/audio/misound_res_headphone.bin` (87,044 B) and `misound_res_spk.bin` (106,268 B) — acoustic tuning
- `odm/etc/media_profiles_kalama.xml` — 11 camera encoder profiles (`cameraId` 0–10) instead of 6 (0, 1, 2, 3, 4, 7)
- `odm/etc/libnfc-nxp.conf` — `NXP_T4T_NFCEE_ENABLE` and `NXP_RDR_DISABLE_ENABLE_LPCD`

---

## Repositories

| Repository | Branch | Commit |
|---|---|---|
| `device/xiaomi/sm8550-common` | `pixelos_a17` | `e7cd4ca` |
| `vendor/xiaomi/sm8550-common` | `a24_24.0` | `bac893a` |
| `device/xiaomi/sm8550-common-dolby` | `bp4a` | `58bae26` |
| `packages/apps/DolbyAtmos` | `bp4a` | `a2112a2` |
