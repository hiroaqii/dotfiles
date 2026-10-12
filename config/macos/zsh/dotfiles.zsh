# Interactive settings, loaded by the managed block in ~/.zshrc.
[[ -o interactive ]] || return

# Homebrew may be installed for Mac-only applications; support both prefixes.
if [[ -z ${HOMEBREW_PREFIX:-} ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/bin" $path)
export PATH

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Respect explicit choices and the terminal's TERM value.
if [[ -z ${EDITOR:-} ]]; then
  if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
  else
    export EDITOR=vi
  fi
fi
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R -F}"
export CLICOLOR="${CLICOLOR:-1}"

HISTSIZE=100000
SAVEHIST=100000
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
unsetopt INC_APPEND_HISTORY INC_APPEND_HISTORY_TIME
setopt APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS
setopt HIST_NO_STORE EXTENDED_HISTORY HIST_VERIFY
bindkey -e
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=40% --layout=reverse --border}"

if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
fi
alias ll='ls -laF'
alias l='ls -1'
alias lt='ls --tree'
alias lS='ls --sizesort'
alias ..='cd ..'
alias ...='cd ../..'

# Add completion definitions before compinit; widget plugins come afterwards.
_dotfiles_zsh_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -r "$HOME/.local/share/antidote/antidote.zsh" ]]; then
  source "$HOME/.local/share/antidote/antidote.zsh"
  source <(antidote bundle < "$_dotfiles_zsh_dir/completions.txt")
fi
autoload -Uz compinit
_dotfiles_compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
command mkdir -p "${_dotfiles_compdump:h}"
compinit -d "$_dotfiles_compdump"
if command -v terraform >/dev/null 2>&1; then
  autoload -Uz bashcompinit
  bashcompinit
  complete -o nospace -C "$(command -v terraform)" terraform
fi
if (( $+functions[antidote] )); then
  antidote load "$_dotfiles_zsh_dir/plugins.txt"
fi
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
[[ ! -r "$_dotfiles_zsh_dir/local.zsh" ]] || source "$_dotfiles_zsh_dir/local.zsh"
unset _dotfiles_zsh_dir _dotfiles_compdump
