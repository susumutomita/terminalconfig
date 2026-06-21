export LANG=ja_JP.UTF-8

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
# vim / vi と打ったら Neovim を起動する
alias vim='nvim'
alias vi='nvim'

fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/opt/pcsc-lite/bin:$PATH"
export PATH="/opt/homebrew/opt/pcsc-lite/sbin:$PATH"

# 削除事故対策: 対話シェルでは rm → ゴミ箱, 本当に消したいときは \rm か rrm
alias rm='trash'
alias rrm='safe-rm'   # safe-rm は ~/.config/safe-rm/conf の保護パスを拒否する rm ラッパ
