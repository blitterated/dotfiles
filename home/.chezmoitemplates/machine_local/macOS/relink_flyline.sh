# The current Homebrew installer for flyline does not create a soft link to the .dylib
# in /opt/homebrew/lib. This script will (re)create that link regardless of a prexisting
# link.
relink_flyline () {
  # The command line invocation for flyline.
  local flyline_invocation="flyline"

  # Get the version number of the most recently installed version of flyline.
  local flyline_version="$(brew list --versions flyline)"
  local flyline_version="${flyline_version/flyline /}"

  # Location of Homebrew installs' links to libs.
  local homebrew_lib_dir="${HOMEBREW_PREFIX}/lib"

  # Source and target for link.
  local source_lib="/opt/homebrew/Cellar/flyline/${flyline_version}/lib/bash/flyline"
  local target_lib="${homebrew_lib_dir}/flyline.dylib"

  # Unregister flyline command before deleting soft link.
  if command -v "${flyline_invocation}" &> /dev/null; then
    echo "Unregistering flyline from bash."
    enable -d "flyline"
  fi

  # Always delete link before another soft linking.
  if [ -L "${target_lib}" ]; then
    echo "Removing flyline.dylib link to: $(readlink "${target_lib}")"
    rm "${target_lib}"
  fi

  # Soft link flyline shared lib to $homebrew_lib_dir.
  echo "Linking '${source_lib}' to '${target_lib}'"
  ln -s "${source_lib}" "${target_lib}"

  # Enable flyline command in bash.
  echo "Registering flyline in bash."
  enable -f "${target_lib}" "${flyline_invocation}"

  # Test invocability
  if ! command -v "${flyline_invocation}" &> /dev/null; then
    echo "Something bad happened. ${flyline_invocation} is not invocable."
    return 1
  fi

  # Show happy, green SUCCESS!
  echo -e "\n\e[32mSUCCESS!\e[0m\n"

  # Conveniently dump the rc configuration for flyline to STDOUT.
  cat <<-RC_CODE
		Add the following to your bash startup file:
		enable -f "${target_lib}" "${flyline_invocation}"
		RC_CODE
}
