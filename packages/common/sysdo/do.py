#!/usr/bin/env python3
import json
import os
import platform
import re
import subprocess
from enum import Enum
from functools import wraps
from pathlib import Path
from typing import List

import typer

app = typer.Typer(add_completion=True)


class FlakeOutputs(Enum):
    NIXOS = 'nixosConfigurations'
    DARWIN = 'darwinConfigurations'
    HOME_MANAGER = 'homeConfigurations'


class Colors(Enum):
    SUCCESS = typer.colors.GREEN
    INFO = typer.colors.BLUE
    ERROR = typer.colors.RED
    WARN = typer.colors.YELLOW


class Dotfile:
    @property
    def value(self):
        for i in [
            os.getenv('DOTFILES'),
            '/etc/dotfiles',
            '/etc/nixos',
            os.path.expanduser('~/.config/dotfiles'),
            os.path.expanduser('~/.dotfiles'),
            os.path.expanduser('~/.nixpkgs'),

        ]:
            if (
                os.path.isdir(i)
                and os.path.exists(os.path.join(i, 'flake.nix'))
                and os.path.exists(os.path.join(i, '.git'))
            ):
                return os.path.realpath(i)

    def get_flake(self, current_dir: bool = False) -> str:
        if current_dir:
            check_git = subprocess.run(
                ['git', 'rev-parse', '--show-toplevel'], capture_output=True
            )
            if check_git.returncode == 0:
                local_flake = os.path.realpath(check_git.stdout.decode().strip())
                return (
                    local_flake
                    if os.path.isfile(os.path.join(local_flake, 'flake.nix'))
                    else REMOTE_FLAKE
                )
        if self.value:
            return self.value
        else:
            typer.secho('No nix configuration directory found', fg=Colors.WARN.value)
            typer.secho(
                'The configuration directory for this script can only be the following location',
                fg=Colors.WARN.value,
            )
            typer.secho('1.     /etc/nixos', fg=Colors.WARN.value)
            typer.secho('2.     ~/.nixpkgs', fg=Colors.WARN.value)
            typer.secho('3.     ~/.config/dotfiles', fg=Colors.WARN.value)
            typer.secho('4.     ~/.dotfiles', fg=Colors.WARN.value)
            typer.secho('Remote flake will be used', fg=Colors.WARN.value)
            return REMOTE_FLAKE


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
DOTFILE = Dotfile()


def change_workdir(func):
    @wraps(func)
    def wrapper(*args, **kw):
        old_workdir = os.getcwd()
        if 'workdir' in kw:
            new_workdir = os.path.abspath(kw['workdir'])
        elif len(args) >= 2 and os.path.isdir(args[1]):
            new_workdir = os.path.abspath(args[1])
        elif DOTFILE.value:
            new_workdir = os.path.abspath(DOTFILE.value)
        is_change = new_workdir != old_workdir
        if is_change:
            os.chdir(new_workdir)
        result = func(*args, **kw)
        if is_change:
            os.chdir(old_workdir)
        return result

    return wrapper


class NixGc:
    def __init__(
        self,
        dry_run: bool = True,
        re_pattern: str = r'(.*)-(\d+)-link$',
        save_num: int = 1,
        default: str = 'default',
    ):
        self.dry_run = dry_run
        self.re_pattern = re.compile(re_pattern)
        self.save_num = save_num
        self.clear_list = []
        self.profiles = [
            i
            for i in [
                '/nix/var/nix/profiles',
                os.path.expanduser('~/.local/state/nix/profiles'),
            ]
            if os.path.isdir(i)
        ]
        self.gc_autos = [i for i in ['/nix/var/nix/gcroots/auto'] if os.path.isdir(i)]
        self.default = default

    def link_exists(self, f: Path):
        if os.path.exists(f):
            if os.path.islink(f):
                return os.path.exists(os.readlink(f))
            else:
                return True
        else:
            return False

    def link_remove(self, f: Path):
        if not (os.path.islink(f) or os.path.isfile(f)):
            return False
        try:
            os.remove(f)
        except PermissionError:
            subprocess.getoutput(f'sudo rm -vf {f}')

    def remove_from_link_list(self):
        if self.clear_list:
            if self.dry_run:
                typer.secho(
                    f'The following files will be deleted from {os.getcwd()}..',
                    fg=Colors.INFO.value,
                )
                print(*self.clear_list, sep='\n')
            else:
                for i in self.clear_list:
                    self.link_remove(i)
        else:
            typer.secho(
                f'Not File will be deleted from {os.getcwd()}...',
                fg=Colors.INFO.value,
            )

    @change_workdir
    def gc_auto(self, profile: Path):
        store = {}
        self.clear_list = []
        for i in os.listdir():
            if os.path.islink(i):
                target_path = os.readlink(i)
                if not os.path.exists(target_path):
                    self.clear_list.append(i)
                    continue
            f_prefix_num = self.re_pattern.match(target_path)
            if not f_prefix_num:
                store[target_path] = [(i, 1)]
                continue
            f_prefix = f_prefix_num.group(1)
            num = int(f_prefix_num.group(2))
            if f_prefix not in store:
                store[f_prefix] = [(i, num)]
            else:
                store[f_prefix].append((i, num))
        for i in store:
            store[i] = sorted(store[i], key=lambda k: k[-1], reverse=True)
            for path in store[i][self.save_num :]:
                self.clear_list.append(path[0])
        self.remove_from_link_list()

    @change_workdir
    def gc_profile(self, profile: Path):
        store = {}
        self.clear_list = []
        for i in os.listdir():
            if os.path.islink(i):
                if not os.path.exists(os.readlink(i)):
                    self.clear_list.append(i)
                    continue
            f_prefix_num = self.re_pattern.match(i)
            if not f_prefix_num:
                continue
            f_prefix = f_prefix_num.group(1)
            num = int(f_prefix_num.group(2))
            if f_prefix not in store:
                store[f_prefix] = [(i, num)]
            else:
                store[f_prefix].append((i, num))
        for i in store.values():
            i = sorted(i, key=lambda k: k[-1], reverse=True)
            for path in i[self.save_num :]:
                self.clear_list.append(path[0])
        self.remove_from_link_list()

    def gc_clear_list(self):
        for i in self.gc_autos:
            self.gc_auto(i)
        for i in self.profiles:
            self.gc_profile(i)

    def get_link_target_path(self, f):
        f_target = os.readlink(f)
        return (
            f_target
            if f_target.startswith('/')
            else os.path.join(os.path.dirname(f), f_target)
        )

    def clear_remove_default(self, reverse: bool = False):
        for i in self.gc_autos:
            for k in os.listdir(i):
                kpath = os.path.join(i, k)
                if not os.path.islink(kpath):
                    continue
                target_path = self.get_link_target_path(kpath)
                is_p = os.path.basename(target_path).startswith(self.default)
                is_p = (not is_p) if reverse else is_p
                if is_p:
                    if self.dry_run:
                        typer.secho(f'Delete {kpath}', fg=Colors.WARN.value)
                    else:
                        self.link_remove(kpath)
        for i in self.profiles:
            for k in os.listdir(i):
                kpath = os.path.join(i, k)
                is_p = os.path.basename(kpath).startswith(self.default)
                is_p = (not is_p) if reverse else is_p
                if is_p:
                    if self.dry_run:
                        typer.secho(f'Delete {kpath}', fg=Colors.WARN.value)
                    else:
                        self.link_remove(kpath)

    def run(self):
        if not self.dry_run:
            run_cmd(['sudo', 'nix', 'store', 'gc', '-v'])


# HACK: When macos is updated it automatically generates new /etc/shells,
# causing the nix-darwin build to fail
def shell_backup():
    etc_shell = '/etc/shells'
    if os.path.exists(etc_shell) and (not os.path.islink(etc_shell)):
        test_cmd(['sudo', 'mv', '-vf', etc_shell, '/etc/shells.backup'])


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
@change_workdir
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
    debug: bool = False,
):
    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    flags = [
        '-v',
        '--experimental-features',
        'nix-command flakes',
        '--extra-substituters',
        'https://shanyouli.cachix.org',
        "--impure",
    ]
    if debug:
        flags.append('--show-trace')
        flags.append('-L')
    bootstrap_flake = REMOTE_FLAKE if remote else DOTFILE.get_flake(True)
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
        shell_backup()
        flake = f'{bootstrap_flake}#{cfg.value}.{host}.config.system.build.toplevel'
        nix = (
            'nix' if test_cmd_exists('nix') else '/nix/var/nix/profiles/default/bin/nix'
        )
        run_cmd([nix, 'build', flake] + flags)
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
    # no_args_is_help=True,
)
def build(
    host: str = typer.Argument(
        DEFAULT_HOST, help='the hostname of the configuration to build'
    ),
    remote: bool = typer.Option(
        default=False, help='whether to fetch current changes from the remote'
    ),
    nixos: bool = False,
    darwin: bool = False,
    home_manager: bool = False,
    debug: bool = True,
):
    cfg = select(nixos=nixos, darwin=darwin, home_manager=home_manager)
    if cfg is None:
        return
    elif cfg == FlakeOutputs.NIXOS:
        cmd = ['sudo', 'nixos-rebuild', 'build', '--flake']
    elif cfg == FlakeOutputs.DARWIN:
        cmd = [ 'darwin-rebuild', 'build', '--flake']
    elif cfg == FlakeOutputs.HOME_MANAGER:
        cmd = ['home-manager', 'built', '--flake']
    else:
        typer.secho('could not infer system type.', fg=Colors.ERROR.value)
        raise typer.Abort()
    flake = f'{REMOTE_FLAKE if remote else DOTFILE.get_flake()}#{host}'
    flags = ['--impure']
    if debug:
        flags.append('--show-trace')
        flags.append('-L')
    run_cmd(cmd + [flake] +   flags)


@app.command(
    help='remove previously built configurations and symlinks from the current directory',
)
@change_workdir
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
    # no_args_is_help=True,
)
def gc(
    delete_older_than: str = typer.Option(
        None,
        '--delete-older-than',
        '-d',
        metavar='[AGE]',
        help='specify minimum age for deleting store paths',
    ),
    save: int = typer.Option(
        3, '--save', '-s', help='Save the last x number of builds'
    ),
    dry_run: bool = typer.Option(False, help='test the result of garbage collection'),
    # only: bool = typer.Option(False, help='Keep only one build'),
):
    if delete_older_than:
        cmd = f"nix-collect-garbage --delete-older-then {delete_older_than} {'--dry-run' if dry_run else ''}"
        if not dry_run:
            run_cmd(['sudo'] + cmd.split())
        run_cmd(cmd.split())
    else:
        nix_gc = NixGc(dry_run=dry_run, save_num=save)
        nix_gc.gc_clear_list()
        nix_gc.run()


def get_inputs_flake(path: Path = None):
    path = os.getcwd() if path is None else path
    flake_lock = os.path.join(os.path.realpath(path), 'flake.lock')
    if os.path.isfile(flake_lock):
        with open(flake_lock, mode='r', encoding='utf-8') as f:
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
@change_workdir
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
    flags = ['--commit-lock-file'] if commit else []
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
@change_workdir
def pull():
    cmd = 'git stash && git pull && git stash apply'
    run_cmd(cmd.split())


@app.command(
    help='builds and activates the specified flake output; infers correct platform to use if not specified',
    # no_args_is_help=True,
)
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
    debug: bool = False,
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
        shell_backup()
        cmd = 'darwin-rebuild switch --flake'
    elif cfg == FlakeOutputs.HOME_MANAGER:
        cmd = 'home-manager switch --flake'
    else:
        typer.secho('could not infer system type.', fg=Colors.ERROR.value)
        raise typer.Abort()
    flake = [f'{REMOTE_FLAKE}#{host}'] if remote else [f'{DOTFILE.get_flake()}#{host}']
    flags = ['--impure']
    if debug:
        flags.append('--show-trace')
        flags.append('-L')
    run_cmd(cmd.split() + flake + flags)


@app.command(help='cache the output environment of flake.nix')
@change_workdir
def cache(cache_name: str = 'shanyouli'):
    cmd = f"nix flake archive --json | jq -r '.path,(.inputs|to_entries[].value.path)' | cachix push {cache_name}"
    run_cmd(cmd.split(), shell=True)


@app.command(help='nix repl')
@change_workdir
def repl(
    pkgs: bool = typer.Option(False, help='import <nixpkgs>'),
    flake: bool = typer.Option(False, help='Automatically import build flake'),
):
    cmd = 'nix repl --expr '
    exarg = 'import <nixpkgs> {}' if pkgs else None
    if flake:
        flake_src = f'(builtins.getFlake \\"{os.getcwd()}\\")'
        if exarg:
            exarg = exarg + ' // ' + flake_src
        else:
            exarg = flake_src + f'.{PLATFORM.value}.\\"{DEFAULT_HOST}\\"'
    cmd = cmd + '"' + exarg + '"' if exarg else cmd + 'builtins'
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


@app.command(help='Reinitialize darwin', hidden=PLATFORM != FlakeOutputs.DARWIN)
def init(
    host: str = typer.Argument(
        DEFAULT_HOST, help='the hostname of the configuration to build'
    ),
    dry_run: bool = typer.Option(False, help='Test the result of init'),
):
    if PLATFORM != FlakeOutputs.DARWIN:
        typer.secho('command is only supported on macos.')
        raise typer.Abort()
    nixgc = NixGc(dry_run=dry_run, default='default')
    nixgc.clear_remove_default()
    if not dry_run:
        # sudo nix upgrade-nix -p /nix/var/nix/profiles/default
        run_cmd(
            [
                'sudo',
                'nix',
                'upgrade-nix',
                '-p',
                '/nix/var/nix/profiles/default',
                '--keep-outputs',
                '--keep-derivations',
                '--experimental-features',
                '"nix-command flakes"',
            ]
        )
    nixgc.clear_remove_default(True)
    nixgc.run()
    if not dry_run:
        bootstrap(host=host, darwin=True, remote=False)


if __name__ == '__main__':
    app()
