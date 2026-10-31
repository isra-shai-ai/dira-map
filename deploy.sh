#!/usr/bin/env bash
# Redeploy the map to GitHub Pages (repo isra-shai-ai/dira-map). Needs env GITHUB_DIRA_MAP_TOKEN (fine-grained, this repo only).
set -euo pipefail
cd "$(dirname "$0")"
python3 -c "import json;json.load(open('listings.json'))"   # validate JSON before publishing
git add -A
git -c user.name="dira-map" -c user.email="dira-map@users.noreply.github.com" commit -qm "update $(date '+%Y-%m-%d %H:%M')" || echo "nothing to commit"
git -c credential.helper= push -q "https://x-access-token:${GITHUB_DIRA_MAP_TOKEN}@github.com/isra-shai-ai/dira-map.git" main 2>&1 | sed 's/x-access-token:[^@]*@/***@/'
echo "URL: https://isra-shai-ai.github.io/dira-map/"
