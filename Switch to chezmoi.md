# Switch to chezmoi for dotfile management

I'm currently using Gnu Stow as a dotfile manager. It's good, but it's more of a binary link farm manager than a dotfile manager. The requirement for Perl isn't my cup of tea, either, There's too many good Rust utilities these days.


## <a id="toc" />Table of Contents

* [Commit and push local changes in the dotfiles repo](#commit-push-local-repo)
    * [Check on `git status`](#local-git-status)
    * [Check the dates on modified and untracked files](#check-file-dates)
* [Iterate towards replacing links with dotfiles](#iterate-replacement)
    * [Search for links to the dotfiles repo from the home directory](#search-for-dotfile-links)
    * [Get dotfile links into into a bash array](#dotfile-array)
    * [Transform source and target paths](#transform-paths)
        * [Look up paths to link targets](#look-up-link-paths)
        * [Generate full path to target](#gen-full-target-path)
        * [View full file path in Markdown table](#md-full-target-path)
        * [Separate link filename from path and use `$HOME` instead of `~`](#link-name-path-home)
    * [Test copying target files and directories](#test-target-cp)
        * [Directory links](#test-target-cp-dir)
        * [File links](#test-target-cp-file)
    * [Double check generating `rm` and `cp` commands](#double-check-cp-rm)
* [Replace the Links](#replace-links)
    * [Capture listing of current linked dotfiles](#capture-first-listing)
    * [Execute Replacement](#execute-replace)
    * [Final check](#final-check)
* [Prepare dotfiles repo for chezmoi](#prep-repo)
    * [Tag latest commit](#tag-last-commit)
    * [Push tag to origin](#push-tag)
    * [Move current dotfiles repo](#move-repo)
    * [Create an orphan branch](#create-orphan-branch)
    * [Create a branch for chezmoi](#create-chezmoi-branch)
    * [Transform dotfiles file hierarchy for chezmoi](#transform-file-hierarchy)
        * [Dotfile repo's current Gnu Stow structure](#stow-repo-structure)
        * [Repo transformation script](#transform-repo)
        * [Dotfile repo's new chezmoi structure](#chezmoi-repo-structure)

* [YOU ARE HERE](#current-progress-marker)

* [Set up chezmoi](#set-up-chezmoi)
    * [Install chezmoi on MBP](#install-chezmoi)
    * [Move current dotfiles in `$HOME` to a backup folder](#backup-current-dotfiles)
* [TODO](#todo)
    * [Post Migration Follow Ups](#post-migration-followups)


## <a id="commit-push-local-repo" />Commit and push local changes in the dotfiles repo

### <a id="local-git-status" />Check on `git status`

```sh
git status
```

```text
On branch main
Your branch is ahead of 'origin/main' by 4 commits.
  (use "git push" to publish your local commits)

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   nvim/.config/nvim/init.lua
        modified:   nvim/.config/nvim/lazy-lock.json
        modified:   zsh/.zshrc

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        __lib/
        nvim/.config/nvim/lua/linenumber-colors.lua
        nvim/.config/nvim/lua/plugins/lsp-config.lua

no changes added to commit (use "git add" and/or "git commit -a")
```

[⬆️](#toc)


### <a id="check-file-dates" />Check the dates on modified and untracked files

```sh
ls -l nvim/.config/nvim/init.lua
```

```text
.rw-r--r--@ 665 blitterated  6 Jun 00:01   nvim/.config/nvim/init.lua
```

```sh
ls -l nvim/.config/nvim/lazy-lock.json
```

```text
.rw-r--r--@ 1.2k blitterated  7 Jun 15:27   nvim/.config/nvim/lazy-lock.json
```

```sh
ls -l nvim/.config/nvim/lua/linenumber-colors.lua
```

```text
.rw-r--r--@ 162 blitterated  5 Jun 23:48   nvim/.config/nvim/lua/linenumber-colors.lua
```

```sh
ls -l nvim/.config/nvim/lua/plugins/lsp-config.lua
```

```text
.rw-r--r--@ 605 blitterated  7 Jun 15:27   nvim/.config/nvim/lua/plugins/lsp-config.lua
```

```sh
ls -l zsh/.zshrc
```

```text
.rw-r--r--@ 3.3k blitterated 10 Jun 00:42   zsh/.zshrc
```

Here they are in order.

| Date       | Time  | File                                         |
| ---------- | ----- | -------------------------------------------- |
| 06/05/2025 | 23:48 | nvim/.config/nvim/lua/linenumber-colors.lua  |
| 06/06/2025 | 00:01 | nvim/.config/nvim/init.lua                   |
| 06/07/2025 | 15:27 | nvim/.config/nvim/lazy-lock.json             |
| 06/07/2025 | 15:27 | nvim/.config/nvim/lua/plugins/lsp-config.lua |
| 06/10/2025 | 00:42 | zsh/.zshrc                                   |

[⬆️](#toc)


## <a id="iterate-replacement" />Iterate towards replacing links with dotfiles

### <a id="search-for-dotfile-links" />Search for links to the dotfiles repo from the home directory

It took a while with Gnu `find`, so I also tried timing it.

```sh
time find $HOME -type l -exec ls -l {} \; | grep '.dotfiles/'
```

```text
lrwxr-xr-x@ 1 blitterated  staff  30 May 18 18:32 ./.config/nvim -> ../.dotfiles/nvim/.config/nvim
lrwxr-xr-x@ 1 blitterated  staff  43 May 18 18:37 ./.config/starship.toml -> ../.dotfiles/starship/.config/starship.toml
lrwxr-xr-x@ 1 blitterated  staff  21 May 18 18:38 ./.gemrc -> .dotfiles/ruby/.gemrc
lrwxr-xr-x@ 1 blitterated  staff  25 May 18 18:43 ./.tmux.conf -> .dotfiles/tmux/.tmux.conf
lrwxr-xr-x@ 1 blitterated  staff  22 May 18 18:25 ./.bashrc -> .dotfiles/bash/.bashrc
lrwxr-xr-x@ 1 blitterated  staff  20 May 18 18:28 ./.zshrc -> .dotfiles/zsh/.zshrc
lrwxr-xr-x@ 1 blitterated  staff  34 May 18 22:01 ./.zsh_local -> .dotfiles/zsh_local.mac/.zsh_local
lrwxr-xr-x@ 1 blitterated  staff  23 May 18 18:28 ./.zprofile -> .dotfiles/zsh/.zprofile
lrwxr-xr-x@ 1 blitterated  staff  36 May 18 21:45 ./.bash_local -> .dotfiles/bash_local.mac/.bash_local
lrwxr-xr-x@ 1 blitterated  staff  31 May 18 18:30 ./.gitignore_global -> .dotfiles/git/.gitignore_global
lrwxr-xr-x@ 1 blitterated  staff  20 May 18 18:44 ./.vimrc -> .dotfiles/vim/.vimrc
lrwxr-xr-x@ 1 blitterated  staff  21 May 18 18:38 ./.pryrc -> .dotfiles/ruby/.pryrc
lrwxr-xr-x@ 1 blitterated  staff  28 May 18 18:25 ./.bash_profile -> .dotfiles/bash/.bash_profile
lrwxr-xr-x@ 1 blitterated  staff  22 May 18 18:44 ./.psqlrc -> .dotfiles/psql/.psqlrc
lrwxr-xr-x@ 1 blitterated  staff  24 May 18 18:30 ./.gitconfig -> .dotfiles/git/.gitconfig
lrwxr-xr-x@ 1 blitterated  staff  18 May 18 18:44 ./.bcrc -> .dotfiles/bc/.bcrc

find . -type l -exec ls -l {} \;
35.04s user
84.79s system
41% cpu
4:50.30 total

grep '.dotfiles/'
0.22s user
0.15s system
0% cpu
4:50.30 total
```

Here's the results in table form

| Type  | Link                      | Target                                       |
| ----- | ------------------------- | -------------------------------------------- |
| File  | `~/.bash_local`           | `~/.dotfiles/bash_local.mac/.bash_local`     |
| File    | `~/.bash_profile`         | `~/.dotfiles/bash/.bash_profile`             |
| File    | `~/.bashrc`               | `~/.dotfiles/bash/.bashrc`                   |
| File    | `~/.bcrc`                 | `~/.dotfiles/bc/.bcrc`                       |
| Dir     | `~/.config/nvim`          | `~/.dotfiles/nvim/.config/nvim`              |
| File    | `~/.config/starship.toml` | `~/.dotfiles/starship/.config/starship.toml` |
| File    | `~/.gemrc`                | `~/.dotfiles/ruby/.gemrc`                    |
| File    | `~/.gitconfig`            | `~/.dotfiles/git/.gitconfig`                 |
| File    | `~/.gitignore_global`     | `~/.dotfiles/git/.gitignore_global`          |
| File    | `~/.pryrc`                | `~/.dotfiles/ruby/.pryrc`                    |
| File    | `~/.psqlrc`               | `~/.dotfiles/psql/.psqlrc`                   |
| File    | `~/.tmux.conf`            | `~/.dotfiles/tmux/.tmux.conf`                |
| File    | `~/.vimrc`                | `~/.dotfiles/vim/.vimrc`                     |
| File    | `~/.zprofile`             | `~/.dotfiles/zsh/.zprofile`                  |
| File    | `~/.zsh_local`            | `~/.dotfiles/zsh_local.mac/.zsh_local`       |
| File    | `~/.zshrc`                | `~/.dotfiles/zsh/.zshrc`                     |


[⬆️](#toc)


### <a id="dotfile-array" />Get dotfile links into into a bash array

```sh
dotlinks=( '.bash_local' '.bash_profile' '.bashrc' '.bcrc' '.config/nvim' '.config/starship.toml'
           '.gemrc' '.gitconfig' '.gitignore_global' '.pryrc' '.psqlrc' '.tmux.conf' '.vimrc'
           '.zprofile' '.zsh_local' '.zshrc' )
```

Try out the array.

```sh
echo "${dotlinks[@]}"
```

```text
.bash_local .bash_profile .bashrc .bcrc .config/nvim .config/starship.toml .gemrc .gitconfig .gitignore_global .pryrc .psqlrc .tmux.conf .vimrc .zprofile .zsh_local .zshrc
```

Try out listing the array.

```sh
for link in "${dotlinks[@]}"; do echo "\"${link}\""; done
```

```text
".bash_local"
".bash_profile"
".bashrc"
".bcrc"
".config/nvim"
".config/starship.toml"
".gemrc"
".gitconfig"
".gitignore_global"
".pryrc"
".psqlrc"
".tmux.conf"
".vimrc"
".zprofile"
".zsh_local"
".zshrc"
```

[⬆️](#toc)

### <a id="transform-paths" />Transform source and target paths

#### <a id="look-up-link-paths" />Look up paths to link targets

```sh
for link in "${dotlinks[@]}"; do
  local target=$(readlink "$HOME/$link")
  echo "\"~/${link}\" -> "\"${target}\"
done
```

```text
"~/.bash_local" -> ".dotfiles/bash_local.mac/.bash_local"
"~/.bash_profile" -> ".dotfiles/bash/.bash_profile"
"~/.bashrc" -> ".dotfiles/bash/.bashrc"
"~/.bcrc" -> ".dotfiles/bc/.bcrc"
"~/.config/nvim" -> "../.dotfiles/nvim/.config/nvim"
"~/.config/starship.toml" -> "../.dotfiles/starship/.config/starship.toml"
"~/.gemrc" -> ".dotfiles/ruby/.gemrc"
"~/.gitconfig" -> ".dotfiles/git/.gitconfig"
"~/.gitignore_global" -> ".dotfiles/git/.gitignore_global"
"~/.pryrc" -> ".dotfiles/ruby/.pryrc"
"~/.psqlrc" -> ".dotfiles/psql/.psqlrc"
"~/.tmux.conf" -> ".dotfiles/tmux/.tmux.conf"
"~/.vimrc" -> ".dotfiles/vim/.vimrc"
"~/.zprofile" -> ".dotfiles/zsh/.zprofile"
"~/.zsh_local" -> ".dotfiles/zsh_local.mac/.zsh_local"
"~/.zshrc" -> ".dotfiles/zsh/.zshrc"
```

[⬆️](#toc)


#### <a id="gen-full-target-path" />Generate full path to target

Looks like the path returned by `readLink` returns the path relative to the target fromt the soft link file.
Scrape off everything from the start of the target path up to and including `.dotfiles/`, and then stitch together a full path to the file.

```sh
for link in "${dotlinks[@]}"; do
  local target="${HOME}/.dotfiles/$(readlink "$HOME/$link" | gsed -E -e "s/^.*?\.dotfiles\///")"
  echo "\"~/${link}\" -> "\"${target}\"
done
```

```text
"~/.bash_local" -> "/Users/blitterated/.dotfiles/bash_local.mac/.bash_local"
"~/.bash_profile" -> "/Users/blitterated/.dotfiles/bash/.bash_profile"
"~/.bashrc" -> "/Users/blitterated/.dotfiles/bash/.bashrc"
"~/.bcrc" -> "/Users/blitterated/.dotfiles/bc/.bcrc"
"~/.config/nvim" -> "/Users/blitterated/.dotfiles/nvim/.config/nvim"
"~/.config/starship.toml" -> "/Users/blitterated/.dotfiles/starship/.config/starship.toml"
"~/.gemrc" -> "/Users/blitterated/.dotfiles/ruby/.gemrc"
"~/.gitconfig" -> "/Users/blitterated/.dotfiles/git/.gitconfig"
"~/.gitignore_global" -> "/Users/blitterated/.dotfiles/git/.gitignore_global"
"~/.pryrc" -> "/Users/blitterated/.dotfiles/ruby/.pryrc"
"~/.psqlrc" -> "/Users/blitterated/.dotfiles/psql/.psqlrc"
"~/.tmux.conf" -> "/Users/blitterated/.dotfiles/tmux/.tmux.conf"
"~/.vimrc" -> "/Users/blitterated/.dotfiles/vim/.vimrc"
"~/.zprofile" -> "/Users/blitterated/.dotfiles/zsh/.zprofile"
"~/.zsh_local" -> "/Users/blitterated/.dotfiles/zsh_local.mac/.zsh_local"
"~/.zshrc" -> "/Users/blitterated/.dotfiles/zsh/.zshrc"
```

[⬆️](#toc)


#### <a id="md-full-target-path" />View full file path in Markdown table

Dump the above in a Markdown table.

```sh
echo '| Source | Target |'
echo '| ------ | ------ |'
for link in "${dotlinks[@]}"; do
  local target="${HOME}/.dotfiles/$(readlink "$HOME/$link" | gsed -E -e "s/^.*?\.dotfiles\///")"
  echo "| \`~/${link}\` | \`${target}\` |"
done
```

| Source | Target |
| ------ | ------ |
| `~/.bash_local` | `/Users/blitterated/.dotfiles/bash_local.mac/.bash_local` |
| `~/.bash_profile` | `/Users/blitterated/.dotfiles/bash/.bash_profile` |
| `~/.bashrc` | `/Users/blitterated/.dotfiles/bash/.bashrc` |
| `~/.bcrc` | `/Users/blitterated/.dotfiles/bc/.bcrc` |
| `~/.config/nvim` | `/Users/blitterated/.dotfiles/nvim/.config/nvim` |
| `~/.config/starship.toml` | `/Users/blitterated/.dotfiles/starship/.config/starship.toml` |
| `~/.gemrc` | `/Users/blitterated/.dotfiles/ruby/.gemrc` |
| `~/.gitconfig` | `/Users/blitterated/.dotfiles/git/.gitconfig` |
| `~/.gitignore_global` | `/Users/blitterated/.dotfiles/git/.gitignore_global` |
| `~/.pryrc` | `/Users/blitterated/.dotfiles/ruby/.pryrc` |
| `~/.psqlrc` | `/Users/blitterated/.dotfiles/psql/.psqlrc` |
| `~/.tmux.conf` | `/Users/blitterated/.dotfiles/tmux/.tmux.conf` |
| `~/.vimrc` | `/Users/blitterated/.dotfiles/vim/.vimrc` |
| `~/.zprofile` | `/Users/blitterated/.dotfiles/zsh/.zprofile` |
| `~/.zsh_local` | `/Users/blitterated/.dotfiles/zsh_local.mac/.zsh_local` |
| `~/.zshrc` | `/Users/blitterated/.dotfiles/zsh/.zshrc` |

[⬆️](#toc)


#### <a id="link-name-path-home" />Separate link filename from path and use `$HOME` instead of `~`

Switch from using `~` to `${HOME}` for the link's full path.
Also, separate the path from the filename.

```sh
echo '| Source Path | Source Filename | Target Full Path |'
echo '| ------ | ------ | ------ |'
for link in "${dotlinks[@]}"; do
  local source="${HOME}/${link}"
  local source_path="$(dirname "${source}")"
  local source_filename="$(basename "${source}")"
  local target="${HOME}/.dotfiles/$(readlink "$HOME/$link" | gsed -E -e "s/^.*?\.dotfiles\///")"
  echo "| \`${source_path}\` | \`${source_filename}\` | \`${target}\` |"
done
```

| Source Path | Source Filename | Target Full Path |
| ------ | ------ | ------ |
| `/Users/blitterated` | `.bash_local` | `/Users/blitterated/.dotfiles/bash_local.mac/.bash_local` |
| `/Users/blitterated` | `.bash_profile` | `/Users/blitterated/.dotfiles/bash/.bash_profile` |
| `/Users/blitterated` | `.bashrc` | `/Users/blitterated/.dotfiles/bash/.bashrc` |
| `/Users/blitterated` | `.bcrc` | `/Users/blitterated/.dotfiles/bc/.bcrc` |
| `/Users/blitterated/.config` | `nvim` | `/Users/blitterated/.dotfiles/nvim/.config/nvim` |
| `/Users/blitterated/.config` | `starship.toml` | `/Users/blitterated/.dotfiles/starship/.config/starship.toml` |
| `/Users/blitterated` | `.gemrc` | `/Users/blitterated/.dotfiles/ruby/.gemrc` |
| `/Users/blitterated` | `.gitconfig` | `/Users/blitterated/.dotfiles/git/.gitconfig` |
| `/Users/blitterated` | `.gitignore_global` | `/Users/blitterated/.dotfiles/git/.gitignore_global` |
| `/Users/blitterated` | `.pryrc` | `/Users/blitterated/.dotfiles/ruby/.pryrc` |
| `/Users/blitterated` | `.psqlrc` | `/Users/blitterated/.dotfiles/psql/.psqlrc` |
| `/Users/blitterated` | `.tmux.conf` | `/Users/blitterated/.dotfiles/tmux/.tmux.conf` |
| `/Users/blitterated` | `.vimrc` | `/Users/blitterated/.dotfiles/vim/.vimrc` |
| `/Users/blitterated` | `.zprofile` | `/Users/blitterated/.dotfiles/zsh/.zprofile` |
| `/Users/blitterated` | `.zsh_local` | `/Users/blitterated/.dotfiles/zsh_local.mac/.zsh_local` |
| `/Users/blitterated` | `.zshrc` | `/Users/blitterated/.dotfiles/zsh/.zshrc` |

[⬆️](#toc)


### <a id="test-target-cp" />Test copying target files and directories

Most of the dotfile links created by `stow` point at a file. However, Neovim's configuration files are pointed to with a directory link.

Create a test folder for `cp` tests.

```sh
mkdir test_cp && cd $_
```

[⬆️](#toc)


#### <a id="test-target-cp-dir" />Directory links

Test out a recursive copy to a test folder.

```sh
cp -r ~/.dotfiles/nvim/.config/nvim .
tree
```

```text
nvim
├── init.lua
├── lazy-lock.json
└── lua
    ├── config
    │   └── lazy.lua
    ├── linenumber-colors.lua
    ├── plugins
    │   ├── catppuccin.lua
    │   ├── lsp-config.lua
    │   ├── lualine.lua
    │   ├── neotree.lua
    │   ├── telescope.lua
    │   └── treesitter.lua
    └── vim-options.lua
```

[⬆️](#toc)


#### <a id="test-target-cp-file" />File links

Can we use the same `cp -r` command as above to copy files? This would avoid needing a decision branch in `bash`.

```sh
cp -r ~/.dotfiles/bc/.bcrc .
tree -a
```

```text
.bcrc
nvim
├── init.lua
├── lazy-lock.json
└── lua
    ├── config
    │   └── lazy.lua
    ├── linenumber-colors.lua
    ├── plugins
    │   ├── catppuccin.lua
    │   ├── lsp-config.lua
    │   ├── lualine.lua
    │   ├── neotree.lua
    │   ├── telescope.lua
    │   └── treesitter.lua
    └── vim-options.lua
```

[⬆️](#toc)


#### <a id="double-check-cp-rm" />Double check generating `rm` and `cp` commands

```sh
echo "| Delete link | Copy dotfiles |"
echo "| ----------- | ------------- |"
for link in "${dotlinks[@]}"; do
  local source="${HOME}/${link}"
  local source_path="$(dirname "${source}")"
  local target="${HOME}/.dotfiles/$(readlink "$HOME/$link" | gsed -E -e "s/^.*?\.dotfiles\///")"

  local rm_cmd="rm \"${source}\""
  local cp_cmd="cp -r \"${target}\" \"${source_path}\""

  echo "| ${rm_cmd} | ${cp_cmd} |"
done
```

| Delete link | Copy dotfiles |
| ----------- | ------------- |
| rm "/Users/blitterated/.bash_local" | cp -r "/Users/blitterated/.dotfiles/bash_local.mac/.bash_local" "/Users/blitterated" |
| rm "/Users/blitterated/.bash_profile" | cp -r "/Users/blitterated/.dotfiles/bash/.bash_profile" "/Users/blitterated" |
| rm "/Users/blitterated/.bashrc" | cp -r "/Users/blitterated/.dotfiles/bash/.bashrc" "/Users/blitterated" |
| rm "/Users/blitterated/.bcrc" | cp -r "/Users/blitterated/.dotfiles/bc/.bcrc" "/Users/blitterated" |
| rm "/Users/blitterated/.config/nvim" | cp -r "/Users/blitterated/.dotfiles/nvim/.config/nvim" "/Users/blitterated/.config" |
| rm "/Users/blitterated/.config/starship.toml" | cp -r "/Users/blitterated/.dotfiles/starship/.config/starship.toml" "/Users/blitterated/.config" |
| rm "/Users/blitterated/.gemrc" | cp -r "/Users/blitterated/.dotfiles/ruby/.gemrc" "/Users/blitterated" |
| rm "/Users/blitterated/.gitconfig" | cp -r "/Users/blitterated/.dotfiles/git/.gitconfig" "/Users/blitterated" |
| rm "/Users/blitterated/.gitignore_global" | cp -r "/Users/blitterated/.dotfiles/git/.gitignore_global" "/Users/blitterated" |
| rm "/Users/blitterated/.pryrc" | cp -r "/Users/blitterated/.dotfiles/ruby/.pryrc" "/Users/blitterated" |
| rm "/Users/blitterated/.psqlrc" | cp -r "/Users/blitterated/.dotfiles/psql/.psqlrc" "/Users/blitterated" |
| rm "/Users/blitterated/.tmux.conf" | cp -r "/Users/blitterated/.dotfiles/tmux/.tmux.conf" "/Users/blitterated" |
| rm "/Users/blitterated/.vimrc" | cp -r "/Users/blitterated/.dotfiles/vim/.vimrc" "/Users/blitterated" |
| rm "/Users/blitterated/.zprofile" | cp -r "/Users/blitterated/.dotfiles/zsh/.zprofile" "/Users/blitterated" |
| rm "/Users/blitterated/.zsh_local" | cp -r "/Users/blitterated/.dotfiles/zsh_local.mac/.zsh_local" "/Users/blitterated" |
| rm "/Users/blitterated/.zshrc" | cp -r "/Users/blitterated/.dotfiles/zsh/.zshrc" "/Users/blitterated" |

Looks good!

[⬆️](#toc)


## <a id="replace-links" />Replace the Links

### <a id="capture-first-listing" />Capture listing of current linked dotfiles

```sh
dotlinks=( '.bash_local' '.bash_profile' '.bashrc' '.bcrc' '.config/nvim' '.config/starship.toml'
           '.gemrc' '.gitconfig' '.gitignore_global' '.pryrc' '.psqlrc' '.tmux.conf' '.vimrc'
           '.zprofile' '.zsh_local' '.zshrc' )

ls -la $dotlinks[@]
```

```text
lrwxr-xr-x@ - blitterated 18 May 21:45 .bash_local -> .dotfiles/bash_local.mac/.bash_local
lrwxr-xr-x@ - blitterated 18 May 18:25 .bash_profile -> .dotfiles/bash/.bash_profile
lrwxr-xr-x@ - blitterated 18 May 18:25 .bashrc -> .dotfiles/bash/.bashrc
lrwxr-xr-x@ - blitterated 18 May 18:44 .bcrc -> .dotfiles/bc/.bcrc
lrwxr-xr-x@ - blitterated 18 May 18:38 .gemrc -> .dotfiles/ruby/.gemrc
lrwxr-xr-x@ - blitterated 18 May 18:30 .gitconfig -> .dotfiles/git/.gitconfig
lrwxr-xr-x@ - blitterated 18 May 18:30 .gitignore_global -> .dotfiles/git/.gitignore_global
lrwxr-xr-x@ - blitterated 18 May 18:38 .pryrc -> .dotfiles/ruby/.pryrc
lrwxr-xr-x@ - blitterated 18 May 18:44 .psqlrc -> .dotfiles/psql/.psqlrc
lrwxr-xr-x@ - blitterated 18 May 18:43 .tmux.conf -> .dotfiles/tmux/.tmux.conf
lrwxr-xr-x@ - blitterated 18 May 18:44 .vimrc -> .dotfiles/vim/.vimrc
lrwxr-xr-x@ - blitterated 18 May 18:28 .zprofile -> .dotfiles/zsh/.zprofile
lrwxr-xr-x@ - blitterated 18 May 22:01 .zsh_local -> .dotfiles/zsh_local.mac/.zsh_local
lrwxr-xr-x@ - blitterated 18 May 18:28 .zshrc -> .dotfiles/zsh/.zshrc
lrwxr-xr-x@ - blitterated 18 May 18:37 .config/starship.toml -> ../.dotfiles/starship/.config/starship.toml

.config/nvim:
drwxr-xr-x@    - blitterated 18 May 18:31 ..
drwxr-xr-x@    - blitterated  5 Jun 23:59 lua
lrwxr-xr-x@    - blitterated 18 May 18:32 . -> ../.dotfiles/nvim/.config/nvim
.rw-r--r--@  665 blitterated  6 Jun 00:01 init.lua
.rw-r--r--@ 1.2k blitterated  7 Jun 15:27 lazy-lock.json
```


[⬆️](#toc)


### <a id="execute-replace" />Execute Replacement
```sh
cat << EOF > replace_stow_links.sh
#!/bin/bash

replace_stow_links ()
{
  # The dotfile links to be replaced
  dotlinks=( '.bash_local' '.bash_profile' '.bashrc' '.bcrc' '.config/nvim' '.config/starship.toml'
             '.gemrc' '.gitconfig' '.gitignore_global' '.pryrc' '.psqlrc' '.tmux.conf' '.vimrc'
             '.zprofile' '.zsh_local' '.zshrc' )

  # Backup directory for current link files
  dead_dots="${HOME}/.dead_dots"
  mkdir -p "${dead_dots}"

  # Iterate dotfile links, backup, and replace them.
  for link in "${dotlinks[@]}"; do
    local source_link="${HOME}/${link}"
    local source_path="$(dirname "${source_link}")"
    local target="${HOME}/.dotfiles/$(readlink "$HOME/$link" | gsed -E -e "s/^.*?\.dotfiles\///")"

    cp -P "${source_link}" "${dead_dots}"

    echo
    echo "Replacing \"${source_link}\" with \"${target}\""

    rm "${source_link}"
    cp -r "${target}" "${source_path}"
  done
}
EOF

chmod +x replace_stow_links.sh

./replace_stow_links.sh
```

[⬆️](#toc)


### <a id="final-check" />Final check

```sh
dotlinks=( '.bash_local' '.bash_profile' '.bashrc' '.bcrc' '.config/nvim' '.config/starship.toml'
           '.gemrc' '.gitconfig' '.gitignore_global' '.pryrc' '.psqlrc' '.tmux.conf' '.vimrc'
           '.zprofile' '.zsh_local' '.zshrc' )

ls -la $dotlinks[@]
```

```text
.rw-r--r--@ 1.6k blitterated  6 Jul 17:14 .bash_local
.rw-r--r--@   76 blitterated  6 Jul 17:14 .bash_profile
.rw-r--r--@ 2.6k blitterated  6 Jul 17:14 .bashrc
.rw-r--r--@  114 blitterated  6 Jul 17:14 .bcrc
.rw-r--r--@   51 blitterated  6 Jul 17:14 .gemrc
.rw-r--r--@  115 blitterated  6 Jul 17:14 .gitconfig
.rw-r--r--@   24 blitterated  6 Jul 17:14 .gitignore_global
.rw-r--r--@   66 blitterated  6 Jul 17:14 .pryrc
.rw-r--r--@  987 blitterated  6 Jul 17:14 .psqlrc
.rw-r--r--@ 1.8k blitterated  6 Jul 17:14 .tmux.conf
.rw-r--r--@ 2.5k blitterated  6 Jul 17:14 .vimrc
.rw-r--r--@    0 blitterated  6 Jul 17:14 .zprofile
.rw-r--r--@ 2.1k blitterated  6 Jul 17:14 .zsh_local
.rw-r--r--@ 2.2k blitterated  6 Jul 17:14 .zshrc
.rw-r--r--@ 3.8k blitterated  6 Jul 17:14 .config/starship.toml

.config/nvim:
drwxr-xr-x@    - blitterated  6 Jul 17:14 .
drwx------     - blitterated  6 Jul 17:14 ..
drwxr-xr-x@    - blitterated  6 Jul 17:14 lua
.rw-r--r--@  665 blitterated  6 Jul 17:14 init.lua
.rw-r--r--@ 1.2k blitterated  6 Jul 17:14 lazy-lock.json
```

Double check `~/.config/nvim`

```sh
tree -a .config/nvim
```

```text
drwxr-xr-x@    - blitterated  6 Jul 17:14 .config/nvim
.rw-r--r--@  665 blitterated  6 Jul 17:14 ├── init.lua
.rw-r--r--@ 1.2k blitterated  6 Jul 17:14 ├── lazy-lock.json
drwxr-xr-x@    - blitterated  6 Jul 17:14 └── lua
drwxr-xr-x@    - blitterated  6 Jul 17:14     ├── config
.rw-r--r--@ 1.3k blitterated  6 Jul 17:14     │   └── lazy.lua
.rw-r--r--@  162 blitterated  6 Jul 17:14     ├── linenumber-colors.lua
drwxr-xr-x@    - blitterated  6 Jul 17:14     ├── plugins
.rw-r--r--@  155 blitterated  6 Jul 17:14     │   ├── catppuccin.lua
.rw-r--r--@  605 blitterated  6 Jul 17:14     │   ├── lsp-config.lua
.rw-r--r--@  162 blitterated  6 Jul 17:14     │   ├── lualine.lua
.rw-r--r--@  413 blitterated  6 Jul 17:14     │   ├── neotree.lua
.rw-r--r--@  303 blitterated  6 Jul 17:14     │   ├── telescope.lua
.rw-r--r--@  591 blitterated  6 Jul 17:14     │   └── treesitter.lua
.rw-r--r--@  540 blitterated  6 Jul 17:14     └── vim-options.lua
```

Looks good!

[⬆️](#toc)


## <a id="prep-repo" />Prepare dotfiles repo

### <a id="tag-last-commit" />Tag latest commit

Tag last commit as "Final Gnu Stow Commit".

```sh
git tag -a gnu-stow-final -m "This is the last Gnu Stow commit before the switch to chezmoi."
```

[⬆️](#toc)


### <a id="push-tag" />Push tag to origin.

```sh
git push --tags
```

[⬆️](#toc)


### <a id="move-repo" />Move current dotfiles repo

chezmoi expects the dotfiles repo to reside at `~/.local/share/chezmoi`. Move `~/.dofiles` to that location.

```sh
mv ~/.dotfiles ~/.local/share
cd ~/.local/share
mv .dotfiles chezmoi
```

[⬆️](#toc)


### <a id="create-orphan-branch" />Create an orphan branch

This branch will omit

WAIT!!!! I DON'T WANT AN ORPHAN BRANCH!!!!
I want to maintain the history of the files.
Shit, this is gonna be a lot more work.

[⬆️](#toc)


### <a id="create-chezmoi-branch" />Create a branch for chezmoi

```sh
git checkout -b chezmoi
```

[⬆️](#toc)


### <a id="transform-file-hierarchy" />Transform dotfiles file hierarchy for chezmoi

#### <a id="stow-repo-structure" />Dotfile repo's current Gnu Stow structure

```sh
tree -a -I .git
```

```text
.
├── .gitignore
├── __lib
│   └── source_files.sh
├── bash
│   ├── .bash_profile
│   └── .bashrc
├── bash_local.mac
│   └── .bash_local
├── bc
│   └── .bcrc
├── git
│   ├── .gitconfig
│   └── .gitignore_global
├── nvim
│   └── .config
│       └── nvim
│           ├── init.lua
│           ├── lazy-lock.json
│           └── lua
│               ├── config
│               │   └── lazy.lua
│               ├── linenumber-colors.lua
│               ├── plugins
│               │   ├── catppuccin.lua
│               │   ├── lsp-config.lua
│               │   ├── lualine.lua
│               │   ├── neotree.lua
│               │   ├── telescope.lua
│               │   └── treesitter.lua
│               └── vim-options.lua
├── psql
│   └── .psqlrc
├── README.md
├── ruby
│   ├── .gemrc
│   └── .pryrc
├── starship
│   └── .config
│       └── starship.toml
├── tmux
│   └── .tmux.conf
├── vim
│   └── .vimrc
├── Windows
│   ├── link_powershell_configs.ps1
│   └── PowerShell
│       └── Microsoft.PowerShell_profile.ps1
├── zsh
│   ├── .zprofile
│   └── .zshrc
└── zsh_local.mac
    └── .zsh_local
```

[⬆️](#toc)


#### <a id="transform-script" />Repo transformation script

```sh
# .gitignore                    do nothing
# __lib/source_files.sh         do nothing

git mv bash/.bash_profile ./dot_bash_profile
git mv bash/.bashrc ./dot_bashrc
rm -rf bash

git mv bash_local.mac/.bash_local ./dot_bash_local
rm -rf bash_local.mac

git mv bc/.bcrc ./dot_bcrc
rm -rf bc

git mv git/.gitconfig ./dot_gitconfig
git mv git/.gitignore_global ./dot_gitignore_global
rm -rf git

git mv nvim/.config ./dot_config
rm -rf nvim

git mv psql/.psqlrc ./dot_psqlrc
rm -rf psql

# README.md                     do nothing

git mv ruby/.gemrc ./dot_gemrc
git mv ruby/.pryrc ./dot_pryrc
rm -rf ruby

git mv starship/.config/starship.toml ./dot_config/starship.toml
rm -rf starship

git mv tmux/.tmux.conf ./dot_tmux.conf
rm -rf tmux

git mv vim/.vimrc ./dot_vimrc
rm -rf vim

# Windows/link_powershell_configs.ps1                   save for later
# Windows/PowerShell/Microsoft.PowerShell_profile.ps1   save for later

git mv zsh/.zprofile ./dot_zprofile
git mv zsh/.zshrc ./dot_zshrc
rm -rf zsh

git mv zsh_local.mac/.zsh_local ./dot_zsh_local
rm -rf zsh_local.mac
```

[⬆️](#toc)


#### <a id="chezmoi-repo-structure" />Dotfile repo's new chezmoi structure

```sh
tree -a -I .git
```

```text
.
├── .gitignore
├── __lib
│   └── source_files.sh
├── dot_bash_local
├── dot_bash_profile
├── dot_bashrc
├── dot_bcrc
├── dot_config
│   ├── nvim
│   │   ├── init.lua
│   │   ├── lazy-lock.json
│   │   └── lua
│   │       ├── config
│   │       │   └── lazy.lua
│   │       ├── linenumber-colors.lua
│   │       ├── plugins
│   │       │   ├── catppuccin.lua
│   │       │   ├── lsp-config.lua
│   │       │   ├── lualine.lua
│   │       │   ├── neotree.lua
│   │       │   ├── telescope.lua
│   │       │   └── treesitter.lua
│   │       └── vim-options.lua
│   └── starship.toml
├── dot_gemrc
├── dot_gitconfig
├── dot_gitignore_global
├── dot_pryrc
├── dot_psqlrc
├── dot_tmux.conf
├── dot_vimrc
├── dot_zprofile
├── dot_zsh_local
├── dot_zshrc
├── README.md
└── Windows
    ├── link_powershell_configs.ps1
    └── PowerShell
        └── Microsoft.PowerShell_profile.ps1
```

[⬆️](#toc)

















## <a id="current-progress-marker" />YOU ARE HERE















## <a id="set-up-chezmoi" />Set up chezmoi

### <a id="install-chezmoi" />Install chezmoi on MBP

```sh
brew install chezmoi
```

[⬆️](#toc)


### <a id="backup-current-dotfiles" />Move current dotfiles in `$HOME` to a backup folder

```sh
mkdir ~/.dead_dots
cd ~/.dead_dots
mkdir ./.config

mv ~/.gitignore .
mv ~/.bash_local .
mv ~/.bash_profile .
mv ~/.bashrc .
mv ~/.bcrc .
mv ~/.gemrc .
mv ~/.gitconfig .
mv ~/.gitignore_global .
mv ~/.pryrc .
mv ~/.psqlrc .
mv ~/.tmux.conf .
mv ~/.vimrc .
mv ~/.zprofile .
mv ~/.zsh_local .
mv ~/.zshrc .
mv ~/.config/nvim ./.config
mv ~/.config/starship.toml ./.config

cd -
```

[⬆️](#toc)



## <a id="todo" />TODO

### <a id="post-migration-followups" />Post Migration Follow Ups

* Change the way `(ba|z)sh_local` files are stored and sourced.
* Move branching code based on machine/OS type into `~/.*_local` files sans branching.
* Load hombrew completions for `zsh` in `~/.zsh_local`.
* `~/.zprofile` is empty?
* Swap out `nvim` for `vim` as editor in `~/.pryrc`.
* rc files for POSIX sh, ash, and dash.
* Starship for `bash`.
* A script for stowing mac or linux environments.
* Have starship show which shell is running.

[⬆️](#toc)























































