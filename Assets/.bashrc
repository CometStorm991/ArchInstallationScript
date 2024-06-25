[[ $- != *i* ]] && return

export PATH="$HOME/Dev/Programs/CEdev/bin:$PATH"
export PATH="$HOME/Dev/Programs/IntelliJIDEA/bin:$PATH"
export PATH="$HOME/Dev/Programs/PyCharm/bin:$PATH"
export PATH="$HOME/Dev/Programs/CLion/bin:$PATH"
export PATH="$HOME/Dev/Programs/WebStorm/bin:$PATH"
export PATH="$HOME/Dev/Programs/RustRover/bin:$PATH"

export PATH="$HOME/Bin:$PATH"

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# PS1='[\u@\h \W]\$ '
BACKGROUND_1="\[$(tput setab 235)\]"
FOREGROUND_1="\[$(tput setaf 235)\]"
RESET="\[$(tput sgr0)\]"
PS1="${RESET}${BACKGROUND_1} \W ${RESET}${FOREGROUND_1}${RESET} ${RESET}"
