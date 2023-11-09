#!/usr/bin/env python3
"""获取程序的Bundle ID"""
import os
import subprocess
import typer
from enum import Enum
from typing import Union, List
from pathlib import Path

app = typer.Typer()

appPath = ["/Applications", os.path.expanduser("~/Applications")]
PathLink = Union[str, bytes, Path]


class Colors(Enum):
    SUCCESS = typer.colors.GREEN
    INFO = typer.colors.BLUE
    ERROR = typer.colors.RED
    WARN = typer.colors.YELLOW


def get_app_list_by_path(path: PathLink) -> List[str]:
    """获取目录下所有的App文件
    """
    app_list = []
    for i in os.listdir(path):
        if i.endswith(".app"):
            app_list.append(i)
        else:
            subpath = f"{path}/{i}"
            if os.path.isdir(subpath):
                for j in get_app_list_by_path(os.path.join(path, i)):
                    app_list.append(j)
    return app_list


def get_app_list_by_list(paths: List[PathLink]) -> List[str]:
    app_lists = [get_app_list_by_path(i) for i in paths]
    return [j for i in app_lists for j in i]


def get_app_bundleid(app_name: str) -> str:
    "获取app的Bundle Ip"
    return subprocess.getoutput(f"osascript -e 'id of app \"{app_name}\"'")


def get_terminal_columns() -> int:
    columns = os.get_terminal_size().columns
    if columns == 0:
        columns = 80

    return columns


def get_list_max_size(lst: List[str]) -> int:
    return max(len(i) for i in lst)


@app.command(help="Get All App Name")
def display():
    app_lists = get_app_list_by_list(appPath)
    pre_size = len(str(len(app_lists)))
    columns = get_terminal_columns()
    app_size = get_list_max_size(app_lists)
    num = columns // (app_size + 4 + pre_size + 2)
    if num == 0:
        num = 1
    messages = ""
    split = "".rjust(4)
    for i, appname in enumerate(app_lists):
        numstr = typer.style(f"{i + 1}".rjust(pre_size, "0"),
                             fg=Colors.INFO.value)
        appname = typer.style(appname.ljust(app_size), fg=Colors.INFO.value)
        message = f"{numstr}: {appname}{split}"
        messages = f"{messages}{message}"
        if (i + 1) % num == 0:
            typer.echo(messages)
            messages = ""


@app.command(help="Display all app BundleId")
def db():
    app_lists = get_app_list_by_list(appPath)
    pre_size = len(str(len(app_lists)))
    app_bundle_id_list = [get_app_bundleid(i) for i in app_lists]

    columns = get_terminal_columns()
    app_size = get_list_max_size(app_lists)
    app_bundle_id_size = get_list_max_size(app_bundle_id_list)

    num = columns // (app_size + 4 + pre_size + 2 + app_bundle_id_size + 2)
    if num == 0:
        num = 1
    messages = ""
    split = "".rjust(2)
    for i, appname in enumerate(app_lists):
        numstr = typer.style(f"{i + 1}".rjust(pre_size, "0"),
                             fg=Colors.INFO.value)
        appname = typer.style(appname.ljust(app_size), fg=Colors.INFO.value)
        appbundleid = typer.style(
            app_bundle_id_list[i].ljust(app_bundle_id_size),
            fg=Colors.INFO.value)
        message = f"{numstr}: {appname}{split}{appbundleid}{split}{split}"
        messages = f"{messages}{message}"
        if (i + 1) % num == 0:
            typer.echo(messages)
            messages = ""

@app.command(help="get one app bundleid")
def get(pkg: str = typer.Argument(None, help="App Path, Please run: getBundleId.py display")):
    if pkg in get_app_list_by_list(appPath):
        typer.secho(get_app_bundleid(pkg), fg=Colors.INFO.value)
    else:
        typer.secho(f"Didn't find the {pkg}, please use the command display view", fg=Colors.ERROR.value)
        raise typer.Abort()

if __name__ == "__main__":
    app()
