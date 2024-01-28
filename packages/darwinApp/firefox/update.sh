#!/usr/bin/env bash
#
# shellcheck shell=bash
# copy from https://github.com/bandithedoge/nixpkgs-firefox-darwin/blob/main/update.sh
BASE_URL="https://download-installer.cdn.mozilla.net/pub"
SCRIPT_PATH=$(dirname "$0")

function get_version() {
    curl -s "https://product-details.mozilla.org/1.0/firefox_versions.json" |
        case $1 in
        firefox)
            jq -r '.LATEST_FIREFOX_VERSION'
            ;;
        firefox-esr)
            jq -r '.FIREFOX_ESR'
            ;;
        esac
}

# function get_path() { echo "firefox/releases/$(get_version "$1")"; }

# function get_url() { echo "$BASE_URL/$(get_path "$1")/mac/en-US/Firefox%20$(get_version "$1").dmg"; }

# function get_sha256() {
#     curl -s "$BASE_URL/$(get_path "$1")/SHA256SUMS" | grep "mac/en-US/Firefox $(get_version "$1").dmg" |
#         awk '{print $1}'
# }

# function generate_json() {
#     jq -n \
#         --arg version "$(get_version $1)" \
#         --arg url "$(get_url $1)" \
#         --arg sha256 "$(get_sha256 $1)" \
#         '{version: $version, url: $url, sha256: $sha256}'
# }


function generate_json() {
    local version=$(get_version "$1")
    local path="firefox/releases/$version"
    local url="$BASE_URL/${path}/mac/en-US/Firefox%20$version.dmg"
    local sha256=$(curl -s "$BASE_URL/$path/SHA256SUMS" | grep "mac/en-US/Firefox $version.dmg" | awk '{print $1}')
    jq -n \
        --arg version "$version" \
        --arg url "$url" \
        --arg sha256 "$sha256" \
        '{version: $version, url: $url, sha256: $sha256}'
}

function main() {
    local json=$(
        cat <<EOF
{
   "firefox": $(generate_json "firefox"),
   "firefox-esr":$(generate_json "firefox-esr")
}
EOF
    )

    echo "$json" | jq . >${SCRIPT_PATH}/source.json
}

main
