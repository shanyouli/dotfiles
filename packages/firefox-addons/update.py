import json
import os
import re
import subprocess
from typing import List

import requests
from bs4 import BeautifulSoup


def get_script_path():
    return os.path.dirname(os.path.realpath(__file__))


def get_firefox_addons_xpi(name: str) -> str:
    html = requests.get(f"https://addons.mozilla.org/en-US/firefox/addon/{name}").text
    soup = BeautifulSoup(html, "html.parser")
    for i in soup.find_all("a", class_="InstallButtonWrapper-download-link"):
        if "href" in i.attrs and i["href"].endswith(".xpi"):
            return i["href"]
    else:
        xpi_soup = soup.find(href=re.compile("\.xpi$"))
        if xpi_soup:
            return xpi_soup.get("href")
        else:
            raise ValueError(f"The extensions of {name}  not found")


def get_version(url: str) -> str:
    re_pattern = re.search(r"-([0-9.]+).xpi", url)
    return re_pattern.group(1) if re_pattern is not None else None


def nix_prefix_url(url: str) -> str:
    result = subprocess.run(["nix-prefetch-url", url], stdout=subprocess.PIPE)
    if result.returncode != 0:
        raise RuntimeError(
            "nix-prefetch-url exited with error {}".format(result.returncode)
        )
    return result.stdout.decode("utf-8").strip()


def get_current_src(f):
    if os.path.isfile(f):
        with open(f, encoding="utf-8", mode="r") as text:
            return json.load(text)


def save_current_src(f, sources):
    with open(f, encoding="utf-8", mode="w") as text:
        json.dump(sources, text)


def init_sources(add_name):
    sources = {}
    for i in add_name:
        url = get_firefox_addons_xpi(i)
        sources[i] = {
            "url": url,
            "version": get_version(url),
            "sha256": nix_prefix_url(url),
            "pname": i,
        }
    return sources


def update_src(add_name: List[str]):
    target_file = os.path.join(get_script_path(), "sources.json")
    is_update = False
    sources = get_current_src(target_file)
    next_sources = {}
    if sources:
        for i in add_name:
            url = get_firefox_addons_xpi(i)
            if i not in sources or sources[i]["url"] != url:
                next_sources[i] = {
                    "url": url,
                    "version": get_version(url),
                    "sha256": nix_prefix_url(url),
                    "pname": i,
                }
                is_update = True
            else:
                next_sources[i] = sources.pop(i)
    else:
        next_sources = init_sources(add_name)
        is_update = True
    if is_update or (not sources):
        save_current_src(target_file, next_sources)


if __name__ == "__main__":
    update_src(
        [
            "noscript",
            "browserpass-ce",
            "download-with-aria2",
            "surfingkeys_ff",
            "auto-tab-discard",
            "user-agent-string-switcher",
            "violentmonkey",
            "switchyomega",
            "styl-us",
        ]
    )
