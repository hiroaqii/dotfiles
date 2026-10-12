#!/usr/bin/env bash
set -euo pipefail
hypr_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
config="$hypr_dir/hyprland.lua"
[[ -f "$config" ]] || { echo "Missing Hyprland config: $config" >&2; exit 1; }
# Append after user overrides so the managed mouse preference takes precedence.
if ! grep -qF -- '-- BEGIN mise-dotfiles mouse' "$config"; then
  cp -p "$config" "$config.bak.$(date +%Y%m%d-%H%M%S)"
  cat >> "$config" <<'LUA'

-- BEGIN mise-dotfiles mouse
dofile((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr/dotfiles-mouse.lua")
-- END mise-dotfiles mouse
LUA
fi
# Apply only when a graphical Hyprland session is available.
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload
  errors=$(hyprctl configerrors)
  if [[ -n ${errors//[[:space:]]/} ]]; then
    printf '%s\n' "$errors" >&2
    exit 1
  fi
fi
