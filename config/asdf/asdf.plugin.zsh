#!/usr/bin/env zsh

#  Mnemonic [V]ersion [M]anager [I]nstall
asdf-vmi() {
    local lang=${1}
    if [[ ! $lang ]]; then
        lang=$(asdf plugin-list | fzf)
    fi

    if [[ $lang ]]; then
        local versions=$(asdf list-all $lang | fzf --tac --no-sort --multi)
        if [[ $versions ]]; then
            for version in $(echo $versions); do
                asdf install $lang $version
            done
        fi
    fi
}
# Mnemonic [V]ersion [M]anager [C]lean
asdf-vmc() {
    local lang=${1}
    if [[ ! $lang ]]; then
        lang=$(asdf plugin-list | fzf)
    fi

    if [[ $lang ]]; then
        local versions=$(asdf list $lang | fzf --multi)
        if [[ $versions ]]; then
            for version in $(echo $versions); do
                asdf uninstall $lang $version
            done
        fi
    fi
}

asdf-shell() {
    local lang=${1}
    if [[ ! $lang ]]; then
        lang=$(asdf plugin list | fzf)
    fi
    if [[ $lang ]]; then
        local version=$(echo $(asdf list $lang | fzf))
        if [[ $version == "*"* ]]; then
            echo "Asdf unset $lang version"
            asdf shell $lang --unset
        else
            asdf shell $lang $version
        fi
    fi
}
if (( $+commands[direnv] )) && [[ -e $ASDF_DATA_DIR/plugins/direnv ]]; then
    asdf() {
        if [[ $1 == "local" ]] || [[ $1 == "shell" ]]; then
            command asdf direnv $@
        else
            command asdf $@
        fi
    }
fi
