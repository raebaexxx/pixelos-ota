# pixelos-ota

OTA feed and changelogs for **PixelOS on Xiaomi 13 (fuxi)**.

Consumed by the PixelOS Updater app (`net.pixelos.ota`). The app builds its URLs from two
resources in `packages/apps/Updater/app/src/main/res/values/strings.xml`, which in this fork
point here:

```text
https://raw.githubusercontent.com/raebaexxx/pixelos-ota/{branch}/API/updater/{device}.json
https://raw.githubusercontent.com/raebaexxx/pixelos-ota/{branch}/API/updater/changelogs/{device}.md
```

`{branch}` resolves to `net.pixelos.version` (`seventeen`) and `{device}` to `ro.custom.device`
(`fuxi`), both defined in `vendor/custom/config/version.mk`.

## Layout

```text
API/updater/fuxi.json              update feed
API/updater/changelogs/fuxi.md     changelog shown inside Updater
API/instructions/fuxi.md           flash instructions for the website
```

## Publishing a build

The ZIP files live on SourceForge. Only the JSON feed is served from here, because the Updater
builds its HTTP client with `followRedirects(false)` — a 302 from SourceForge to a mirror would
fail the fetch with `Unexpected HTTP status: 302`.

1. Build and upload the OTA package:

   ```bash
   export IS_OFFICIAL=true
   m otapackage
   # upload out/target/product/custom_fuxi/ota_package/*.zip to SourceForge
   ```

2. Generate the feed entry from the uploaded artifact:

   ```bash
   cd ~/roms/pixelos/packages/apps/Updater
   python3 tools/pixelos_feed.py generate-ota \
     /path/to/PixelOS_fuxi-17.0-<date>.zip \
     --url "https://downloads.sourceforge.net/project/rbxfuxiroms/<path>/<file>.zip" \
     --version 17.0 \
     --output API/updater/fuxi.json
   ```

   The generator computes `sha256`, `size`, `os_patch_level`, `os_sdk_level` and
   `ota_property_files` from the package itself.

3. Validate before committing:

   ```bash
   python3 tools/pixelos_feed.py validate-ota API/updater/fuxi.json \
     --artifact /path/to/PixelOS_fuxi-17.0-<date>.zip
   ```

4. Write the changelog into `API/updater/changelogs/fuxi.md`, then commit and push.

## Feed schema

The Updater is strict: the response is a plain JSON array, the legacy `response` wrapper and its
`id`, `stream_url`, `stream` and `payload` fields are rejected.

```json
[
  {
    "datetime": 1789949327,
    "files": [
      {
        "filename": "PixelOS_fuxi-17.0-20261003-1348.zip",
        "os_patch_level": "2026-08-01",
        "os_sdk_level": 37,
        "ota_property_files": "payload_metadata.bin:4059:174047,payload.bin:4059:2561477021,payload_properties.txt:2561481138:156",
        "sha256": "42453589bfe6e68ac4dd24820e50d1c9319f56b2492c1f910153d8017db977db",
        "size": 2561484259,
        "url": "https://downloads.sourceforge.net/project/rbxfuxiroms/.../PixelOS_fuxi-17.0-20261003-1348.zip"
      }
    ],
    "type": "ci",
    "version": "17.0"
  }
]
```

Exactly one entry in `files`, `sha256` must be 64 lowercase hex characters, `url` must be HTTPS,
and `datetime` must be newer than `ro.build.date.utc` of the installed build or the update is
rejected as older.

## Incremental updates

Add an `incremental` array with a single file of the same shape. The app tries the delta first on
A/B devices and falls back to the full package automatically.
