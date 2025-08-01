# ▄ ▄▖▄▖▄▖▖ ▖  ▄ ▄▖▄▖▖▖      ▄▖▄▖▖▖  ▄▖▄▖▖  ▖▖  ▖▄▖▖ ▖
# ▙▘▙▖▌ ▐ ▛▖▌  ▙▘▌▌▚ ▙▌  ▟▖  ▗▘▚ ▙▌  ▌ ▌▌▛▖▞▌▛▖▞▌▌▌▛▖▌
# ▙▘▙▖▙▌▟▖▌▝▌  ▙▘▛▌▄▌▌▌  ▝   ▙▖▄▌▌▌  ▙▖▙▌▌▝ ▌▌▝ ▌▙▌▌▝▌

########################################
#  Variables                           #
########################################

export TERM=xterm-256color
export EDITOR="nvim"
export PAGER="less"
export BROWSER="brave"


########################################
# Aliases                              #
########################################

alias src='cd $HOME/src'
alias hl='history | sed -e '"'"'s/^\[ \\t\]\*//'"'"' | sort -rn | less'
alias cz='chezmoi --verbose '


# eza: the ls and exa replacement
alias ls='eza --icons -a --group-directories-first'
alias t='eza --tree'
alias tree='eza --tree --long'


# git
alias gg='git status -s'
alias gdiff='git diff --no-ext-diff'
alias gwdiff='git diff --no-ext-diff --word-diff=color'
alias gdt='git difftool'
alias gs='git status'
alias ga='git add'
alias gc='git commit'


########################################
# Functions                            #
########################################

# Make path additions idempotent to sourcing rc files
pathmunge () {
  if ! echo "$PATH" | grep -Eq "(^|:)$1($|:)" ; then
    if [ "$2" = "prepend" ] ; then
      PATH="$1:$PATH"
    else
      PATH="$PATH:$1"
    fi
  fi
}


# mkdir and cd into it
function md () { mkdir -p "$@" && eval cd "\"\$$#\""; }


# Pretty print $PATH
function path () { echo "${PATH}" | tr ':' '\n'; }


# Display all color combos
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


# psql prettifier
ppsql() {
  local TEMP_LESS=$LESS
  local TEMP_PAGER=$PAGER

  local PSQL_YELLOW=$(printf "\e[1;33m")
  local PSQL_LIGHT_CYAN=$(printf "\e[1;36m")
  local PSQL_NOCOLOR=$(printf "\e[0m")

  export LESS="-iMSx4 -FXR"

  PAGER="sed \"s/\([[:space:]]\+[0-9.\-]\+\)$/${PSQL_LIGHT_CYAN}\1$PSQL_NOCOLOR/;"
  PAGER+="s/\([[:space:]]\+[0-9.\-]\+[[:space:]]\)/${PSQL_LIGHT_CYAN}\1$PSQL_NOCOLOR/g;"
  PAGER+="s/|/$PSQL_YELLOW|$PSQL_NOCOLOR/g;s/^\([-+]\+\)/$PSQL_YELLOW\1$PSQL_NOCOLOR/\" 2>/dev/null  | less"
  export PAGER

  env psql "$@"

  [[ -z "$TEMP_LESS" ]] && unset LESS || export LESS=$TEMP_LESS
  [[ -z "$TEMP_PAGER" ]] && unset PAGER || export LESS=$TEMP_PAGER
}


# convenience function for generating rc file
# section headers using figlet
fighead () {
  local header_text="$(echo "$1" | tr '[:lower:]' '[:upper:]')"

  echo -e "BEGIN ${header_text}\nEND ${header_text}" | \
  figlet -w 200 -f miniwi | \
  while read -r ln; do echo "# ${ln}"; done
}


########################################
# bc                                   #
########################################

# http://superuser.com/questions/84949/dividing-with-gnus-bc
export BC_ENV_ARGS="-q $HOME/.bcrc"


########################################
# Colorize man pages                   #
########################################

cman() {
  local less_start_blink_mb=$'\E[1;31m'         # begin blinking                                 
  local less_start_bold_md=$'\E[1;31m'          # begin bold, $'\E[01;38;5;74m', $'\E[32m'
  local less_end_mode_me=$'\E[0m'               # end mode

  local less_start_reverse_so=$'\E[1;44;33m'    # begin standout-mode - info box, $'\E[38;5;246m', $'\E[36m'
  local less_end_reverse_se=$'\E[0m'            # end standout-mode

  local less_start_underline_us=$'\e[1;32m'     # begin underline, $'\E[4;31;5;146m'
  local less_end_underline_ue=$'\E[0m'          # end underline

  env \
	LESS_TERMCAP_mb="${less_start_blink_mb}" \
	LESS_TERMCAP_md="${less_start_bold_md}" \
	LESS_TERMCAP_me="${less_end_mode_me}" \
	LESS_TERMCAP_so="${less_start_reverse_so}" \
	LESS_TERMCAP_se="${less_end_reverse_se}" \
	LESS_TERMCAP_us="${less_start_underline_us}" \
	LESS_TERMCAP_ue="${less_end_underline_ue}" \
	man "$@"
}


########################################
# Load available secrets               #
########################################

[[ -r ~/.secrets ]] && source ~/.secrets


# ▄▖▖ ▖▄   ▄ ▄▖▄▖▖▖      ▄▖▄▖▖▖  ▄▖▄▖▖  ▖▖  ▖▄▖▖ ▖
# ▙▖▛▖▌▌▌  ▙▘▌▌▚ ▙▌  ▟▖  ▗▘▚ ▙▌  ▌ ▌▌▛▖▞▌▛▖▞▌▌▌▛▖▌
# ▙▖▌▝▌▙▘  ▙▘▛▌▄▌▌▌  ▝   ▙▖▄▌▌▌  ▙▖▙▌▌▝ ▌▌▝ ▌▙▌▌▝▌
