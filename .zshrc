# 環境変数の設定
export LANG=ja_JP.UTF-8
export GOENV_ROOT="$HOME/.goenv"
export PYENV_ROOT="$HOME/.pyenv"
export NARGO_HOME="$HOME/.nargo"

# PATH の設定。冗長な部分を削除し、一箇所にまとめる。
export PATH="/opt/homebrew/bin:$HOME/.huff/bin:$HOME/.nodebrew/current/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin:/usr/local/bin:$GOENV_ROOT/bin:$PYENV_ROOT/shims:$HOME/flutter/bin:$HOME/.foundry/bin:$HOME/.cargo/bin:$HOME/.aztec/bin:$NARGO_HOME/bin"

# rbenv, goenv, pyenv の初期化
eval "$(rbenv init -)"
eval "$(goenv init -)"
eval "$(pyenv init -)"

# ヒストリの設定
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000

# 補完の設定
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..
# sudo の後ろでコマンド名を補完する

# オプションの設定
setopt print_eight_bit no_beep no_flow_control interactive_comments auto_cd auto_pushd pushd_ignore_dups magic_equal_subst share_history hist_ignore_all_dups hist_save_nodups hist_ignore_space hist_reduce_blanks auto_menu

# エイリアスの設定
alias la='ls -al'
alias ll='ls -l'
alias mkdir='mkdir -p'
alias sudo='sudo '  # sudo の後のコマンドでエイリアスを有効にする
alias -g L='| less'
alias -g G='| grep'

# Prezto の読み込み
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
