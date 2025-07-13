# Switch to chezmoi for dotfile management

I'm currently using Gnu Stow as a dotfile manager. It's good, but it's more of a binary link farm manager than a dotfile manager. The requirement for Perl isn't my cup of tea, either, There's too many good Rust utilities these days.


## Table of Contents          <a id="toc" />

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
* [Set up chezmoi](#set-up-chezmoi)
    * [Copy current dotfiles in `$HOME` to a backup folder](#backup-current-dotfiles)
        * [Restore script, JIC](#dotfile-restore-script)
    * [List modified dates for dotfiles in `$HOME` dir](#list-mod-dates)
        * [Create an array of dotfile names](#dotfile-name-array)
        * [Get the listing](#get-the-listing)
    * [Install chezmoi on MBP](#install-chezmoi)
    * [Configure chezmoi on MBP](#configure-chezmoi)
        * [Ignore folders and files](#ignore-files-folder")
        * [Config file](#onfig-file)
        * [Make `.bashrc` a template file and weave in the mac settings](#make-bashrc-template)
        * [INTERLUDE: Reinitialize chezmoi using source repo URL](#reinit-chezmoi)
        * [Edit `.bashrc` template to bring in Mac settings](#edit-bashrc-template)
        * [Move `dot_bash_local` to `bash_local/bash_darwin`](#move-bash-local-file)

* [YOU ARE HERE](#current-progress-marker)

* [chezmoi Gotchas](#gotchas)
    * [Converting a dotfile to a template](#gotchas-template-conversion)
    * [Make file paths passed to chezmoi commands relative to the source repo](#gotchas-cmd-file-path-params)
    * [Vim file type detection](#gotchas-cmd-file-path-params)
* [TODO](#todo)
    * [Post Migration Follow Ups](#post-migration-followups)
* [Appendix](#appendix")
    * [Source repo file system tree before and after results](#repo-before-after")
* [Resources](#resources)


## Commit and push local changes in the dotfiles repo                           <a id="commit-push-local-repo" />

### Check on `git status`                                                       <a id="local-git-status" />

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


### Check the dates on modified and untracked files                             <a id="check-file-dates" />

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


## Iterate towards replacing links with dotfiles                                <a id="iterate-replacement" />

### Search for links to the dotfiles repo from the home directory               <a id="search-for-dotfile-links" />

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


### Get dotfile links into into a bash array                                    <a id="dotfile-array" />

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

### Transform source and target paths                                           <a id="transform-paths" />

#### Look up paths to link targets                                              <a id="look-up-link-paths" />

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


#### Generate full path to target                                               <a id="gen-full-target-path" />

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


#### View full file path in Markdown table                                      <a id="md-full-target-path" />

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


#### Separate link filename from path and use `$HOME` instead of `~`            <a id="link-name-path-home" />

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


### Test copying target files and directories                                   <a id="test-target-cp" />

Most of the dotfile links created by `stow` point at a file. However, Neovim's configuration files are pointed to with a directory link.

Create a test folder for `cp` tests.

```sh
mkdir test_cp && cd $_
```

[⬆️](#toc)


#### Directory links                                                            <a id="test-target-cp-dir" />

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


#### File links                                                                 <a id="test-target-cp-file" />

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


#### Double check generating `rm` and `cp` commands                             <a id="double-check-cp-rm" />

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


## Replace the Links                                                            <a id="replace-links" />

### Capture listing of current linked dotfiles                                  <a id="capture-first-listing" />

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


### Execute Replacement                                                         <a id="execute-replace" />
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


### Final check                                                                 <a id="final-check" />

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


## Prepare dotfiles repo                                                        <a id="prep-repo" />

### Tag latest commit                                                           <a id="tag-last-commit" />

Tag last commit as "Final Gnu Stow Commit".

```sh
git tag -a gnu-stow-final -m "This is the last Gnu Stow commit before the switch to chezmoi."
```

[⬆️](#toc)


### Push tag to origin.                                                         <a id="push-tag" />

```sh
git push --tags
```

[⬆️](#toc)


### Move current dotfiles repo                                                  <a id="move-repo" />

chezmoi expects the dotfiles repo to reside at `~/.local/share/chezmoi`. Move `~/.dofiles` to that location.

```sh
mv ~/.dotfiles ~/.local/share
cd ~/.local/share
mv .dotfiles chezmoi
```

[⬆️](#toc)


### Create an orphan branch                                                     <a id="create-orphan-branch" />

This branch will omit

WAIT!!!! I DON'T WANT AN ORPHAN BRANCH!!!!
I want to maintain the history of the files.
Shit, this is gonna be a lot more work.

[⬆️](#toc)


### Create a branch for chezmoi                                                 <a id="create-chezmoi-branch" />

```sh
git checkout -b chezmoi
```

[⬆️](#toc)


### Transform dotfiles file hierarchy for chezmoi                               <a id="transform-file-hierarchy" />

#### Dotfile repo's current Gnu Stow structure                                  <a id="stow-repo-structure" />

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


#### Repo transformation script                                                 <a id="transform-script" />

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


#### Dotfile repo's new chezmoi structure                                       <a id="chezmoi-repo-structure" />

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


## Set up chezmoi                                                               <a id="set-up-chezmoi" />

### Copy current dotfiles in `$HOME` to a backup folder                         <a id="backup-current-dotfiles" />

```sh
mkdir ~/.dotbak
cd ~/.dotbak
mkdir ./.config

cp ~/.bash_local .
cp ~/.bash_profile .
cp ~/.bashrc .
cp ~/.bcrc .
cp ~/.gemrc .
cp ~/.gitconfig .
cp ~/.gitignore_global .
cp ~/.pryrc .
cp ~/.psqlrc .
cp ~/.tmux.conf .
cp ~/.vimrc .
cp ~/.zprofile .
cp ~/.zsh_local .
cp ~/.zshrc .
cp -r ~/.config/nvim ./.config
cp ~/.config/starship.toml ./.config

cd -
```

#### Restore script, JIC                                                        <a id="dotfile-restore-script" />

```sh
cd ~/.dotbak

cp .bash_local ~
cp .bash_profile ~
cp .bashrc ~
cp .bcrc ~
cp .gemrc ~
cp .gitconfig ~
cp .gitignore_global ~
cp .pryrc ~
cp .psqlrc ~
cp .tmux.conf ~
cp .vimrc ~
cp .zprofile ~
cp .zsh_local ~
cp .zshrc ~
cp -r ~/.config/nvim ~/.config
cp .config/starship.toml ~/.config

cd -
```

[⬆️](#toc)

### List modified dates for dotfiles in `$HOME` dir                             <a id="list-mod-dates" />

Capture a listing of current dotfiles in `$HOME` for comparison after applying with chezmoi.

I have `ls` is aliased to `eza`.

The following `eza` options are used in the steps below:

| switch | long option | description |
| ------ | ----------- | ----------- |
| `-1`   | `--oneline`            | display one entry per line |
| `-a`   | `--all`                | show hidden and 'dot' files. Use this twice to also show the '.' and '..' directories |
| `-l`   | `--long`               | display extended file metadata as a table |
| `-R`   | `--recurse`            | recurse into directories |
| `-I GLOBS` | `--ignore-glob GLOBS`  | glob patterns (pipe-separated) of files to ignore |
| `-f`   | `--only-files`         | list only files |
| `-m`   | `--modified`           | use the modified timestamp field |
| &nbsp; | `--absolute`           | display entries with their absolute path (on, follow, off) |
| &nbsp; | `--time-style`         | how to format timestamps (default, iso, long-iso, full-iso, relative, or a custom style '+<FORMAT>' like '+%Y-%m-%d %H:%M') |
| &nbsp; | `--icons=WHEN`         | cisplay icons next to file names. WHEN = always, automatic (auto), never |

[⬆️](#toc)


#### Create an array of dotfile names                                           <a id="dotfile-name-array" />

I'm just reusing the dotfile backup dir [created above](#backup-current-dotfiles) to create this array.

```sh
watch_dots=( $(ls -1afR --absolute=on --icons=never ~/.dotbak | grep -Ev "(^$|:)" | gsed -E "s|${HOME}/.dotbak/||") )
echo $watch_dots[@]
```

```text
.bash_local
.bash_profile
.bashrc
.bcrc
.gemrc
.gitconfig
.gitignore_global
.pryrc
.psqlrc
.tmux.conf
.vimrc
.zprofile
.zsh_local
.zshrc
.config/starship.toml
.config/nvim/init.lua
.config/nvim/lazy-lock.json
.config/nvim/lua/linenumber-colors.lua
.config/nvim/lua/vim-options.lua
.config/nvim/lua/config/lazy.lua
.config/nvim/lua/plugins/catppuccin.lua
.config/nvim/lua/plugins/lsp-config.lua
.config/nvim/lua/plugins/lualine.lua
.config/nvim/lua/plugins/neotree.lua
.config/nvim/lua/plugins/telescope.lua
.config/nvim/lua/plugins/treesitter.lua
```

[⬆️](#toc)


#### Get the listing                                                            <a id="get-the-listing" />

```sh
watch_dots=( $(ls -1afR --absolute=on --icons=never $HOME/.dotbak | grep -Ev "(^$|:)" | gsed -E "s|${HOME}/.dotbak/||") )

ls -1aflmR --absolute=on  --icons=never --time-style '+%Y-%m-%d %H:%M:%S' $watch_dots[@] | grep '^\.[r-]' | gsed -E "s/\.[rwx-]+?@\s+[0-9.k]+\s${USER}\s//"
```

```text
2025-07-06 17:14:57 /Users/peteyoung/.bash_local
2025-07-06 17:14:57 /Users/peteyoung/.bash_profile
2025-07-06 17:14:57 /Users/peteyoung/.bashrc
2025-07-06 17:14:57 /Users/peteyoung/.bcrc
2025-07-06 17:14:57 /Users/peteyoung/.gemrc
2025-07-06 17:14:57 /Users/peteyoung/.gitconfig
2025-07-06 17:14:57 /Users/peteyoung/.gitignore_global
2025-07-06 17:14:57 /Users/peteyoung/.pryrc
2025-07-06 17:14:57 /Users/peteyoung/.psqlrc
2025-07-06 17:14:57 /Users/peteyoung/.tmux.conf
2025-07-06 17:14:57 /Users/peteyoung/.vimrc
2025-07-06 17:14:57 /Users/peteyoung/.zprofile
2025-07-06 17:14:57 /Users/peteyoung/.zsh_local
2025-07-06 17:14:57 /Users/peteyoung/.zshrc
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/plugins/catppuccin.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/init.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lazy-lock.json
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/config/lazy.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/linenumber-colors.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/plugins/lsp-config.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/plugins/lualine.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/plugins/neotree.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/starship.toml
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/plugins/telescope.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/plugins/treesitter.lua
2025-07-06 17:14:57 /Users/peteyoung/.config/nvim/lua/vim-options.lua
```

[⬆️](#toc)


### Install chezmoi on MBP                                                      <a id="install-chezmoi" />

```sh
brew install chezmoi
```

[⬆️](#toc)


### Configure chezmoi on MBP                                                    <a id="configure-chezmoi" />

#### Ignore folders and files                                                   <a id="ignore-files-folder" />

The following files and directories need to be ignored for various reasons.

* `__lib/source_files.sh` - intended to be used with `stow`
* `Windows/**/*` - temporary while I work out the Mac setup first
* `Switch to chezmoi.md` - the file you're reading right now

We can use [`.chezmoiignore`](https://www.chezmoi.io/reference/special-files/chezmoiignore/) to do this.

```sh
cat << EOF > .chezmoiignore
README.md               # don't need this in $HOME
Switch to chezmoi.md    # don't need this in $HOME
Windows/                # ignore Windows folder
Windows/**              # ignore the contents of Windows
__lib/                  # ignore __lib folder
__lib/**                # ignore the contents of __lib
EOF
```

[⬆️](#toc)


#### Config file                                                               <a id="config-file" />

[Variables, a.k.a. configuration settings](https://www.chezmoi.io/reference/configuration-file/variables/)

```toml
[edit]
    command = "nvim"

[git]
    autoCommit = false
    autoPush = false
```

[⬆️](#toc)


#### Make `.bashrc` a template file and weave in the mac settings                <a id="make-bashrc-template" />

Convert to template.

```sh
git mv dot_bashrc dot_bashrc.tmpl
```

Open the file to edit it.

```sh
chezmoi edit .bashrc
```

```text
chezmoi: .bashrc: not managed
```

Uh oh. Time to commit everything and try initializing chezmoi again using a URL.

[⬆️](#toc)


#### INTERLUDE: Reinitialize chezmoi using source repo URL                      <a id="reinit-chezmoi" />

Backup the current source repo.

```sh
mv $HOME/.local/share/chezmoi $HOME/.local/share/chezmoi.oops
```

Initialize chezmoi with the upstream source repo URL.

```sh
chezmoi -v init --branch chezmoi ghblit:blitterated/dotfiles.git
```

```text
Cloning into '/Users/blitterated/.local/share/chezmoi'...
remote: Enumerating objects: 245, done.
remote: Counting objects: 100% (245/245), done.
remote: Compressing objects: 100% (124/124), done.
remote: Total 245 (delta 91), reused 225 (delta 71), pack-reused 0 (from 0)
Receiving objects: 100% (245/245), 44.57 KiB | 1.11 MiB/s, done.
Resolving deltas: 100% (91/91), done.
```

`tree` showed that `$HOME/.local/share/chezmoi` and `$HOME/.local/share/chezmoi.oops` were the same except for `.DS_Store` in the latter.

See [the Appendix entry](#repo-before-after") for details.

Try to edit `.bashrc` again.

```sh
chezmoi edit .bashrc
```

```text
chezmoi: .bashrc: not managed
```

AAAAANNNNNNNDDDDDD... I'm an idiot. It works if you're in `$HOME` or specify `$HOME` in the command.

```sh
chezmoi edit ~/.bashrc
```

Unnecessary rework. Yay. Make sure you specify the path to the target file and not just its name, e.g. `~/.bashrc` and not just `.bashrc`.

[⬆️](#toc)






## YOU ARE HERE                                                                 <a id="current-progress-marker" />




#### Edit `.bashrc` template to bring in Mac settings                           <a id="edit-bashrc-template" />

Open the file to edit it.

```sh
chezmoi edit ~/.bashrc
```

I think chezmoi's mapping from `.bashrc` to `dot_bashrc` breaks filetype detection.
Force it with this:

```text
:setf bash
```

Replace any code loading `.bash_local` with the following template code:

```text
{{- if eq .chezmoi.os "darwin" -}}
{{-   include bash_local/bash_darwin -}}
{{- end -}}
```

[⬆️](#toc)


#### Move `dot_bash_local` to `bash_local/bash_darwin`                          <a id="move-bash-local-file" />

I plan to use `bash_local` as the folder for bash local machine configs.
The current `.bash_local` file is specific to a Macbook Pro.

```sh
chezmoi cd
mkdir bash_local
 git mv dot_bash_local bash_local/bash_darwin
```

[⬆️](#toc)


















__TODO:__
* √ Move dot_bash_local to bash_local/bash_darwin
* √ Make .bashrc a template
* Detect os and include bash_darwin if .chezmoi.os is "darwin" in dot_bash_rc
* Run the template
* chezmoi apply --dry_run --verbose




## chezmoi Gotchas                                                              <a id="gotchas" />

### Converting a dotfile to a template                                          <a id="gotchas-template-conversion" />

Using `chezmoi chattr +template ~/.foobar` breaks the history of the original file by deleting it and adding the templated version as a new file to Git.
Here's what the `git status` looks like:

```text
git status
```

```text
On branch chezmoi
Your branch is up to date with 'origin/chezmoi'.

Changes not staged for commit:
  ...
        deleted:    dot_bashrc

Untracked files:
  ...
        dot_bashrc.tmpl
```

To preserve the file's history, use `git mv` instead.

```sh
git mv dot_bashrc dot_bashrc.tmpl
git status
```

```text
On branch chezmoi
Your branch is up to date with 'origin/chezmoi'.

Changes to be committed:
  ...
        renamed:    dot_bashrc -> dot_bashrc.tmpl
```

[⬆️](#toc)


### Make file paths passed to chezmoi commands relative to the source repo      <a id ="gotchas-cmd-file-path-params">

Simply specifying the file name to edit only works if you're currently in `$HOME`. Otherwise, make sure you specify `$HOME` or `~` in the file path parameter.

This only works in `$HOME`:

```sh
chezmoi edit .bashrc
```

Otherwise you'll get this error:

```text
chezmoi: .bashrc: not managed
```

This will work from any directory:

```sh
chezmoi edit ~/.bashrc
```

[See what happened here](#reinit-chezmoi).


[⬆️](#toc)

### Vim file type detection                                                    <a id ="gotchas-cmd-file-path-params">

The way chezmoi renames files in the source repo can break Vim's file type detection.
For example, Vim will detect `.bashrc` as a Bash file, but it fails with `dot_bashrc`.

It happens with the edit command `chezmoi edit ~/.bashrc` if you've made the source file a template with the `.tmpl` extension.
Here's what I got from `:ls` in Vim while editing `.bashrc`:

```txt
/private/var/folders/s9/84x1rz2j02g5pth66xsm7vv80000gp/T/chezmoi-edit663884950/.bashrc.tmpl
```

The quick fix is to run the following in Vim:

```text
:setf bash
```

[⬆️](#toc)

















## TODO                                                                         <a id="todo" />

### Post Migration Follow Ups                                                   <a id="post-migration-followups" />

* Change the way `(ba|z)sh_local` files are stored and sourced.
* Load hombrew completions for `zsh` in `~/.zsh_local`.
* `~/.zprofile` is empty?
* Swap out `nvim` for `vim` as editor in `~/.pryrc`.
* rc files for POSIX sh, ash, and dash? (fat chance)
* Starship for `bash`.
* Add `.config/homebrew`
* Add `.config/karabiner`
* Add `.hammerspoon`
* Add `.config/ghostty`

[⬆️](#toc)


## Appendix                                                                     <a id="appendix" />

### Source repo file system tree before and after results <a id="todo" />       <a id="repo-before-after" />

Before reinit:

```sh
tree -a -I .git
```

```text
drwxr-xr-x@    - peteyoung 12 Jul 23:29 .
.rw-r--r--@  539 peteyoung 12 Jul 14:01 ├── .chezmoiignore
.rw-r--r--@  10k peteyoung  8 Jul 10:42 ├── .DS_Store
.rw-r--r--@   19 peteyoung 18 May 22:07 ├── .gitignore
drwxr-xr-x@    - peteyoung  2 Jul 14:02 ├── __lib
.rw-r--r--@ 1.1k peteyoung  2 Jul 14:02 │   └── source_files.sh
.rw-r--r--@  154 peteyoung 12 Jul 01:08 ├── chezmoi.toml
.rw-r--r--@ 1.6k peteyoung  9 Jun 18:22 ├── dot_bash_local
.rw-r--r--@   76 peteyoung 18 May 22:07 ├── dot_bash_profile
.rw-r--r--@ 2.6k peteyoung 12 Jul 23:28 ├── dot_bashrc.tmpl
.rw-r--r--@  114 peteyoung 18 May 03:05 ├── dot_bcrc
drwxr-xr-x@    - peteyoung  7 Jul 22:32 ├── dot_config
drwxr-xr-x@    - peteyoung  6 Jun 00:01 │   ├── nvim
.rw-r--r--@  665 peteyoung  6 Jun 00:01 │   │   ├── init.lua
.rw-r--r--@ 1.2k peteyoung  7 Jun 15:27 │   │   ├── lazy-lock.json
drwxr-xr-x@    - peteyoung  5 Jun 23:59 │   │   └── lua
drwxr-xr-x@    - peteyoung  5 Jun 23:59 │   │       ├── config
.rw-r--r--@ 1.3k peteyoung  3 Jun 16:52 │   │       │   └── lazy.lua
.rw-r--r--@  162 peteyoung  5 Jun 23:48 │   │       ├── linenumber-colors.lua
drwxr-xr-x@    - peteyoung  2 Jul 01:19 │   │       ├── plugins
.rw-r--r--@  155 peteyoung 20 Apr 18:15 │   │       │   ├── catppuccin.lua
.rw-r--r--@  605 peteyoung  7 Jun 15:27 │   │       │   ├── lsp-config.lua
.rw-r--r--@  162 peteyoung  5 Jun 23:03 │   │       │   ├── lualine.lua
.rw-r--r--@  413 peteyoung  4 Jun 13:42 │   │       │   ├── neotree.lua
.rw-r--r--@  303 peteyoung 20 Apr 22:02 │   │       │   ├── telescope.lua
.rw-r--r--@  591 peteyoung 20 Apr 21:53 │   │       │   └── treesitter.lua
.rw-r--r--@  540 peteyoung  3 Jun 17:40 │   │       └── vim-options.lua
.rw-r--r--@ 3.8k peteyoung 20 May 23:40 │   └── starship.toml
.rw-r--r--@   51 peteyoung 13 Feb  2024 ├── dot_gemrc
.rw-r--r--@  115 peteyoung 25 Mar  2024 ├── dot_gitconfig
.rw-r--r--@   24 peteyoung 18 May 03:05 ├── dot_gitignore_global
.rw-r--r--@   66 peteyoung 18 May 22:49 ├── dot_pryrc
.rw-r--r--@  987 peteyoung 18 May 03:05 ├── dot_psqlrc
.rw-r--r--@ 1.8k peteyoung 18 May 03:05 ├── dot_tmux.conf
.rw-r--r--@ 2.5k peteyoung 18 May 03:05 ├── dot_vimrc
.rw-r--r--@    0 peteyoung 30 May 15:33 ├── dot_zprofile
.rw-r--r--@ 2.1k peteyoung  9 Jun 18:27 ├── dot_zsh_local
.rw-r--r--@ 2.2k peteyoung  2 Jul 01:34 ├── dot_zshrc
.rw-r--r--@  102 peteyoung 18 May 22:07 ├── README.md
.rw-r--r--@  42k peteyoung 12 Jul 23:31 ├── 'Switch to chezmoi.md'
drwxr-xr-x@    - peteyoung 30 May 15:34 └── Windows
.rw-r--r--@ 1.4k peteyoung 30 May 15:34     ├── link_powershell_configs.ps1
drwxr-xr-x@    - peteyoung 30 May 15:34     └── PowerShell
.rw-r--r--@ 5.8k peteyoung 30 May 15:34         └── Microsoft.PowerShell_profile.ps1
```

After reinit:

```sh
tree -a -I .git
```

```text
drwxr-xr-x@    - peteyoung 13 Jul 00:00 .
.rw-r--r--@  539 peteyoung 13 Jul 00:00 ├── .chezmoiignore
.rw-r--r--@   19 peteyoung 13 Jul 00:00 ├── .gitignore
drwxr-xr-x@    - peteyoung 13 Jul 00:00 ├── __lib
.rw-r--r--@ 1.1k peteyoung 13 Jul 00:00 │   └── source_files.sh
.rw-r--r--@  154 peteyoung 13 Jul 00:00 ├── chezmoi.toml
.rw-r--r--@ 1.6k peteyoung 13 Jul 00:00 ├── dot_bash_local
.rw-r--r--@   76 peteyoung 13 Jul 00:00 ├── dot_bash_profile
.rw-r--r--@ 2.6k peteyoung 13 Jul 00:00 ├── dot_bashrc.tmpl
.rw-r--r--@  114 peteyoung 13 Jul 00:00 ├── dot_bcrc
drwxr-xr-x@    - peteyoung 13 Jul 00:00 ├── dot_config
drwxr-xr-x@    - peteyoung 13 Jul 00:00 │   ├── nvim
.rw-r--r--@  665 peteyoung 13 Jul 00:00 │   │   ├── init.lua
.rw-r--r--@ 1.2k peteyoung 13 Jul 00:00 │   │   ├── lazy-lock.json
drwxr-xr-x@    - peteyoung 13 Jul 00:00 │   │   └── lua
drwxr-xr-x@    - peteyoung 13 Jul 00:00 │   │       ├── config
.rw-r--r--@ 1.3k peteyoung 13 Jul 00:00 │   │       │   └── lazy.lua
.rw-r--r--@  162 peteyoung 13 Jul 00:00 │   │       ├── linenumber-colors.lua
drwxr-xr-x@    - peteyoung 13 Jul 00:00 │   │       ├── plugins
.rw-r--r--@  155 peteyoung 13 Jul 00:00 │   │       │   ├── catppuccin.lua
.rw-r--r--@  605 peteyoung 13 Jul 00:00 │   │       │   ├── lsp-config.lua
.rw-r--r--@  162 peteyoung 13 Jul 00:00 │   │       │   ├── lualine.lua
.rw-r--r--@  413 peteyoung 13 Jul 00:00 │   │       │   ├── neotree.lua
.rw-r--r--@  303 peteyoung 13 Jul 00:00 │   │       │   ├── telescope.lua
.rw-r--r--@  591 peteyoung 13 Jul 00:00 │   │       │   └── treesitter.lua
.rw-r--r--@  540 peteyoung 13 Jul 00:00 │   │       └── vim-options.lua
.rw-r--r--@ 3.8k peteyoung 13 Jul 00:00 │   └── starship.toml
.rw-r--r--@   51 peteyoung 13 Jul 00:00 ├── dot_gemrc
.rw-r--r--@  115 peteyoung 13 Jul 00:00 ├── dot_gitconfig
.rw-r--r--@   24 peteyoung 13 Jul 00:00 ├── dot_gitignore_global
.rw-r--r--@   66 peteyoung 13 Jul 00:00 ├── dot_pryrc
.rw-r--r--@  987 peteyoung 13 Jul 00:00 ├── dot_psqlrc
.rw-r--r--@ 1.8k peteyoung 13 Jul 00:00 ├── dot_tmux.conf
.rw-r--r--@ 2.5k peteyoung 13 Jul 00:00 ├── dot_vimrc
.rw-r--r--@    0 peteyoung 13 Jul 00:00 ├── dot_zprofile
.rw-r--r--@ 2.1k peteyoung 13 Jul 00:00 ├── dot_zsh_local
.rw-r--r--@ 2.2k peteyoung 13 Jul 00:00 ├── dot_zshrc
.rw-r--r--@  102 peteyoung 13 Jul 00:00 ├── README.md
.rw-r--r--@  42k peteyoung 13 Jul 00:00 ├── 'Switch to chezmoi.md'
drwxr-xr-x@    - peteyoung 13 Jul 00:00 └── Windows
.rw-r--r--@ 1.4k peteyoung 13 Jul 00:00     ├── link_powershell_configs.ps1
drwxr-xr-x@    - peteyoung 13 Jul 00:00     └── PowerShell
.rw-r--r--@ 5.8k peteyoung 13 Jul 00:00         └── Microsoft.PowerShell_profile.ps1
```

They're the same except for `.DS_Store`.

[⬆️](#toc)


## Resources                                                                     <a id="resources" />

* chezmoi Documentation
    * [User Guide](https://www.chezmoi.io/user-guide/command-overview/)
    * [Reference](https://www.chezmoi.io/reference/)
        * [Config file](https://www.chezmoi.io/reference/configuration-file/)
            * [Config file settings, a.k.a. Variables](https://www.chezmoi.io/reference/configuration-file/variables/)
        * [Filename prefixes and suffixes, a.k.a. Attributes](https://www.chezmoi.io/reference/source-state-attributes/)
        * [Script filename prefixes and suffixes, a.k.a. Hooks](https://www.chezmoi.io/reference/configuration-file/hooks/)
        * [Symbolic links](https://www.chezmoi.io/reference/target-types/#symbolic-links)
            * [Symlink mode](https://www.chezmoi.io/reference/target-types/#symlink-mode)
        * [Commands](https://www.chezmoi.io/reference/commands/)
* Video
    * Chezmoi
        * [Automating Development Environments with Ansible & Chezmoi](https://www.youtube.com/watch?v=P4nI1VhoN2Y)
        * [Chris Titus Tech: Easily moving Linux installs](https://www.youtube.com/watch?v=x6063EuxfEA)
        * [Singularity Club: The ultimate dotfiles setup](https://www.youtube.com/watch?v=-RkANM9FfTM)
        * [chezmoi: Organize your dotfiles across multiple computers](https://www.youtube.com/watch?v=L_Y3s0PS_Cg)
    * Gnu Stow
        * [typecraft: NEVER lose dotfiles again with GNU Stow](https://www.youtube.com/watch?v=NoFiYOqnC4o)
        * [Dreams of Autonomy: Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs)
        * [Manage Your Dotfiles Like A Superhero](https://www.youtube.com/watch?v=FHuwzbpTTo0)
        * [DevOps Toolbox: ~/.dotfiles 101: A Zero to Configuration Hero Blueprint](https://www.youtube.com/watch?v=WpQ5YiM7rD4)
        * [System Crafters: Give Your Dotfiles a Home with GNU Stow](https://www.youtube.com/watch?v=CxAT1u8G7is)
    * dotfiles
        * [System Crafters: How to Create a Dotfiles Folder](https://www.youtube.com/watch?v=gibqkbdVbeY)