# General settings
export EDITOR='nvim'
export TERM='xterm-256color'

# Speed up zsh startup
source ~/.config/zsh/zsh-defer/zsh-defer.plugin.zsh
# function zsh-defer() { eval "$@" }

# oh-my-zsh features
source ~/.config/zsh/omz.zsh
zsh-defer source ~/.config/zsh/omz-sudo.zsh

# Fish-like features
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
zsh-defer source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# My settings
fpath+=(~/bin ~/.local/bin)
export PATH=~/bin:~/.local/bin:~/.cargo/bin:$PATH

alias vim='nvim'
alias ls='eza'
alias ll='eza -l --octal-permissions'
alias la='eza -la --octal-permissions'
alias tree='eza --tree'

export COLOR_LIGHT='#90a0bf'
export COLOR_DARK='#21283b'

alias folder='xdg-open'
alias wol='curl -X POST http://10.0.1.2:8000/wol && ping 10.0.1.11'
alias t='tmux-sessionizer'
alias sync-dotfiles='stow -d ~/dotfiles -R . --no-folding'
alias zsh-reload="exec zsh"
alias ansi-remove='sed "s/\x1B\[[0-9;]*[a-zA-Z]//g"'

bootwindows() {
    sudo efibootmgr -n $(efibootmgr | grep "Windows" | grep -oE '[0-9]+') >/dev/null
    echo "Booting up from Windows on next boot"
}

__env_vars() {
    export GPG_TTY=$TTY
    export SUDO_EDITOR=$(command -v nvim)
    source ~/.env || true

    if [[ "$(uname)" == "Darwin" ]]; then
        export COPY_CMD="pbcopy"
    elif [[ "$(uname -r)" =~ "[Mm]icrosoft" ]]; then
        export COPY_CMD="clip.exe"
    elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        export COPY_CMD="wl-copy"
    else
        export COPY_CMD="xclip -selection clipboard -i"
    fi
    alias copy="$COPY_CMD"

    unset -f __env_vars
}
zsh-defer __env_vars

# Python
export MKL_DEBUG_CPU_TYPE=5
export PYDEVD_DISABLE_FILE_VALIDATION=1
export JUPYTER_PLATFORM_DIRS=1
alias pipe='python -m pip install --no-deps --disable-pip-version-check -ve .'
alias ppt='pytest -n logical --dist loadgroup -qq'
alias pptx='pytest -n logical --dist loadscope --nbval-lax -p no:python -qq'
alias uvc='[ -n "$CONDA_PREFIX" ] && uv pip install --system'
alias debugpy-inject='echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope'
import-time() { python -X importtime -c "import $1" 2> /tmp/tuna.log && tuna /tmp/tuna.log }
zsh-defer source ~/.config/zsh/python.zsh

# Holoviz
export HOLOVIZ_REP=~/projects/holoviz/repos/
export HOLOVIZ_DEV=~/projects/holoviz/
alias panel-kill='lsof -c panel -t | xargs -r kill'
zsh-defer source ~/projects/holoviz-tools/holoviz.zsh

# Apps
__zoxide() { eval "$(zoxide init zsh)" && unset -f __zoxide }; zsh-defer __zoxide
__fzf() { eval "$(fzf --zsh)" && unset -f __fzf }; zsh-defer __fzf
export FZF_DEFAULT_COMMAND="fd --type=f --hidden --follow --strip-cwd-prefix"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --follow --strip-cwd-prefix"
export FZF_DEFAULT_OPTS="--bind=shift-tab:down,tab:up --color=fg:$COLOR_LIGHT,fg+:$COLOR_DARK,bg+:$COLOR_LIGHT,prompt:1,pointer:$COLOR_LIGHT,gutter:-1,hl:1,hl+:1"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"
eval "$(starship init zsh)"

# Autocompletion
autoload -Uz compinit
zsh-defer compinit
