#!/usr/bin/env zsh

#@https://github.com/alexherbo2/dotfiles/blob/master/.bashrc
#@https://blog.binchen.org/posts/my-git-set-up/
alias g='git'

alias gl1="git log --pretty=format:'%C(yellow)%h%Creset %ad %s %Cred(%an)%Creset' --date=short --decorate --graph"
alias gu='git stash && git pull --rebase && git stash pop'
alias gst='git status'

alias ga='git add'
alias ga.='git add .'
alias gau='git add -u'

# 切换为一个已存在的分支
alias gb='git branch -a | fzf | cut -c 3- | xargs git switch'
alias gbb='git switch -' # 返回上一个branch

# 如果该分支不存在则创建并切换到该分支，反之，直接切换为该分支
function gbc() {
    git switch $1 || git switch -c $1
}

alias gc1='git clone --depth 1'
