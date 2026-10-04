#!/bin/bash
#
# Publish a PixelOS OTA update for fuxi.
#
#   1. verifies the OTA package and the Updater tooling
#   2. generates the feed entry with the official generator
#   3. merges it into the existing feed (newest first, keeps history)
#   4. validates the result
#   5. commits and pushes
#
# Usage:
#   ./publish.sh <ota-zip> <sourceforge-url> [--version 17.0]
#
# Example:
#   ./publish.sh \
#     ~/roms/pixelos/out/target/product/fuxi/custom_fuxi-ota.zip \
#     "https://downloads.sourceforge.net/project/rbxfuxiroms/PixelOS/Android%2017/04.10.2026/PixelOS_fuxi-17.0-20261004-0053.zip"
#
set -euo pipefail

FEED_REPO="${FEED_REPO:-$HOME/roms/pixelos-ota}"
FEED_BRANCH="${FEED_BRANCH:-seventeen}"
FEED_PATH="API/updater/fuxi.json"
FEED_CL="API/updater/changelogs/fuxi.md"
GENERATOR="$HOME/roms/pixelos/packages/apps/Updater/tools/pixelos_feed.py"
VERSION="17.0"
KEEP_HISTORY=5
ROM_TREE="${ROM_TREE:-$HOME/roms/pixelos}"

die() { echo "Error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# ---- arguments -------------------------------------------------------------
[ $# -ge 2 ] || die "usage: $0 <ota-zip> <sourceforge-url> [--version X.Y]"

OTA_ZIP="$1"; SF_URL="$2"
shift 2
while [ $# -gt 0 ]; do
    case "$1" in
        --version) VERSION="$2"; shift 2 ;;
        --keep)    KEEP_HISTORY="$2"; shift 2 ;;
        --changelog) CHANGELOG_SRC="$2"; shift 2 ;;
        --no-changelog) SKIP_CHANGELOG=1; shift ;;
        *) die "unknown option: $1" ;;
    esac
done

# ---- checks ----------------------------------------------------------------
[ -f "$OTA_ZIP" ]   || die "OTA package not found: $OTA_ZIP"
[ -f "$GENERATOR" ] || die "generator not found: $GENERATOR"
[ -d "$FEED_REPO/.git" ] || die "feed repo not found: $FEED_REPO"

case "$SF_URL" in
    https://*) ;;
    *) die "the URL must be HTTPS (enforced by the Updater)" ;;
esac

info "feed repo   : $FEED_REPO ($FEED_BRANCH)"
info "ota package : $OTA_ZIP ($(du -h "$OTA_ZIP" | cut -f1))"
info "public url  : $SF_URL"

# ---- changelog -------------------------------------------------------------
# The Updater resolves the changelog from {branch}/{device} only, with no
# per-build selector, so every entry in the feed points at the same file.
# Publish whichever release notes belong to the newest build and keep them
# in sync with the feed.
if [ -z "${SKIP_CHANGELOG:-}" ]; then
    if [ -z "${CHANGELOG_SRC:-}" ]; then
        CHANGELOG_SRC="$(ls -t "$ROM_TREE"/changelog_*.md 2>/dev/null | head -1 || true)"
    fi
    if [ -n "${CHANGELOG_SRC:-}" ] && [ -f "$CHANGELOG_SRC" ]; then
        mkdir -p "$(dirname "$FEED_REPO/$FEED_CL")"
        cp "$CHANGELOG_SRC" "$FEED_REPO/$FEED_CL"
        info "changelog   : $(basename "$CHANGELOG_SRC") -> $FEED_CL ($(wc -c < "$FEED_REPO/$FEED_CL") bytes)"
    else
        info "changelog   : not updated, none found under $ROM_TREE/changelog_*.md"
    fi
else
    info "changelog   : skipped (--no-changelog)"
fi

# ---- pretty filename -------------------------------------------------------
# The generator copies the local archive name into "filename", which is what
# the user sees in the app. Present the package under the real release name
# via a symlink so we do not copy 3.4 GB around.
DISPLAY_NAME="$(basename "$SF_URL")"
TMP_LINK_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_LINK_DIR"' EXIT
ln -s "$(readlink -f "$OTA_ZIP")" "$TMP_LINK_DIR/$DISPLAY_NAME"

# ---- generate --------------------------------------------------------------
info "generating feed entry"
python3 "$GENERATOR" generate-ota \
    "$TMP_LINK_DIR/$DISPLAY_NAME" \
    --url "$SF_URL" \
    --version "$VERSION" \
    --output "$TMP_LINK_DIR/new.json"

[ -f "$TMP_LINK_DIR/new.json" ] || die "generator produced no output"

# ---- merge into the feed ---------------------------------------------------
info "merging into $FEED_PATH"
python3 - "$FEED_REPO/$FEED_PATH" "$TMP_LINK_DIR/new.json" "$KEEP_HISTORY" <<'PY'
import json, sys

feed_path, new_path, keep = sys.argv[1], sys.argv[2], int(sys.argv[3])

try:
    current = json.load(open(feed_path))
    if not isinstance(current, list):
        current = []
except (FileNotFoundError, json.JSONDecodeError):
    current = []

new = json.load(open(new_path))
if not isinstance(new, list) or len(new) != 1:
    sys.exit("generated feed entry is not a single-element array")

entry = new[0]
digest = entry["files"][0]["sha256"]
display = entry["files"][0]["filename"]

# Drop any previous entry for the same artifact. Match on filename as well as
# digest: repackaging the same build produces a new sha256 and a slightly
# different size, and leaving both in the feed would advertise two different
# packages under the same name.
current = [
    e for e in current
    if e.get("files", [{}])[0].get("sha256") != digest
    and e.get("files", [{}])[0].get("filename") != display
]
current.insert(0, entry)
current = current[:keep]

json.dump(current, open(feed_path, "w"), indent=2)
open(feed_path, "a").write("\n")

print(f"    entries in feed: {len(current)}")
for e in current:
    print(f"      {e['files'][0]['filename']}  ({e['files'][0]['size']} bytes)")
PY

# ---- validate --------------------------------------------------------------
info "validating"
# The official checker compares a single feed entry against the artifact and
# refuses a feed holding several, so validate the freshly generated entry in
# isolation and check the merged feed separately below.
python3 "$GENERATOR" validate-ota "$TMP_LINK_DIR/new.json" --artifact "$TMP_LINK_DIR/$DISPLAY_NAME"

info "validating JSON shape"
python3 - "$FEED_REPO/$FEED_PATH" <<'PY'
import json, re, sys
feed = json.load(open(sys.argv[1]))
assert isinstance(feed, list), "feed must be a JSON array"
for e in feed:
    assert len(e["files"]) == 1, "each entry must carry exactly one file"
    f = e["files"][0]
    assert re.fullmatch(r"[0-9a-f]{64}", f["sha256"]), "sha256 must be lowercase hex"
    assert f["url"].startswith("https://"), "url must be HTTPS"
    assert e["datetime"] > 0 and e["version"], "datetime and version are required"
print("    ok")
PY

# ---- commit and push -------------------------------------------------------
cd "$FEED_REPO"
git checkout -q "$FEED_BRANCH"
git add -A

if git diff --cached --quiet; then
    info "nothing to publish, feed already up to date"
    exit 0
fi

STAMP="$(date -u "+%Y-%m-%d %H:%M UTC")"
git -c user.name="${GIT_NAME:-raebaexxx}" \
    -c user.email="${GIT_EMAIL:-vadimfeda@yandex.ru}" \
    commit -q -m "Publish OTA feed entry ${DISPLAY_NAME}

Generated with tools/pixelos_feed.py and validated against the
package. Published ${STAMP}."

info "pushing"
git push -q origin "$FEED_BRANCH"

info "done: https://github.com/$(git config --get remote.origin.url | sed 's|.*github.com/||; s|\.git$||')/blob/$FEED_BRANCH/$FEED_PATH"
git log --oneline -1
