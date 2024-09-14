# CLI

**Usage**:

```console
$ [OPTIONS] COMMAND [ARGS]...
```

**Options**:

* `--install-completion`: Install completion for the current shell.
* `--show-completion`: Show completion for the current shell, to copy it or customize the installation.
* `--help`: Show this message and exit.

**Commands**:

* `bootstrap`: builds an initial configuration
* `build`: builds the specified flake output; infers...
* `cache`: cache the output environment of flake.nix
* `clean`: remove previously built configurations and...
* `disksetup`: configure disk setup for nix-darwin
* `fmt`: run formatter on all files
* `gc`: run garbage collection on unused nix store...
* `git-pull`: pull changes from remote repo
* `git-push`: update remote repo with current changes
* `refresh`: Redirect the bundle id to specify the version
* `search`: search pacakge
* `switch`: builds and activates the specified flake...
* `update`: update all flake inputs or optionally...

## `bootstrap`

builds an initial configuration

**Usage**:

```console
$ bootstrap [OPTIONS] [HOST]
```

**Arguments**:

* `[HOST]`: the hostname of the configuration to build

**Options**:

* `--nixos / --no-nixos`: [default: False]
* `--darwin / --no-darwin`: [default: False]
* `--home-manager / --no-home-manager`: [default: False]
* `--help`: Show this message and exit.

## `build`

builds the specified flake output; infers correct platform to use if not specified

**Usage**:

```console
$ build [OPTIONS] [HOST]
```

**Arguments**:

* `[HOST]`: the hostname of the configuration to build

**Options**:

* `--pull / --no-pull`: whether to fetch current changes from the remote  [default: False]
* `--nixos / --no-nixos`: [default: False]
* `--darwin / --no-darwin`: [default: False]
* `--home-manager / --no-home-manager`: [default: False]
* `--help`: Show this message and exit.

## `cache`

cache the output environment of flake.nix

**Usage**:

```console
$ cache [OPTIONS]
```

**Options**:

* `--cache-name TEXT`: [default: shanyouli]
* `--help`: Show this message and exit.

## `clean`

remove previously built configurations and symlinks from the current directory

**Usage**:

```console
$ clean [OPTIONS]
```

**Options**:

* `--help`: Show this message and exit.

## `disksetup`

configure disk setup for nix-darwin

**Usage**:

```console
$ disksetup [OPTIONS]
```

**Options**:

* `--help`: Show this message and exit.

## `fmt`

run formatter on all files

**Usage**:

```console
$ fmt [OPTIONS]
```

**Options**:

* `--help`: Show this message and exit.

## `gc`

run garbage collection on unused nix store paths

**Usage**:

```console
$ gc [OPTIONS]
```

**Options**:

* `-d, --delete-older-than [AGE]`: specify minimum age for deleting store paths
* `--dry-run / --no-dry-run`: test the result of garbage collection  [default: False]
* `--help`: Show this message and exit.

## `git-pull`

pull changes from remote repo

**Usage**:

```console
$ git-pull [OPTIONS]
```

**Options**:

* `--help`: Show this message and exit.

## `git-push`

update remote repo with current changes

**Usage**:

```console
$ git-push [OPTIONS]
```

**Options**:

* `--help`: Show this message and exit.

## `refresh`

Redirect the bundle id to specify the version

**Usage**:

```console
$ refresh [OPTIONS]
```

**Options**:

* `--help`: Show this message and exit.

## `search`

search pacakge

**Usage**:

```console
$ search [OPTIONS] [PKG] [MAX_NUM]
```

**Arguments**:

* `[PKG]`: package name
* `[MAX_NUM]`: search max num  [default: 100]

**Options**:

* `--help`: Show this message and exit.

## `switch`

builds and activates the specified flake output; infers correct platform to use if not specified

**Usage**:

```console
$ switch [OPTIONS] [HOST]
```

**Arguments**:

* `[HOST]`: the hostname of the configuration to build

**Options**:

* `--pull / --no-pull`: whether to fetch current changes from the remote  [default: False]
* `--nixos / --no-nixos`: [default: False]
* `--darwin / --no-darwin`: [default: False]
* `--home-manager / --no-home-manager`: [default: False]
* `--help`: Show this message and exit.

## `update`

update all flake inputs or optionally specific flakes

**Usage**:

```console
$ update [OPTIONS]
```

**Options**:

* `-f, --flake [FLAKE]`: specify an individual flake to be updated
* `--commit / --no-commit`: commit the updated lockfile  [default: False]
* `--help`: Show this message and exit.
