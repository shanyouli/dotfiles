#!/usr/bin/env python3
import json
import os
import platform
import subprocess
from enum import Enum
from typing import List
from typer._completion_shared import Shells
import typer.completion
import typer
import sys

app = typer.Typer(add_completion=True)
app_completion = typer.Typer(
    help="Generate and install completion scripts.", hidden=True
)
app.add_typer(app_completion, name="completion")


@app_completion.command(
    no_args_is_help=True,
    help="Show completion for the specified shell, to copy or customize it.",
)
def show(ctx: typer.Context, shell: Shells) -> None:
    typer.completion.show_callback(ctx, None, shell)


@app_completion.command(
    no_args_is_help=True, help="Install completion for the specified shell."
)
def install(ctx: typer.Context, shell: Shells) -> None:
    typer.completion.install_callback(ctx, None, shell)


class FlakeOutputs(Enum):
    NIXOS = "nixosConfigurations"
    DARWIN = "darwinConfigurations"
    HOME_MANAGER = "homeConfigurations"


class Colors(Enum):
    SUCCESS = typer.colors.GREEN
    INFO = typer.colors.BLUE
    ERROR = typer.colors.RED
    WARN = typer.colors.YELLOW


if os.system("command -v nixos-rebuild > /dev/null") == 0:
    # if we're on nixos, this command is built in
    PLATFORM = FlakeOutputs.NIXOS
elif (
    os.system("command -v darwin-rebuild > /dev/null") == 0
    or platform.uname().system.lower().strip() == "darwin".lower().strip()
):
    # if we're on darwin, we might have darwin-rebuild or the distro id will be 'darwin'
    PLATFORM = FlakeOutputs.DARWIN
else:
    # in all other cases of linux
    PLATFORM = FlakeOutputs.HOME_MANAGER


def fmt_command(cmd: str):
    return f"> {cmd}"


def test_cmd(cmd: str):
    return os.system(f"{cmd} > /dev/null") == 0


def run_cmd(cmd: str):
    typer.secho(fmt_command(cmd), fg=Colors.INFO.value)
    return os.system(cmd)


def select(nixos: bool, darwin: bool, home_manager: bool):
    if sum([nixos, darwin, home_manager]) > 1:
        typer.secho(
            "cannot apply more than one of [--nixos, --darwin, --home-manager]. aborting...",
            fg=Colors.ERROR.value,
        )
        raise typer.Abort()

    if nixos:
        return FlakeOutputs.NIXOS

    elif darwin:
        return FlakeOutputs.DARWIN

    elif home_manager:
        return FlakeOutputs.HOME_MANAGER

    else:
        return PLATFORM


@app.command(
    help="builds an initial configuration",
    hidden=PLATFORM == FlakeOutputs.NIXOS,
)
def bootstrap(
    host: str = typer.Argument(None, help="the hostname of the configuration to build"),
    nixos: bool = False,
    darwin: bool = False,
    home_manager: bool = False,
):
    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    flags = "-v --experimental-features 'nix-command flakes'"

    if cfg is None:
        return
    elif cfg == FlakeOutputs.NIXOS:
        typer.secho(
            "boostrap does not apply to nixos systems.",
            fg=Colors.ERROR.value,
        )
        raise typer.Abort()
    elif cfg == FlakeOutputs.DARWIN:
        diskSetup()
        flake = f".#{cfg.value}.{host}.config.system.build.toplevel {flags}"
        run_cmd(f"nix build {flake} {flags}")
        run_cmd(f"./result/sw/bin/darwin-rebuild switch --flake .#{host}")
    elif cfg == FlakeOutputs.HOME_MANAGER:
        flake = f".#{host}"
        run_cmd(
            f"nix run github:nix-community/home-manager {flags} --no-write-lock-file -- switch --flake {flake} -b backup"
        )
    else:
        typer.secho("could not infer system type.", fg=Colors.ERROR.value)
        raise typer.Abort()


@app.command(
    help="builds the specified flake output; infers correct platform to use if not specified",
    no_args_is_help=True,
)
def build(
    host: str = typer.Argument(None, help="the hostname of the configuration to build"),
    pull: bool = typer.Option(
        default=False, help="whether to fetch current changes from the remote"
    ),
    nixos: bool = False,
    darwin: bool = False,
    home_manager: bool = False,
):
    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    if cfg is None:
        return
    elif cfg == FlakeOutputs.NIXOS:
        cmd = "sudo nixos-rebuild build --flake"
        flake = f".#{host}"
    elif cfg == FlakeOutputs.DARWIN:
        flake = f".#{host}"
        cmd = "darwin-rebuild build --flake"
    elif cfg == FlakeOutputs.HOME_MANAGER:
        flake = f".#{host}"
        cmd = "home-manager build --flake"
    else:
        typer.secho("could not infer system type.", fg=Colors.ERROR.value)
        raise typer.Abort()

    if pull:
        git_pull()
    flake = f".#{host}"
    flags = " ".join(["--show-trace"])
    run_cmd(f"{cmd} {flake} {flags}")


@app.command(
    help="remove previously built configurations and symlinks from the current directory",
)
def clean():
    run_cmd("for i in *; do [[ -L $i ]] && rm -f $i; done")


@app.command(
    help="configure disk setup for nix-darwin",
    hidden=PLATFORM != FlakeOutputs.DARWIN,
)
def diskSetup():
    if PLATFORM != FlakeOutputs.DARWIN:
        typer.secho(
            "nix-darwin does not apply on this platform. aborting...",
            fg=Colors.ERROR.value,
        )
        return

    if not test_cmd("grep -q '^run\\b' /etc/synthetic.conf 2>/dev/null"):
        APFS_UTIL = "/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util"
        typer.secho("setting up /etc/synthetic.conf", fg=Colors.INFO.value)
        run_cmd("echo 'run\tprivate/var/run' | sudo tee -a /etc/synthetic.conf")
        run_cmd(f"{APFS_UTIL} -B || true")
        run_cmd(f"{APFS_UTIL} -t || true")
    if not test_cmd("test -L /run"):
        typer.secho("linking /run directory", fg=Colors.INFO.value)
        run_cmd("sudo ln -sfn private/var/run /run")
    typer.secho("disk setup complete", fg=Colors.SUCCESS.value)


@app.command(help="run formatter on all files")
def fmt():
    run_cmd("fmt")


def get_inputs_flake():
    path = os.path.join(os.path.expanduser(os.getcwd()), "flake.lock")
    if os.path.exists(path) and os.path.isfile(path):
        with open(path, mode="r", encoding="utf-8") as f:
            data_json = json.load(f)
            try:
                return [i for i in data_json["nodes"]["root"]["inputs"].keys()]
            except KeyError as er:
                raise er
    else:
        print("没有发现路径")
        return False


@app.command(
    help="run garbage collection on unused nix store paths",
    no_args_is_help=True,
)
def gc(
    delete_older_than: str = typer.Option(
        None,
        "--delete-older-than",
        "-d",
        metavar="[AGE]",
        help="specify minimum age for deleting store paths",
    ),
    dry_run: bool = typer.Option(False, help="test the result of garbage collection"),
):
    cmd = f"nix-collect-garbage --delete-older-than {delete_older_than} {'--dry-run' if dry_run else ''}"
    run_cmd(cmd)


@app.command(
    help="update all flake inputs or optionally specific flakes",
)
def update(
    flake: List[str] = typer.Option(
        None,
        "--flake",
        "-f",
        metavar="[FLAKE]",
        help="specify an individual flake to be updated",
    ),
    not_flake: List[str] = typer.Option(
        None,
        "--no-flake",
        "-n",
        metavar="[FLAKE]",
        help="Don't update the following flake",
    ),
    commit: bool = typer.Option(False, help="commit the updated lockfile"),
):
    flags = "--commit-lock-file" if commit else ""
    all_flags = [
        "nixos-hardware",
        "nixos-stable",
        "darwin-stable",
        "nixpkgs",
        "small",
        "darwin",
        "home-manager",
        "emacs-overlay",
        "emacs-src",
        "rust-overlay",
        "flake-utils",
        "nixpkgs-firefox-darwin",
        "nur",
        "devenv",
        "treefmt-nix",
    ]
    flakes = []
    if flake:
        all_flags = get_inputs_flake()
        for i in flake:
            if i in all_flags:
                flakes.append(i)
            else:
                typer.secho(
                    f"The flake({i}) does not exist, please check all_flake or update it.",
                    fg=Colors.WARN.value,
                )
    elif not_flake:
        flakes = get_inputs_flake()
        for i in not_flake:
            if i in flakes:
                flakes.remove(i)
            else:
                typer.secho(
                    f"The flake({i}) does not exist, please check all_flake or update it.",
                    fg=Colors.ERROR.value,
                )
                raise typer.Abort()

    if not flakes:
        typer.secho("updating all flake inputs")
        cmd = f"nix flake update {flags}"
        run_cmd(cmd)
    else:
        inputs = [f"--update-input {input}" for input in flakes]
        typer.secho(f"updating {','.join(flakes)}")
        cmd = f"nix flake lock {' '.join(inputs)} {flags}"
        run_cmd(cmd)


@app.command(help="pull changes from remote repo")
def git_pull():
    cmd = "git stash && git pull && git stash apply"
    run_cmd(cmd)


@app.command(help="update remote repo with current changes")
def git_push():
    cmd = "git push"
    run_cmd(cmd)


@app.command(
    help="builds and activates the specified flake output; infers correct platform to use if not specified",
    no_args_is_help=True,
)
def switch(
    host: str = typer.Argument(
        default=None,
        help="the hostname of the configuration to build",
    ),
    pull: bool = typer.Option(
        default=False, help="whether to fetch current changes from the remote"
    ),
    nixos: bool = False,
    darwin: bool = False,
    home_manager: bool = False,
):
    if not host:
        typer.secho("Error: host configuration not specified.", fg=Colors.ERROR.value)
        raise typer.Abort()

    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    if cfg is None:
        return
    elif cfg == FlakeOutputs.NIXOS:
        cmd = "sudo nixos-rebuild switch --flake"
    elif cfg == FlakeOutputs.DARWIN:
        cmd = "darwin-rebuild switch --flake"
    elif cfg == FlakeOutputs.HOME_MANAGER:
        cmd = "home-manager switch --flake"
    else:
        typer.secho("could not infer system type.", fg=Colors.ERROR.value)
        raise typer.Abort()

    if pull:
        git_pull()
    flake = f".#{host}"
    flags = " ".join(["--show-trace"])
    run_cmd(f"{cmd} {flake} {flags}")


@app.command(help="cache the output environment of flake.nix")
def cache(cache_name: str = "shanyouli"):
    cmd = f"nix flake archive --json | jq -r '.path,(.inputs|to_entries[].value.path)' | cachix push {cache_name}"
    run_cmd(cmd)


@app.command(help="Redirect the bundle id to specify the version")
def refresh(rd: bool = typer.Option(False, help="Reset to start the machine layout")):
    if PLATFORM == FlakeOutputs.DARWIN:
        if rd:
            run_cmd(
                "defaults write com.apple.dock ResetLaunchPad -bool true && killall Dock"
            )

        run_cmd(
            "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user"
        )
    SHELL = os.getenv("SHELL")
    proc = subprocess.getoutput(f"unset PATH;{SHELL} -c -i printenv")
    proc_list = (
        i for i in proc.split("\n") if not i.startswith("_") and i.find("=") != -1
    )
    source_env = {}
    for tup in proc_list:
        temp = tup.split("=")
        source_env[temp[0].strip()] = temp[1].strip()
    envfile = os.path.expanduser(os.path.join("~/.cache", "menv.json"))
    with open(envfile, mode="w", encoding="utf-8") as f:
        f.write(json.dumps(source_env))


@app.command(help="search pacakge")
def search(
    pkg: str = typer.Argument(default=None, help="package name"),
    max_num: int = typer.Argument(default=100, help="search max num"),
):
    if not pkg:
        typer.secho("Error: Please input package name", fg=Colors.ERROR.value)
        raise typer.Abort()
    cmd = f"nix search --json --no-update-lock-file nixpkgs {pkg}"
    search_result = os.popen(cmd).readlines()[0]
    if search_result == "{}":
        typer.secho("Warn: No search packages", fg=Colors.WARN.value)
        raise typer.Abort()
    search_dict = json.loads(search_result)
    search_keys = search_dict.keys()
    search_package = [i for i in search_keys if i.find(pkg) != -1]
    if search_package == []:
        typer.secho("Warn: No search packages", fg=Colors.WARN.value)
        raise typer.Abort()
    search_package = [
        pkg_key for i, pkg_key in enumerate(search_package) if i < max_num
    ]
    names = [
        typer.style(
            i.split(".", 2)[-1], fg=typer.colors.GREEN, bold=True, underline=True
        )
        for i in search_package
    ]
    pnames = [
        typer.style(
            search_dict[i]["pname"], fg=typer.colors.GREEN, bold=True, underline=True
        )
        for i in search_package
    ]
    pversions = [
        typer.style(search_dict[i]["version"], fg=typer.colors.YELLOW, bold=True)
        for i in search_package
    ]
    pdesc = [search_dict[i]["description"] for i in search_package]
    names_max = max([len(i) for i in names])
    pnames_max = max([len(i) for i in pnames])
    pversions_max = max([len(i) for i in pversions])
    for i, pname in enumerate(pnames):
        num = typer.style(f"{i + 1}.\t", fg=Colors.INFO.value)
        message = f"{num} name: {names[i].ljust(names_max)} ppname: {pname.ljust(pnames_max)} version: {pversions[i].ljust(pversions_max)} desc: {pdesc[i]}"
        typer.echo(message)

def nth(idx, lst):
    if idx >= len(lst):
        return None
    else:
        return lst[idx]

def main():
    if nth(1, sys.argv) not in [ "completion", "--install-completion", "--show-completion", "--help" ]:
        for i in [
                "/etc/nixos",
                os.path.expanduser("~/.nixpkgs"),
                os.path.expanduser("~/.dotfiles"),
        ]:
            if os.path.isdir(i):
                os.chdir(i)
                break
        else:
            typer.secho("Unable to set the working directory", fg=Colors.ERROR.value)
            typer.secho(
                "The working directory for this script can only be the following location",
                fg=Colors.ERROR.value,
            )
            typer.secho("1.     /etc/nixos", fg=Colors.INFO.value)
            typer.secho("2.     ~/nixpkgs", fg=Colors.INFO.value)
            typer.secho("3.     ~/.dotfiles", fg=Colors.INFO.value)
            sys.exit(1)
    typer.completion.completion_init()
    sys.exit(app())


if __name__ == "__main__":
    main()
