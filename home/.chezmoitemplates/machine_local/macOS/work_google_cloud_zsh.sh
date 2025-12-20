# ▄ ▄▖▄▖▄▖▖ ▖  ▄▖▄▖▄▖▄▖▖ ▄▖  ▄▖▖ ▄▖▖▖▄   ▄▖▄▖▄▖▖ ▄▖
# ▙▘▙▖▌ ▐ ▛▖▌  ▌ ▌▌▌▌▌ ▌ ▙▖  ▌ ▌ ▌▌▌▌▌▌  ▐ ▌▌▌▌▌ ▚
# ▙▘▙▖▙▌▟▖▌▝▌  ▙▌▙▌▙▌▙▌▙▖▙▖  ▙▖▙▖▙▌▙▌▙▘  ▐ ▙▌▙▌▙▖▄▌

export CLOUDSDK_PYTHON=$(uv python dir)/cpython-3.15.0a2-macos-aarch64-none/bin/python

export HOMEBREW_GITHUB_API_TOKEN=<ITS_A_SECRET>


########################################
# tgenv                                #
########################################

PATH="$HOME/.tgenv/bin:$PATH"
export TGENV_ARCH=arm64


########################################
# Artirfacctory Auth                   #
########################################

# If ~/.terraform.d/credentials.tfrc.json doesn't exist,
# you need to cd to the terragrunt-repo and run this:
#     terraform login sifi.jfrog.io
# then log into Artifactory with Okta when the browser opens.
export TG_TF_REGISTRY_TOKEN=$(jq -r '.credentials["sifi.jfrog.io"].token' ~/.terraform.d/credentials.tfrc.json)


########################################
# Google Cloud SDK Path                #
########################################

# The next line updates PATH for the Google Cloud SDK.
if [ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/completion.zsh.inc"; fi

# ▄▖▖ ▖▄   ▄▖▄▖▄▖▄▖▖ ▄▖  ▄▖▖ ▄▖▖▖▄   ▄▖▄▖▄▖▖ ▄▖
# ▙▖▛▖▌▌▌  ▌ ▌▌▌▌▌ ▌ ▙▖  ▌ ▌ ▌▌▌▌▌▌  ▐ ▌▌▌▌▌ ▚
# ▙▖▌▝▌▙▘  ▙▌▙▌▙▌▙▌▙▖▙▖  ▙▖▙▖▙▌▙▌▙▘  ▐ ▙▌▙▌▙▖▄▌
