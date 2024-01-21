#!/usr/bin/env bash
# shellcheck shell=bash
function tr_quote() { echo "$@" | tr -d '"'; }

SCRIPT_PATH=$(dirname "\$0")
IS_LOCAL=${IS_LOCAL:-false}
IS_TMPDIR=${IS_TMPDIR:-true}
repo_name="Cirn09/calibre-do-not-translate-my-path"
VERSION=$(tr_quote "$(curl -s https://api.github.com/repos/${repo_name}/releases/latest  | jq '.tag_name')")

function download() {
    local tmpdir=$SCRIPT_PATH
    if [[ "$IS_TMPDIR" == "true" ]]; then
        tmpdir=$(mktemp -d)
    fi
    local file=$(basename "$1")
    if [[ -f "$tmpdir/$file" ]]; then
        echo "$tmpdir/$file"
        return 0
    fi
    if wget -q -O "$tmpdir/$file" "$1"; then
        echo "$tmpdir/$file"
    fi
}

function get_hash() {
    local file=$(download "$1")
    local hash=1
    if [[ -f $file ]]; then
        hash=$(nix-hash --flat --base32 --type sha256 --sri $file)
        if [[ $IS_LOCAL == "true" ]]; then
            nix-store --add $file >/dev/null 2>&1
        fi
    fi
    if [[ "$IS_TMPDIR" == "true" ]]; then
        rm -rf $(dirname "\$file")
    fi
    if  [[ $hash != 1 ]]; then
        echo $hash
    fi
}

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
    "calibrepath": $(generate_json "https://github.com/Cirn09/calibre-do-not-translate-my-path/releases/download/${VERSION}/mac-patch-backend+update-${VERSION}.zip"),
    "calibre": $(generate_json "https://download.calibre-ebook.com/${version}/calibre-${version}.dmg" "$version")
}
EOF
          )
    echo "$json" | jq . >${SCRIPT_PATH}/source.json
}
if [[ ! -f "${SCRIPT_PATH}/source.json" ]] ||
       [[ $(tr_quote "$(jq '.calibrepath.version' "${SCRIPT_PATH}"/source.json)") != "$VERSION" ]]; then
    main
fi
