#!/usr/bin/env bash
set -euo pipefail

dest="${1:-$HOME/dotfiles/.claude/skills}"

release_url=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/obra/superpowers/releases/latest")
tag="${release_url##*/}"
echo "Latest release: $tag"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "https://github.com/obra/superpowers/archive/refs/tags/$tag.tar.gz" | tar -xz -C "$tmp" --strip-components=1

for src in "$tmp"/skills/*/; do
    name=$(basename "$src")
    rm -rf "${dest:?}/$name"
    cp -r "$src" "$dest/$name"

    skill="$dest/$name/SKILL.md"
    [[ -f "$skill" ]] || continue
    awk -v author="author: $release_url" '
        NR == 1 && $0 == "---" { infm = 1; print; next }
        infm && /^author:/ { next }
        infm && $0 == "---" { print author; infm = 0 }
        { print }
    ' "$skill" >"$skill.tmp"
    mv "$skill.tmp" "$skill"
    echo "Updated $name"
done
