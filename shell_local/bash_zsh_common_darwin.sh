# ▄ ▄▖▄▖▄▖▖ ▖  ▄ ▄▖▄▖▖▖      ▄▖▄▖▖▖  ▄▖▄▖▖  ▖▖  ▖▄▖▖ ▖  ▄ ▄▖▄▖▖  ▖▄▖▖ ▖
# ▙▘▙▖▌ ▐ ▛▖▌  ▙▘▌▌▚ ▙▌  ▟▖  ▗▘▚ ▙▌  ▌ ▌▌▛▖▞▌▛▖▞▌▌▌▛▖▌  ▌▌▌▌▙▘▌▞▖▌▐ ▛▖▌
# ▙▘▙▖▙▌▟▖▌▝▌  ▙▘▛▌▄▌▌▌  ▝   ▙▖▄▌▌▌  ▙▖▙▌▌▝ ▌▌▝ ▌▙▌▌▝▌  ▙▘▛▌▌▌▛ ▝▌▟▖▌▝▌

########################################
#  Aliases                             #
########################################

# BBEdit
alias bb='open -a /Applications/BBEdit.app'

# Beyond Compare
alias bcomp='/Applications/Beyond\ Compare.app/Contents/MacOS/bcomp -nobackups -ro'


########################################
#  Functions                           #
########################################

# Open man pages in a GUI
function gman () {
  man -t $1 | open -a /System/Applications/Preview.app -f
}

# Open markdown files in Marked 2
#     see http://jblevins.org/log/marked-2-command
function mark {
  md_file=$1
  marked_exec="Marked 2"

  if [ $md_file ]; then
    open -a "${marked_exec}" $md_file;
  else
    open -a "${marked_exec}"
  fi
}


########################################
#  Homebrew Init                       #
########################################

eval "$(/opt/homebrew/bin/brew shellenv)"


########################################
#  Python                              #
########################################

# uv tools executable path
pathmunge "${HOME}/.local/bin"


########################################
#  macOS Ruby                          #
########################################

key="  - USER INSTALLATION DIRECTORY: "
value=$(gem env | grep "^$key")
export GEM_HOME="${value#$key}"
pathmunge "$GEM_HOME/bin"


########################################
#  OrbStack                            #
########################################

# OrbStack's init script is not idempotent in regards to $PATH
if ! echo "$PATH" | grep -Eq "orbstack" ; then
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi


########################################
#  STM32 Programming Settings          #
########################################

export STM32_PRG_PATH=/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin

# ▄▖▖ ▖▄   ▄ ▄▖▄▖▖▖      ▄▖▄▖▖▖  ▄▖▄▖▖  ▖▖  ▖▄▖▖ ▖  ▄ ▄▖▄▖▖  ▖▄▖▖ ▖
# ▙▖▛▖▌▌▌  ▙▘▌▌▚ ▙▌  ▟▖  ▗▘▚ ▙▌  ▌ ▌▌▛▖▞▌▛▖▞▌▌▌▛▖▌  ▌▌▌▌▙▘▌▞▖▌▐ ▛▖▌
# ▙▖▌▝▌▙▘  ▙▘▛▌▄▌▌▌  ▝   ▙▖▄▌▌▌  ▙▖▙▌▌▝ ▌▌▝ ▌▙▌▌▝▌  ▙▘▛▌▌▌▛ ▝▌▟▖▌▝▌
