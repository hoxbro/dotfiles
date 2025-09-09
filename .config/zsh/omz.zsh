# HISTORY
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify share_history

# KEY BINDINGS
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh
# Use emacs key bindings
bindkey -e

# Start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search

bindkey -M emacs "^[[A" up-line-or-beginning-search
bindkey -M viins "^[[A" up-line-or-beginning-search
bindkey -M vicmd "^[[A" up-line-or-beginning-search
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M viins "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search
fi

# Start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -M emacs "^[[B" down-line-or-beginning-search
bindkey -M viins "^[[B" down-line-or-beginning-search
bindkey -M vicmd "^[[B" down-line-or-beginning-search
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M viins "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Ctrl-Delete] - delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word
bindkey -M viins '^[[3;5~' kill-word
bindkey -M vicmd '^[[3;5~' kill-word

# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M viins '^[[1;5C' forward-word
bindkey -M vicmd '^[[1;5C' forward-word

# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M vicmd '^[[1;5D' backward-word

# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
fi

# COMPLETION
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh
WORDCHARS='' # Ctrl + w only delete word at a time
unsetopt menu_complete flowcontrol
setopt auto_menu complete_in_word always_to_end
zstyle ':completion:*:*:*:*:*' menu select

# https://stackoverflow.com/questions/890620/unable-to-have-bash-like-c-x-e-in-zsh/903973#903973
autoload edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line

setopt autocd
