#!/bin/bash
# Publish a fresh TikTok domain-verification token.
#
#   ./publish-token.sh
#
# TikTok issues a new token every time the URL prefix changes, and the old one
# stops counting. This picks up any tiktok*.txt sitting in ~/Downloads, pushes
# it to GitHub Pages, and waits until it is actually reachable before saying so.
set -e
cd "$(dirname "$0")"
found=0
for f in "$HOME"/Downloads/tiktok*.txt; do
  [ -e "$f" ] || continue
  cp "$f" . && echo "  staged $(basename "$f")" && found=1
done
[ "$found" = 0 ] && { echo "No tiktok*.txt in ~/Downloads."; exit 1; }
git add -A
git -c user.email="sadramohajer@gmail.com" -c user.name="Sadra Mohajer" \
    commit -qm "Add TikTok verification token" || { echo "Nothing new to publish."; exit 0; }
git push -q origin main
echo "  pushed — waiting for GitHub Pages…"
for f in tiktok*.txt; do
  url="https://sadrasupply.github.io/$f"
  for i in $(seq 1 24); do
    sleep 10
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    [ "$code" = "200" ] && { echo "  LIVE  $url"; break; }
    [ "$i" = 24 ] && echo "  still $code — try again shortly: $url"
  done
done
