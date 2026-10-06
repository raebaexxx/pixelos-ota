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

`publish.sh` does the whole job: it checks the package and the URL, integrates remote work into the
feed branch, generates the entry with the official generator, merges it into the feed, validates,
commits and pushes. The manual steps further down are what it runs, for when you prefer to drive
them yourself.

### 1. Build and upload

```bash
export IS_OFFICIAL=true
. b*/env*
breakfast fuxi user
m pixelos -j$(nproc)
```

Take the release name from the build output, `Package Complete:
out/target/product/fuxi/PixelOS_fuxi-<version>.zip`, and upload exactly that file. The name in the
URL must match the upload character for character.

The build must use release keys. Check with `getprop ro.build.tags` on the device, it has to read
`release-keys`; see `vendor/lineage-priv/keys/keys.mk`. A build signed with the default AOSP test
keys is accepted by a recovery built from the same source, so the mismatch only surfaces on devices
whose recovery came from an older release.

### 2. Publish

```bash
./publish.sh \
  ~/roms/pixelos/out/target/product/fuxi/custom_fuxi-ota.zip \
  "https://downloads.sourceforge.net/project/rbxfuxiroms/PixelOS/Android%2017/06.10.2026-2/PixelOS_fuxi-17.0-20261006-2004.zip" \
  --no-changelog --keep 1
```

| flag | default | effect |
|---|---|---|
| `--version X.Y` | `17.0` | `version` field of the generated entry |
| `--keep N` | `5` | how many entries the merged feed keeps, newest first |
| `--changelog PATH` | newest `$ROM_TREE/changelog_*.md` | copies that file over `API/updater/changelogs/fuxi.md` |
| `--no-changelog` | off | leaves the changelog alone |
| `--skip-url-check` | off | skips the URL probe, see below |

Environment overrides: `FEED_REPO`, `FEED_BRANCH`, `ROM_TREE`, `GIT_NAME`, `GIT_EMAIL`.

`--changelog` takes a path, not text. The changelog the app shows is the whole file rather than a
per-build section, so it is edited in place between releases.

The URL is fetched with a HEAD request before anything is published, and the run aborts on a 404, on
an unexpected status, or when the file at that URL is a different size than the local package. The
size case is the one that bites: the name looks right, but an older build is sitting under it. A
wrong name or path used to publish cleanly and only fail later, in the app, at download time.

SourceForge takes a moment to propagate a new upload. If the probe 404s on a file you just
uploaded, wait and retry, or pass `--skip-url-check` once.

### 3. Incremental updates

Deltas need the target-files of both builds, which `m pixelos` alone does not produce:

```bash
m updatepackage pixelos
ota_from_target_files -v \
  -k vendor/lineage-priv/keys/releasekey \
  -i ~/releases/fuxi/<old>/custom_fuxi-img.zip \
     ~/releases/fuxi/<new>/custom_fuxi-img.zip \
     ~/releases/fuxi/<new>/incremental.zip
```

Keep the target-files of every release, a delta is only valid from the exact build it was made
against. Note that delta installation fails on rooted devices by design, so testers on KernelSU or
Magisk get the full package.

### Manual steps

```bash
cd ~/roms/pixelos/packages/apps/Updater
python3 tools/pixelos_feed.py generate-ota \
  /path/to/PixelOS_fuxi-17.0-<date>.zip \
  --url "https://downloads.sourceforge.net/project/rbxfuxiroms/<path>/<file>.zip" \
  --version 17.0 \
  --output API/updater/fuxi.json

python3 tools/pixelos_feed.py validate-ota API/updater/fuxi.json \
  --artifact /path/to/PixelOS_fuxi-17.0-<date>.zip
```

The generator computes `sha256`, `size`, `os_patch_level`, `os_sdk_level` and `ota_property_files`
from the package itself. Then merge the entry into the existing feed, write the changelog into
`API/updater/changelogs/fuxi.md`, commit and push. Nothing on this path checks that the URL
resolves, so that part is on you.

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
