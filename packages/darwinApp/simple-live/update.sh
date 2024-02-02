#!/usr/bin/env bash
# shellcheck shell=bash

SCRIPT_PATH=$(dirname "$0")
repo_name="xiaoyaocz/dart_simple_live"
TMP_JSON=$(mktemp -t source.XXXXXX.json)
curl -s https://api.github.com/repos/${repo_name}/releases/latest > $TMP_JSON
VERSION=$(jq -r .name $TMP_JSON)
URL=$(cat $TMP_JSON | grep browser_download_url | grep macos\.dmg | awk -F '"' '{ print $(NF-1) }' | sed 's/%2B/+/g')
function get_hash { nix-prefetch-url $1 --name "simple_live_app_$VERSION.dmg" | head -n 1 ; }

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
    "simpleLive": $(generate_json "$URL" "$version")
}
EOF
          )
    echo "$json" | jq . >${SCRIPT_PATH}/source.json
}
if [[ ! -f "${SCRIPT_PATH}/source.json" ]] ||
       [[ $(jq -r '.simpleLive.version' "${SCRIPT_PATH}"/source.json) != "$VERSION" ]]; then
    main
fi
[[ -f $TMP_JSON ]] && rm -rf $TMP_JSON
