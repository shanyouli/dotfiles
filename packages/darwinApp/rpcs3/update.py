import requests
import os
import json
import re
import subprocess
import sys
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
            subprocess.run(f"git add ./{i}", shell=True)
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

def get_hash(url: str) -> str:
    result = subprocess.run(["nix-prefetch-url", url], stdout=subprocess.PIPE)
    if result.returncode != 0:
        raise RuntimeError(
            "nix-prefetch-url exited with error {}".format(result.returncode)
        )
    return result.stdout.decode("utf-8").strip()

def get_repos_latest_info(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    gtoken = os.getenv("MY_GITHU_TOKEN")
    header = {'Authorization': f"token {gtoken}"} if gtoken else None
    return requests.get(url, headers=header).json()

def get_version(s, k="tag_name", rex=r"v(.*)"):
    ver = s.get(k)
    if not ver and k != "tag_name":
        ver = s["tag_name"]
    if ver:
        re_pattern = re.search(rex, ver)
        return re_pattern.group(1) if re_pattern is not None else ver
    else:
        print("Error: version keyword not found, The id will be used instead of")
        return s['id']

def get_url(s, ext, rex):
    for i in s.get("assets"):
        i_name = i.get("name")
        if i_name.endswith(ext) and re.match(rex, i_name):
            return i.get("browser_download_url")

def main(owner, repo, pname, ver_key="tag_name", ver_regx=r"v(.*)", ext=".dmg", url_regx=".*mac.+arm64"):
    info = get_repos_latest_info(owner, repo)
    source_file = os.path.join(SCRIPT_DIR, "source.json")
    latest_info = get_current_src(source_file)
    version = get_version(info, ver_key, ver_regx)
    next_source = {}
    if latest_info is None or latest_info[pname]["version"] != version:
        url = get_url(info, ext, url_regx)
        cversion = latest_info[pname]["version"] if latest_info else "∅"
        next_source = {
            pname : {
                'version': version,
                'url': url,
                'sha256': get_hash(url)
            }
        }
        save_current_src(source_file, next_source)
        if nth(1, sys.argv):
            commit_source(f"Update {pname} {cversion} -> {version}")

if __name__ == '__main__':
    main("RPCS3", "rpcs3-binaries-mac", "rpcs3",ver_key="name", ext=".7z", url_regx=".*macos.7z")
