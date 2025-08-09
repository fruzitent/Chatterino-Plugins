#!/bin/bash
set -e

repo="${GITHUB_REPOSITORY}"

for file in dist/*.zip; do
  filename=$(basename "$file")
  tag="${filename%.zip}"

  echo "Checking if release with tag '$tag' exists..."

  release_check=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$repo/releases/tags/$tag")

  if echo "$release_check" | grep -q '"message": "Not Found"'; then
    echo "Release with tag '$tag' does not exist. Creating release..."

    release_response=$(curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"tag_name\":\"$tag\", \"name\":\"$tag\", \"draft\":false, \"prerelease\":false}" \
      "https://api.github.com/repos/$repo/releases")

    upload_url=$(echo "$release_response" | grep -oP '"upload_url":\s*"\K[^"]+' | sed 's/{?name,label}//')

    if [ -z "$upload_url" ]; then
      echo "Failed to create release for tag $tag"
      exit 1
    fi

    echo "Uploading asset $filename"
    curl -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Content-Type: application/zip" \
      --data-binary @"$file" \
      "$upload_url?name=$filename"

  else
    echo "Release with tag '$tag' already exists. Failing the job."
    continue
  fi

done
