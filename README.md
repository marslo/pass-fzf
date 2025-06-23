# pass-fzf
An extension for [pass](https://www.passwordstore.org/) that allows fuzzy
finding in the store ( `$PASSWORD_STORE_DIR` ).

> [!TIP]
> requires [`fzf`](https://github.com/junegunn/fzf) to be installed in the system ( [how to install fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#installation) ).

# Installation

```bash
curl -fsSL --create-dirs \
     --create-file-mode 755 \
     --output $PASSWORD_STORE_DIR/.extensions/fzf.bash \
     https://github.com/marslo/pass-fzf/raw/master/fzf.bash &&
chmod +x $PASSWORD_STORE_DIR/.extensions/fzf.bash
```

```bash
# temporarily
$ PASSWORD_STORE_ENABLE_EXTENSIONS=true pass fzf

# permanently
$ echo 'export PASSWORD_STORE_ENABLE_EXTENSIONS=true' >> ~/.bashrc
$ pass fzf
```

# Usage

![pass fzf --help](./screenshots/pass-fzf-help.png)

```bash
$ pass fzf --help

USAGE
  $ pass fzf [OPTIONS] [SUB_COMMAND] [QUERY]

OPTIONS
  -s           only output selected path without run 'pass'
  -h, --help   show this help message

EXAMPLES
  $ pass fzf                  → pass -c <selected>
  $ pass fzf show             → pass show <selected>
  $ pass fzf github           → fzf search with 'github', then pass -c <selected>
  $ pass fzf -c               → pass -c <selected>
  $ pass fzf edit             → pass edit <selected>
  $ pass fzf -s               → just print path
  $ pass fzf -s github        → just print path (query='github')

NOTE:
  • supported pass sub-commands : -c/--clip, show, edit, rm
  • if no sub-command is given, the default is -c/--clip (clipboard)
  • environment variables that can be set PASSWORD_STORE_DIR, PASSWORD_STORE_CLIP_TIM
```

# Alias
```bash
$ alias passs='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass fzf'
```
