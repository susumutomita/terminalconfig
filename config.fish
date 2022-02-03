#view
set -g theme_display_date yes
set -g theme_date_format "+%F %H:%M"
set -g theme_display_git_default_branch yes
set -g theme_color_scheme dark

#path
set -x PATH $HOME/.nodebrew/current/bin $PATH
export LANG=ja_JP.UTF-8
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin:/opt/homebrew/bin:/opt/homebrew/sbin
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"

#init
eval (goenv init - | source)
eval (pyenv init - | source)
#peco setting
set fish_plugins theme peco

########################################
# エイリアス
alias la='ls -al'
alias ll='ls -l'
alias mkdir='mkdir -p'
# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

function fish_user_key_bindings
  bind \cw peco_select_history
end
