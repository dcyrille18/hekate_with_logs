#!/bin/sh
# Packages the build output like an upstream hekate release.
# Prebuilt resources not produced by this repo (res.pak, emummc.kipm, l4t/, thk.bin, icons)
# are taken from the upstream release zip. Set BASE_ZIP to use a local zip instead.
set -eu

cd "$(dirname "$0")/.."

ver() { sed -n "s/^$1 *:= *\([0-9]*\).*/\1/p" Versions.inc; }
HEKATE_VER="$(ver BLVERSION_MAJOR).$(ver BLVERSION_MINOR).$(ver BLVERSION_HOTFX)"
NYX_VER="$(ver NYXVERSION_MAJOR).$(ver NYXVERSION_MINOR).$(ver NYXVERSION_HOTFX)"

OUT=output
DIST=build/release
ZIP="hekate_ctcaer_${HEKATE_VER}_Nyx_${NYX_VER}.zip"

for f in hekate.bin nyx.bin libsys_lp0.bso libsys_minerva.bso; do
	[ -f "$OUT/$f" ] || { echo "Missing $OUT/$f. Run make first." >&2; exit 1; }
done

if [ -z "${BASE_ZIP:-}" ]; then
	BASE_ZIP=build/upstream.zip
	URL="$(curl -fsSL https://api.github.com/repos/CTCaer/hekate/releases/latest \
		| sed -n 's/.*"browser_download_url": *"\([^"]*_Nyx_[^"]*\.zip\)".*/\1/p' | head -n1)"
	[ -n "$URL" ] || { echo "Could not find upstream release zip." >&2; exit 1; }
	curl -fsSL -o "$BASE_ZIP" "$URL"
fi

rm -rf "$DIST"
mkdir -p "$DIST"
unzip -q "$BASE_ZIP" -d "$DIST"

# Drop upstream binaries built from this repo.
rm -f "$DIST"/hekate_ctcaer_*.bin
cp "$OUT/hekate.bin"          "$DIST/payload.bin"
cp "$OUT/hekate.bin"          "$DIST/bootloader/update.bin"
cp "$OUT/nyx.bin"             "$DIST/bootloader/sys/nyx.bin"
cp "$OUT/libsys_lp0.bso"      "$DIST/bootloader/sys/libsys_lp0.bso"
cp "$OUT/libsys_minerva.bso"  "$DIST/bootloader/sys/libsys_minerva.bso"

rm -f "$OUT/$ZIP"
(cd "$DIST" && zip -qr "$OLDPWD/$OUT/$ZIP" .)

echo "Created $OUT/$ZIP"
