####################
# Aliases          #
####################
alias src='cd $HOME/src'
alias hl='history | sed -e '"'"'s/^\[ \\t\]\*//'"'"' | sort -rn | less'

# BBEdit
alias bb='open -a /Applications/BBEdit.app'

# Beyond Compare
alias bcomp='/Applications/Beyond\ Compare.app/Contents/MacOS/bcomp -nobackups -ro'

# eza: the ls and exa replacement
alias ls='eza --icons -a --group-directories-first'
alias t='eza --tree'
alias tree='eza --tree --long'

# tmux
#alias ta='tmux attach -t'

# git
alias gg='git status -s'
alias gdiff='git diff --no-ext-diff'
alias gwdiff='git diff --no-ext-diff --word-diff=color'
alias gdt='git difftool'
alias gs='git status'
alias ga='git add'
alias gc='git commit'


####################
# Exports          #
####################
export TERM=xterm-256color


####################
# Functions        #
####################
# mkdir and cd into it
function md () { mkdir -p "$@" && eval cd "\"\$$#\""; }

# pretty print $PATH
function path () { echo "${PATH}" | tr : '\n'; }

# show all zsh completions
function zsh-completions () {
  for command completion in ${(kv)_comps:#-*(-|-,*)}
  do
    printf "%-32s %s\n" $command $completion
  done | sort
}

# function to display all color combos
function showColors {
 for STYLE in 0 1 2 3 4 5 6 7; do
   for FG in 30 31 32 33 34 35 36 37; do
     for BG in 40 41 42 43 44 45 46 47; do
       CTRL="\033[${STYLE};${FG};${BG}m"
       echo -en "${CTRL}"
       echo -n "${STYLE};${FG};${BG}"
       echo -en "\033[0m"
     done
     echo
   done
   echo
 done
}


###################
# color man pages #
###################
cman() {
    env \
	LESS_TERMCAP_mb=$(printf "\e[1;31m") \
	LESS_TERMCAP_md=$(printf "\e[1;31m") \
	LESS_TERMCAP_me=$(printf "\e[0m") \
	LESS_TERMCAP_se=$(printf "\e[0m") \
	LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	LESS_TERMCAP_ue=$(printf "\e[0m") \
	LESS_TERMCAP_us=$(printf "\e[1;32m") \
	man "$@"
}


####################
#  Local Settings  #
####################
[[ -r ~/.zsh_local ]] && source ~/.zsh_local


####################
# Starship         #
####################
eval "$(starship init zsh)"


########################
# useful prompt emojis #
########################
## 🤡 💩 💀 ☠️  👉 🖖 🖕 💋 👄 👁 🐼 🐒 🙊 🦋 🐙 🍀 🍄 🐚 🌸 🌼 🌝 🌜 ⭐ 🌟 ✨ ⚡ ☄️ 
##  💥 🔥 🌪  🌈 🌮 🍣 🍥 🥃 🍸 🏆 🎹 🥁 🎸 🚀 🚦 🚥 🕹  🔒 🔓 💢 🔶 🔷 🎲
