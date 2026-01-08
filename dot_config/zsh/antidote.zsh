# ~/.config/zsh/antidote.zsh
# managed by chezmoi

# --- locate antidote ---
if [[ -f "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
elif [[ -f "$HOME/.local/share/antidote/antidote.zsh" ]]; then
  source "$HOME/.local/share/antidote/antidote.zsh"
elif command -v brew >/dev/null 2>&1; then
  _antidote="$(brew --prefix 2>/dev/null)/share/antidote/antidote.zsh"
  [[ -f "$_antidote" ]] && source "$_antidote"
fi

# --- load plugins ---
if typeset -f antidote >/dev/null 2>&1; then
  local bundle_file="$HOME/.config/zsh/plugins.txt"
  local static_file="$HOME/.config/zsh/.zsh_plugins.zsh"

  # Generate static bundle for faster startup
  if [[ ! -f "$static_file" || "$bundle_file" -nt "$static_file" ]]; then
    antidote bundle < "$bundle_file" >| "$static_file"
  fi
  source "$static_file"
fi

