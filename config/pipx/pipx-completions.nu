#!/usr/bin/env nu

def "nu-complete pipx packages" [] {
    ^pipx list --short | lines --skip-empty | parse '{name} {version}' | get name
}

def "nu-complete pipx env" [] noting -> list<string> {
    ["PIPX_HOME" "PIPX_BIN_DIR" "PIPX_MAN_DIR" "PIPX_SHARED_LIBS" "PIPX_LOCAL_VENVS"
     "PIPX_LOG_DIR" "PIPX_TRASH_DIR" "PIPX_VENV_CACHEDIR" "PIPX_DEFAULT_PYTHON" "USE_EMOJI"]
}

export extern "pipx" [
    --help(-h)       # show this help message and exit
    --quieet(-q)     # Give less output. May be used mnultiple times correspoding to the WARNING,ERROR,and CRITICAL logging levels.
    --version        # print version and exit
    --verbose(-v)    # Print version and exit
]

# Installa package
export extern "pipx install" [
    ...package_spec: string     # package name(s) or pip installation spec(s)
    --include-deps           # Include apps of dependent packages
    --force(-f)              # Modify existing virtual environment and files in PIPX_BIN_DIR and PIPX_MAN_DIR
    --suffix: string         # Optional suffix for virtual environment and executable name
    --python: string         # Python to install with. Specified python version. Path or executable
    --preinstall: string     # Optional packages to be installed into the Virtual Environment before installing the main package.
    --system-site-packages   # Give the virtual environment access to the system site-packages dir.
    --index-url(-i): string  # Base URL of Python Package Index
    --editable(-e)           # Install a project in editable mode
    --pip-args: string       # Arbitrary pip arguments to pass directly to pip install/upgrade commands
]

# Uninstalls inject packages from an existing pipx-managed virtual Environment
export extern "pipx uninject" [
    package: string           # Name of the existing pipx-managed Virtual Environment to inject into
    ...dependencies: string   # the package names to uninject from the Virtual Environment
    --leave-deps             # Only uninstall the main injected package but leave its dependencies installed.
]

# installs packages to an existing pipx-managed virtual environment
export extern "pipx inject" [
    package: string         # Name of the existing pipx-managed Virtual Environment to inject into
    ...dependencies: string # the packages to inject into the Virtual Environment--either package name or pip package spec
    --include-apps           # Add apps from the injected packages onto your PATH and expose their manual pages
    --include-deps           # Include apps of dependent packages. Implies --include-apps
    --system-site-packages   # Give the virtual environment access to the system site-packages dir.
    --index-url(-i): string  # Base URL of Python Package Index
    --editable(-e)           # Install a project in editable mode
    --pip-args: string       # Arbitrary pip arguments to pass directly to pip install/upgrade commands
    --force(-f)              # Modify existing virtual environment and files in PIPX_BIN_DIR and PIPX_MAN_DIR
    --with-suffix            # Add the suffix (if given) of the Virtual Environment to the packages to inject
]

# Upgrade a package in a pipx-managed Virtual Environment
export extern "pipx upgrade" [
    package: string@"nu-complete pipx packages"     # update pkacages
    --include-injected                              # Also upgrade packages injected into the main app's environment
    --system-site-packages   # Give the virtual environment access to the system site-packages dir.
    --index-url(-i): string  # Base URL of Python Package Index
    --editable(-e)           # Install a project in editable mode
    --pip-args: string       # Arbitrary pip arguments to pass directly to pip install/upgrade commands
    --force(-f)              # Modify existing virtual environment and files in PIPX_BIN_DIR and PIPX_MAN_DIR
]

# Upgrade all packages within their virtual environments
export extern "pipx upgrade-all" [
    --include-injected                              # Also upgrade packages injected into the main app's environment
    --skip: string@"nu-complete pipx packages"      # skip these packages
    --force(-f)              # Modify existing virtual environment and files in PIPX_BIN_DIR and PIPX_MAN_DIR
]

# Uninstall a packages
export extern "pipx uninstall" [
    package: string@"nu-complete pipx packages"     # uninstall package name
]
# Uninstall all Packages
export extern "pipx uninstall-all" [ ]

# Reinstalls a package
export extern "pipx reinstall" [
    package: string@"nu-complete pipx packages"     # reinstall package name
    --python: string                                # Specified version, use path
]

# Reinstall all packages
export extern "pipx reinstall-all" [
    --python: string                                # Specified version, use path
    --skip:   string@"nu-complete pipx packages"    # skip these packages
]

# list packages and apps installed with pipx
export extern "pipx list" [
    --include-injected      # show packages injected into the main app's environment
    --json                  # Output rich data in json format.
    --short                 # List packages only.
    --skip-maintenance      # Skip maintenance tasks.
]

# Donload the latest version of a package to a temporary virtual environment, the run it
export extern "pipx run" [
    --no-cache           # Do not re-use cached virtual environment if it exists
    --path               # Interpret app name as a local path
    --pypackages         # Require app to be run from local __pypackages__ directory
    --spec: string       # The package name or specific installation source passed to pip.
    --python: string                                # Specified version, use path
    --system-site-packages   # Give the virtual environment access to the system site-packages dir.
    --index-url(-i): string  # Base URL of Python Package Index
    --editable(-e)           # Install a project in editable mode
    --pip-args: string       # Arbitrary pip arguments to pass directly to pip install/upgrade commands
]

# run pip in an existing pipx-managed Virtual Environment
export extern "pipx runpip" [
    package: string@"nu-complete pipx packages"     # name of the existing pipx-managed Virtual Environment to run
    pipargs: string                                 # Arguments to forward to pip command
]

# Ensure directories necessary for pipx operation are in your PATH
export extern "pipx ensurepath" [
    --force(-f)                     # Add text your shell's config file even if it looks like your PATH already contaions paths
]

# print a list of environment variables and paths used by pipx.
export extern "pipx environment" [
    --value(-v): string@"nu-complete pipx env"           # Print the value of the variable.
]

# print instructions on enabling shell completions for pipx
export extern "pipx completions" []

