#!/usr/bin/env sh

use_asdf() {
    if asdf plugin list | grep direnv >/dev/null 2>&1; then
        source_env "$(asdf direnv envrc "$@")"
    else
        log_status "No direnv plug-ins are installed. Please run command 'asdf plugin add direnv'!!"
        exit 1
    fi
}
