#!/usr/bin/env bash

set -euox pipefail

ZSH_EAGER=1 zsh -i -c $'
nvim --headless "+Lazy! restore" +qa
nvim --headless "+MasonUpdate" +qa
nvim --headless "+MasonLockRestore" +qa'

# Blink download
BLINK_PATH=~/.local/share/nvim/lazy/blink.cmp/target/release
mkdir -p "$BLINK_PATH"
cd "$BLINK_PATH"

VERSION=$(git describe --tags --abbrev)
case "$(uname)" in
Linux) EXT=".so" ;;
Darwin) EXT=".dylib" ;;
*) EXT=".dll" ;;
esac
ASSET="$(rustc --print host-tuple)"
NAME="libblink_cmp_fuzzy${EXT}"

curl -sLo "${NAME}" "https://github.com/Saghen/blink.cmp/releases/download/${VERSION}/${ASSET}${EXT}"
curl -sLo "${NAME}.sha256" "https://github.com/Saghen/blink.cmp/releases/download/${VERSION}/${ASSET}${EXT}.sha256"

mkdir -p "${ASSET}"
cp "${NAME}" "${ASSET}/${ASSET}${EXT}"
sha256sum -c "${NAME}.sha256"
rm "${ASSET}/${ASSET}${EXT}"
echo -n "${VERSION}" >version
