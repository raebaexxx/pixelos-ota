# Install PixelOS on Xiaomi 13 Ultra (fuxi)

Device codename: `fuxi` (Xiaomi 13 Ultra / Redmi K60 Pro)

## Clean flash

1. `fastboot flash boot boot.img`
2. `fastboot flash vendor_boot vendor_boot.img`
3. Reboot to recovery
4. Sideload the PixelOS zip
5. Format data
6. Reboot

## Dirty flash

1. Sideload the PixelOS zip from recovery
2. Reboot system

## OTA update

1. Open Updater
2. Download and install
3. Reboot
