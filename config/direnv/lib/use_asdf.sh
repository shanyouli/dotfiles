#!/usr/bin/env sh

use_asdf() {
    if asdf plugin list | grep direnv 2>&1 >/dev/null; then
        source_env "$(asdf direnv envrc "$@")"
    else
        log_status "No direnv plug-ins are installed. Please run command 'asdf plugin add direnv'!!"
        exit 1
    fi
}
