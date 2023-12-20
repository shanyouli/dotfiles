#!/usr/bin/env python3
import json
import os
import platform
import re
import subprocess
from enum import Enum
from functools import wraps
from pathlib import Path
from typing import List, Optional

import typer

app = typer.Typer(add_completion=True)


link_pattern = re.compile(r'(.*)-(\d*)-link')


class Dotfile:
    @property
    def value(self):
        for i in [
            os.getenv('DOTFILES'),
            '/etc/nixos',
            os.path.expanduser('~/.nixpkgs'),
            os.path.expanduser('~/.config/dotfiles'),
            os.path.expanduser('~/.dotfiles'),
        ]:
            if os.path.isdir(i):
                return i
        else:
            typer.secho('Unable to set the working directory', fg=Colors.ERROR.value)
            typer.secho(
                'The working directory for this script can only be the following location',
                fg=Colors.ERROR.value,
            )
            typer.secho('1.     /etc/nixos', fg=Colors.INFO.value)
            typer.secho('2.     ~/.nixpkgs', fg=Colors.INFO.value)
            typer.secho('3.     ~/.config/dotfiles', fg=Colors.INFO.value)
            typer.secho('4.     ~/.dotfiles', fg=Colors.INFO.value)
            raise typer.Abort()


def set_workdir_to_dotfiles(func):
    """Set the working directory to dotfiles"""

    @wraps(func)
    def wrapper(*args, **kw):
        old_workdir = os.getcwd()
        os.chdir(Dotfile().value)
        result = func(*args, **kw)
        os.chdir(old_workdir)
        return result

    return wrapper


class FlakeOutputs(Enum):
    NIXOS = 'nixosConfigurations'
    DARWIN = 'darwinConfigurations'
    HOME_MANAGER = 'homeConfigurations'


class Colors(Enum):
    SUCCESS = typer.colors.GREEN
    INFO = typer.colors.BLUE
    ERROR = typer.colors.RED
    WARN = typer.colors.YELLOW


def change_workdir(func):
    @wraps(func)
    def wrapper(*args, **kw):
        old_workdir = os.getcwd()
        os.chdir(args[0])
        result = func(*args, **kw)
        os.chdir(old_workdir)
        return result

    return wrapper


def file_exists(f: Optional[Path]):
    if not os.path.exists(f):
        return False
    if os.path.islink(f):
        return os.path.exists(os.readlink(f))
    else:
        return True


def link_remove(f: Optional[Path]):
    if not (os.path.islink(f) or os.path.isfile(f)):
        return False
    try:
        os.remove(f)
    except PermissionError:
        subprocess.getoutput(f'sudo rm -vf {f}')


def remove_from_link_list(clearl: List[Path], dry_run: bool = False):
    if dry_run:
        typer.secho(
            f'The following files will be deleted from {os.getcwd()}..',
            fg=Colors.INFO.value,
        )
        print(*clearl, sep='\n')
    else:
        for i in clearl:
            link_remove(i)


def gc_save_link(store: dict[str, List], clear_list: List[str], test: str | tuple):
    if isinstance(test, str):
        f = test
        cf = test
    else:
        f = test[1]
        cf = test[0]

    if not file_exists(f):
        clear_list.append(cf)
        return

    f_prefix_num_group = link_pattern.match(f)
    if not f_prefix_num_group:
        return

    f_prefix = f_prefix_num_group.group(1)
    num = int(f_prefix_num_group.group(2))

    if f_prefix not in store:
        store[f_prefix] = (cf, num)
        return

    if store[f_prefix][-1] < num:
        clear_list.append(store[f_prefix][0])
        store[f_prefix] = (cf, num)
    else:
        clear_list.append(cf)


@change_workdir
def gc_remove_profile_link(profile: Optional[Path], clear: bool = False):
    store = {}
    clear_list = []
    for i in os.listdir():
        gc_save_link(store, clear_list, i)
    if clear_list:
        remove_from_link_list(clear_list, clear)
    else:
        typer.secho(
            f'There are no files in the {os.getcwd()} directory that need to be deleted',
            fg=Colors.INFO.value,
        )


@change_workdir
def gc_remove_auto_link(gc_fpath: Path, clear: bool = False):
    rlinks = [(i, os.readlink(i)) for i in os.listdir() if os.path.islink(i)]
    clear_list = []
    store = {}
    for i in rlinks:
        gc_save_link(store, clear_list, i)
    if clear_list:
        remove_from_link_list(clear_list, clear)
    else:
        typer.secho(
            f'There are no files in the {os.getcwd()} directory that need to be deleted',
            fg=Colors.INFO.value,
        )


def test_cmd_exists(cmd):
    return (
        subprocess.run(['/usr/bin/env', 'type', cmd], capture_output=True).returncode
        == 0
    )


UNAME = platform.uname()

if test_cmd_exists('nixos-rebuild'):
    # if we're on nixos, this command is built in
    PLATFORM = FlakeOutputs.NIXOS
elif test_cmd_exists('darwin-rebuild') or UNAME.system.lower() == 'darwin':
    # if we're on darwin, we might have darwin-rebuild or the distro id will be 'darwin'
    PLATFORM = FlakeOutputs.DARWIN
else:
    # in all other cases of linux
    PLATFORM = FlakeOutputs.HOME_MANAGER

USERNAME = subprocess.run(['id', '-un'], capture_output=True).stdout.decode().strip()
SYSTEM_ARCH = 'aarch64' if UNAME.machine == 'arm64' else UNAME.machine
SYSTEM_OS = UNAME.system.lower()
DEFAULT_HOST = f'{USERNAME}@{SYSTEM_ARCH}-{SYSTEM_OS}'

REMOTE_FLAKE = 'github:shanyouli/dotfiles'


def get_flake() -> str:
    check_git = subprocess.run(
        ['git', 'rev-parse', '--show-toplevel'], capture_output=True
    )
    local_flake = os.path.realpath(check_git.stdout.decode().strip())
    if check_git.returncode == 0 and os.path.isfile(
        os.path.join(local_flake, 'flake.nix')
    ):
        return local_flake
    else:
        return REMOTE_FLAKE


def fmt_command(cmd: List[str]):
    cmd_str = ' '.join(cmd)
    return f'> {cmd_str}'


def test_cmd(cmd: List[str]):
    return subprocess.run(cmd).returncode == 0


def run_cmd(cmd: List[str], shell: bool = False):
    typer.secho(fmt_command(cmd), fg=Colors.INFO.value)
    return subprocess.run((' '.join(cmd) if shell else cmd), shell=shell)


def select(nixos: bool, darwin: bool, home_manager: bool):
    if sum([nixos, darwin, home_manager]) > 1:
        typer.secho(
            'cannot apply more than one of [--nixos, --darwin, --home-manager]. aborting...',
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
    help='builds an initial configuration',
    hidden=PLATFORM == FlakeOutputs.NIXOS,
)
@set_workdir_to_dotfiles
def bootstrap(
    host: str = typer.Argument(
        DEFAULT_HOST, help='the hostname of the configuration to build'
    ),
    nixos: bool = False,
    darwin: bool = False,
    home_manager: bool = False,
    remote: bool = typer.Option(
        default=False, help='whether to fetch current changes from the remote'
    ),
):
    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    flags = [
        '-v',
        '--experimental-features',
        'nix-command flakes',
        '--extra-substituters',
        'https://shanyouli.cachix.org',
    ]
    bootstrap_flake = REMOTE_FLAKE if remote else get_flake()
    if host is None:
        typer.secho('Host unspecified', fg=Colors.ERROR.value)
        return
    if cfg is None:
        typer.secho('missing configuration', fg=Colors.ERROR.value)
    elif cfg == FlakeOutputs.NIXOS:
        typer.secho(
            'boostrap does not apply to nixos systems.',
            fg=Colors.ERROR.value,
        )
        raise typer.Abort()
    elif cfg == FlakeOutputs.DARWIN:
        diskSetup()
        flake = f'${bootstrap_flake}#{cfg.value}.{host}.config.system.build.toplevel'
        run_cmd(['nix', 'build', 'flake'] + flags)
        run_cmd(
            f'./result/sw/bin/darwin-rebuild switch --flake {bootstrap_flake}#{host}'.split()
        )
    elif cfg == FlakeOutputs.HOME_MANAGER:
        flake = f'{bootstrap_flake}#{host}'
        run_cmd(
            ['nix', 'run']
            + flags
            + [
                'github:nix-community/home-manager',
                '--no-write-lock-file',
                '--',
                'switch',
                '--flake',
                flake,
                '-b',
                'backup',
            ]
        )
    else:
        typer.secho('could not infer system type.', fg=Colors.ERROR.value)
        raise typer.Abort()


@app.command(
    help='builds the specified flake output; infers correct platform to use if not specified',
    no_args_is_help=True,
)
@set_workdir_to_dotfiles
def build(
    host: str = typer.Argument(None, help='the hostname of the configuration to build'),
    remote: bool = typer.Option(
        default=False, help='whether to fetch current changes from the remote'
    ),
    nixos: bool = False,
    darwin: bool = False,
    home_manager: bool = False,
):
    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    if cfg is None:
        return
    elif cfg == FlakeOutputs.NIXOS:
        cmd = ['sudo', 'nixos-rebuild', 'build', '--flake']
    elif cfg == FlakeOutputs.DARWIN:
        cmd = ['sudo', 'darwin-rebuild', 'build', '--flake']
    elif cfg == FlakeOutputs.HOME_MANAGER:
        cmd = ['home-manager', 'built', '--flake']
    else:
        typer.secho('could not infer system type.', fg=Colors.ERROR.value)
        raise typer.Abort()
    flake = f'{REMOTE_FLAKE if remote else get_flake()}#{host}'
    flags = ['--show-trace']
    run_cmd(cmd + [flake] + flags)


@app.command(
    help='remove previously built configurations and symlinks from the current directory',
)
@set_workdir_to_dotfiles
def clean(
    filename: str = typer.Argument(
        'result', help="the filename to be cleaned, or '*' for all files"
    ),
):
    run_cmd(f'find . -type l -maxdepth 1 -name {filename} -exec rm {{}} +'.split())


@app.command(
    help='configure disk setup for nix-darwin',
    hidden=PLATFORM != FlakeOutputs.DARWIN,
)
def diskSetup():
    if not test_cmd('grep -q ^run\\b /etc/synthetic.conf'.split()):
        APFS_UTIL = '/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util'
        typer.secho('setting up /etc/synthetic.conf', fg=Colors.INFO.value)
        run_cmd(
            "echo 'run\tprivate/var/run' | sudo tee -a /etc/synthetic.conf".split(),
            shell=True,
        )
        run_cmd([APFS_UTIL, '-B'])
        run_cmd([APFS_UTIL, '-t'])
    if not test_cmd(['test', '-L', '/run']):
        typer.secho('linking /run directory', fg=Colors.INFO.value)
        run_cmd('sudo ln -sfn private/var/run /run'.split())
    typer.secho('disk setup complete', fg=Colors.SUCCESS.value)


@app.command(
    help='run garbage collection on unused nix store paths',
    no_args_is_help=True,
)
def gc(
    delete_older_than: str = typer.Option(
        None,
        '--delete-older-than',
        '-d',
        metavar='[AGE]',
        help='specify minimum age for deleting store paths',
    ),
    dry_run: bool = typer.Option(False, help='test the result of garbage collection'),
    only: bool = typer.Option(False, help='Keep only one build'),
):
    if only:
        gc_remove_auto_link('/nix/var/nix/gcroots/auto', dry_run)
        gc_remove_profile_link('/nix/var/nix/profiles', dry_run)
        gc_remove_profile_link(
            os.path.expanduser('~/.local/state/nix/profiles'), dry_run
        )
    else:
        if dry_run:
            cmd = f"nix-collect-garbage { '--delete-older-than ' + delete_older_than if delete_older_than else '-d' } --dry-run"
            run_cmd(cmd.split())
        else:
            for i in [
                '/nix/var/nix/profiles/default',
                '/nix/var/nix/profiles/system',
                os.path.expanduser('~/.local/state/nix/profiles/home-manager'),
            ]:
                if os.path.exists(i):
                    cmd = f"sudo nix profile wipe-history --profile {i} --older-than {delete_older_than} {'--dry-run' if dry_run else ''}"
                    run_cmd(cmd.split())
    if not dry_run:
        cmd = 'sudo nix store gc --debug'
        run_cmd(cmd.split())


@set_workdir_to_dotfiles
def get_inputs_flake():
    path = os.path.join(os.path.expanduser(os.getcwd()), 'flake.lock')
    if os.path.exists(path) and os.path.isfile(path):
        with open(path, mode='r', encoding='utf-8') as f:
            data_json = json.load(f)
            try:
                return [i for i in data_json['nodes']['root']['inputs'].keys()]
            except KeyError as er:
                raise er
    else:
        print('没有发现路径')
        return False


@app.command(
    help='update all flake inputs or optionally specific flakes',
)
@set_workdir_to_dotfiles
def update(
    flake: List[str] = typer.Option(
        None,
        '--flake',
        '-f',
        metavar='[FLAKE]',
        help='specify an individual flake to be updated',
    ),
    not_flake: List[str] = typer.Option(
        None,
        '--no-flake',
        '-n',
        metavar='[FLAKE]',
        help="Don't update the following flake",
    ),
    commit: bool = typer.Option(False, help='commit the updated lockfile'),
):
    flags = ['--commit-lock-file'] if commit else ['']
    flakes = []
    if flake:
        all_flags = get_inputs_flake()
        for i in flake:
            if i in all_flags:
                flakes.append(i)
            else:
                typer.secho(
                    f'The flake({i}) does not exist, please check all_flake or update it.',
                    fg=Colors.WARN.value,
                )
    elif not_flake:
        flakes = get_inputs_flake()
        for i in not_flake:
            if i in flakes:
                flakes.remove(i)
            else:
                typer.secho(
                    f'The flake({i}) does not exist, please check all_flake or update it.',
                    fg=Colors.ERROR.value,
                )
                raise typer.Abort()

    if not flakes:
        typer.secho('updating all flake inputs')
        run_cmd(['nix', 'flake', 'update'] + flags)
    else:
        inputs = [f'--update-input {input}' for input in flakes]
        typer.secho(f"updating {','.join(flakes)}")
        run_cmd(['nix', 'flake', 'lock'] + inputs + flags)


@app.command(help='pull changes from remote repo')
@set_workdir_to_dotfiles
def pull():
    cmd = 'git stash && git pull && git stash apply'
    run_cmd(cmd.split())


@app.command(
    help='builds and activates the specified flake output; infers correct platform to use if not specified',
    no_args_is_help=True,
)
@set_workdir_to_dotfiles
def switch(
    host: str = typer.Argument(
        default=DEFAULT_HOST,
        help='the hostname of the configuration to build',
    ),
    remote: bool = typer.Option(
        default=False, help='whether to fetch current changes from the remote'
    ),
    nixos: bool = False,
    darwin: bool = False,
    home_manager: bool = False,
):
    if not host:
        typer.secho('Error: host configuration not specified.', fg=Colors.ERROR.value)
        raise typer.Abort()

    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    if cfg is None:
        return
    elif cfg == FlakeOutputs.NIXOS:
        cmd = 'sudo nixos-rebuild switch --flake'
    elif cfg == FlakeOutputs.DARWIN:
        cmd = 'darwin-rebuild switch --flake'
    elif cfg == FlakeOutputs.HOME_MANAGER:
        cmd = 'home-manager switch --flake'
    else:
        typer.secho('could not infer system type.', fg=Colors.ERROR.value)
        raise typer.Abort()

    if remote:
        flake = f'{REMOTE_FLAKE}#{host}'
    else:
        flake = f'{get_flake()}#{host}'
    flags = ['--show-trace']
    run_cmd(cmd.split() + [flake] + flags)


@app.command(help='cache the output environment of flake.nix')
@set_workdir_to_dotfiles
def cache(cache_name: str = 'shanyouli'):
    cmd = f"nix flake archive --json | jq -r '.path,(.inputs|to_entries[].value.path)' | cachix push {cache_name}"
    run_cmd(cmd.split(), shell=True)


@app.command(help='nix repl')
@set_workdir_to_dotfiles
def repl(
    pkgs: bool = typer.Option(False, help='import <nixpkgs>'),
    flake: bool = typer.Option(False, help='Automatically import build flake'),
):
    cmd = 'nix repl'
    exarg = 'import <nixpkgs> {}' if pkgs else None
    if flake:
        flake_src = f'(builtins.getFlake \\"{os.getcwd()}\\")'
        if exarg:
            exarg = exarg + ' // ' + flake_src
        else:
            exarg = flake_src + f'.{PLATFORM.value}.\\"{DEFAULT_HOST}\\"'
    cmd = cmd + ' --expr "' + exarg + '"' if exarg else cmd
    typer.secho(f'> {cmd}', fg=Colors.INFO.value)
    os.system(cmd)


@app.command(help='Redirect the bundle id to specify the version')
def refresh(rd: bool = typer.Option(False, help='Reset to start the machine layout')):
    if PLATFORM == FlakeOutputs.DARWIN:
        if rd:
            run_cmd(
                [
                    'defaults',
                    'write',
                    'com.apple.dock',
                    'ResetLaunchPad',
                    '-bool',
                    'true',
                    '&&',
                    'killall',
                    'Dock',
                ],
                shell=True,
            )
        run_cmd(
            [
                '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister',
                '-kill',
                '-r',
                '-domain local',
                '-domain',
                'system',
                '-domain',
                'user',
            ],
            shell=True,
        )
    SHELL = os.getenv('SHELL')
    proc = subprocess.getoutput(f'unset PATH;{SHELL} -c -i printenv')
    proc_list = (
        i for i in proc.split('\n') if not i.startswith('_') and i.find('=') != -1
    )
    source_env = {}
    for tup in proc_list:
        temp = tup.split('=')
        source_env[temp[0].strip()] = temp[1].strip()
    envfile = os.path.expanduser(os.path.join('~/.cache', 'menv.json'))
    with open(envfile, mode='w', encoding='utf-8') as f:
        f.write(json.dumps(source_env))


if __name__ == '__main__':
    app()
