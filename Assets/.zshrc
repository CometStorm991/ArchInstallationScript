# Path to your oh-my-zsh installation.
export ZSH="$ZDOTDIR/ohMyZsh"

alias gt="gio trash"

setopt GLOB_DOTS

ZSH_THEME=""

plugins=(
    git
    sudo
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# zsh-syntax-highlighting
# Disables underlining paths
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#404040"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source $ZSH/oh-my-zsh.sh

bindkey -v

. /usr/share/powerline/bindings/zsh/powerline.zsh
source <(fzf --zsh)
