#!/bin/bash
mkdir -p dist
for i in */; do
  [ "$i" = "dist/" ] && continue

  if [ ! -f "$i/info.json" ]; then
    echo "Error: $i/info.json not found."
    exit 1
  fi

  version=$(grep -Po '"version"\s*:\s*"\K[^"]+' "$i/info.json")

  if [ -z "$version" ]; then
    echo "Error: version not found in $i/info.json"
    exit 1
  fi

  version="${version//./_}"

  git ls-files --cached --others --exclude-standard "$i" | zip "dist/${i%/}_v${version}.zip" -@
done
