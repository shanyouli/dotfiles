#!/usr/bin/env bash
# shellcheck shell=bash

SCRIPT_PATH=$(dirname "$0")
repo_name="odomu/aliyunpan"
VERSION=$(curl -s https://api.github.com/repos/${repo_name}/releases/latest | jq -r .tag_name)
NAME="xbydriver"

if [[ $VERSION == v* ]]; then
    VERSION=${VERSION:1}
fi

function get_hash() { nix-prefetch-url "$1" | head -n 1 ; }

function generate_json() {
    local url=$1
    local version=${2:-$VERSION}
    local sha256
    sha256=$(get_hash "$url")
    jq -n \
        --arg version "$version" \
        --arg url "$url" \
        --arg sha256 "$sha256" \
        '{version: $version, url: $url, sha256: $sha256}'
}

function main() {
    local url="https://github.com/odomu/aliyunpan/releases/download/v$VERSION/alixby-$VERSION-mac-arm64.dmg"
    local json
    json=$(
        cat <<EOF
{
    "${NAME}": $(generate_json "$url" "$version")
}
EOF
          )
    echo "$json" | jq . > "${SCRIPT_PATH}/source.json"
}

function get_old_version() {
    if [[ ! -f "${SCRIPT_PATH}/source.json" ]]; then
        echo "0"
    else
        jq -r .${NAME}.version "${SCRIPT_PATH}"/source.json
    fi
}
OLD_VERSION=get_old_version
if [[ "$OLD_VERSION" != "$VERSION" ]]; then
    echo "update ${SCRIPT_PATH}/source.json"
    main
    if [[ -n $1 ]]; then
        pushd "${SCRIPT_PATH}" || return
        git add ./source.json
        git commit -m "${NAME} ${OLD_VERSION} --> ${VERSION}"
        popd || return
    fi
fi
