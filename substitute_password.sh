#!/bin/zsh

# Check if the environment variable is set
if [ -z "$NAS_PASSWORD" ]; then
  echo "Error: NAS_PASSWORD environment variable is not set."
  exit 1
fi

# Substitute the placeholder with the environment variable
sed -i '' "s/PLACEHOLDER_PASSWORD/$NAS_PASSWORD/" containers/plex/media-nas.mount
