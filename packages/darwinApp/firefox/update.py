import json
import os
import re
import subprocess
import sys
from typing import List

import requests

# copy from https://github.com/bandithedoge/nixpkgs-firefox-darwin/blob/main/update.sh

SCRIPT_DIR = os.path.dirname(os.path.relpath(__file__))


def nth(idx, lst):
    if idx >= len(lst):
        return None
    else:
        return lst[idx]


def commit_source(msg):
    current_dir = os.getcwd()
    os.chdir(SCRIPT_DIR)
    for i in ["sources.json", "source.json"]:
        if os.path.isfile(i):
            subprocess.run("git add ./{i}", shell=True)
    subprocess.run(f"git commit -m '{msg}'", shell=True)
    os.chdir(current_dir)


def get_current_src(f):
    if os.path.isfile(f):
        with open(f, encoding="utf-8", mode="r") as text:
            return json.load(text)
    else:
        return {}


def save_current_src(f, sources):
    with open(f, encoding="utf-8", mode="w") as text:
        json.dump(sources, text, indent=2)


def get_version() -> List:
    resp = requests.get(
        "https://product-details.mozilla.org/1.0/firefox_versions.json"
    ).json()
    return {
        "firefox": resp["LATEST_FIREFOX_VERSION"],
        "firefox-esr": resp["FIREFOX_ESR"],
    }


def get_hash(version="124.0.1"):
    url = f"https://download-installer.cdn.mozilla.net/pub/firefox/releases/{version}/SHA256SUMS"
    resp = requests.get(url).text
    re_pattern = re.search(rf"(.*) +mac\/en-US\/Firefox {version}.dmg", resp)
    return re_pattern.group(1) if re_pattern is not None else None


def get_dict(version) -> dict[str, str]:
    url = f"https://download-installer.cdn.mozilla.net/pub/mac/en-US/Firefox%20{version}.dmg"
    sha256 = get_hash(version)
    if sha256 is not None:
        return {"url": url, "sha256": sha256, "version": version}


def main():
    source_file = os.path.join(SCRIPT_DIR, "sources.json")
    latest_info = get_current_src(source_file)
    next_version_info = get_version()
    next_infos = {}
    update_msg_list = []
    for i in ["firefox-esr", "firefox"]:
        last_i = latest_info.get(i) if latest_info.get(i) else None
        if last_i is None or next_version_info[i] != last_i["version"]:
            i_info = get_dict(next_version_info[i])
            if i_info:
                current_version = last_i["version"] if last_i else "∅"
                next_infos[i] = i_info
                update_msg_list.append(f"{i}: {current_version} -> {i_info['version']}")
        else:
            next_infos[i] = latest_info[i]
    if update_msg_list:
        save_current_src(source_file, next_infos)
        if nth(1, sys.argv):
            msg = (
                f"Update {update_msg_list[0]}"
                if len(update_msg_list) == 1
                else "Update\n" + "\n".join(update_msg_list)
            )
            print(msg)


if __name__ == "__main__":
    main()
