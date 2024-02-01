#!/usr/bin/env bash
# shellcheck shell=bash

SCRIPT_PATH=$(dirname "$0")
repo_name="RPCS3/rpcs3-binaries-mac"
TEXT=$(curl -s https://api.github.com/repos/${repo_name}/releases/latest)
URL=$(echo -n $TEXT | jq  | grep browser_download_url | grep macos  | awk -F '"' '{ print $(NF-1) }')
VERSION=$(echo -n $TEXT | jq -r .name)

function get_hash() { nix-prefetch-url  $1 | head -n 1 ; }

function generate_json() {
    local url=$1
    local version=${2:-$VERSION}
    local sha256=$(get_hash "$url")
    jq -n \
        --arg version "$version" \
        --arg url "$url" \
        --arg sha256 "$sha256" \
        '{version: $version, url: $url, sha256: $sha256}'
}

function main() {
    local version=$VERSION
    if [[ $version == v* ]]; then
        version=${version:1}
    fi
    local json=$(
        cat <<EOF
{
    "rpcs3": $(generate_json "$URL" "$version")
}
EOF
          )
    echo "$json" | jq . >${SCRIPT_PATH}/source.json
}
if [[ ! -f "${SCRIPT_PATH}/source.json" ]] ||
       [[ $(jq -r '.rpcs3.version' "${SCRIPT_PATH}"/source.json) != "$VERSION" ]]; then
    main
fi
