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
  mandoc -T pdf "$(/usr/bin/man -w $@)" | open -fa Preview
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

function watchsize() {

  target="$1"

  # Notes on heredocs:
  #   * The '-' after "<<" removes leading tabs from the heredoc, but only tabs.
  #   * Quoting the delimiter, 'AWKDOC', prevents shell substitution.

  # The awk_script lines are tab indented.
  # Do not remove the tabs!!!
  # That will break the heredoc!
	awk_script=$(cat <<-'AWKDOC'
		{
			filesize = $1
			filename = $2
			sizefmtd = sprintf("%'\''d MB", filesize)
			print sizefmtd, filename
		}
		AWKDOC
	)

  # macOS du is weird.
  # macOS block size is 512K which doubles file sizes.
  # The '-k' sets it to 1024 bytes.
  watch -n 1 "du -k \"${target}\" | gawk '{ ${awk_script} }'"
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


# ▄▖▖ ▖▄   ▄ ▄▖▄▖▖▖      ▄▖▄▖▖▖  ▄▖▄▖▖  ▖▖  ▖▄▖▖ ▖  ▄ ▄▖▄▖▖  ▖▄▖▖ ▖
# ▙▖▛▖▌▌▌  ▙▘▌▌▚ ▙▌  ▟▖  ▗▘▚ ▙▌  ▌ ▌▌▛▖▞▌▛▖▞▌▌▌▛▖▌  ▌▌▌▌▙▘▌▞▖▌▐ ▛▖▌
# ▙▖▌▝▌▙▘  ▙▘▛▌▄▌▌▌  ▝   ▙▖▄▌▌▌  ▙▖▙▌▌▝ ▌▌▝ ▌▙▌▌▝▌  ▙▘▛▌▌▌▛ ▝▌▟▖▌▝▌
