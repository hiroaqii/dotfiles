#!/usr/bin/env bash
set -euo pipefail
action=${1:?Specify plan, status, or apply}
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
packages=(fcitx5 fcitx5-mozc fcitx5-gtk fcitx5-qt fcitx5-configtool)
case "$action" in
  plan|status)
    for package in "${packages[@]}"; do
      if pacman -Q "$package" >/dev/null 2>&1; then
        echo "Japanese input: $package installed"
      else
        echo "Japanese input: $package missing (setup will install)"
      fi
    done
    echo 'Japanese input: enable Mozc in the active Fcitx5 group; preserve keyboard shortcuts.'
    echo 'Japanese input: use Omarchy fcitx5 service and environment settings.'
    ;;
  apply)
    for package in "${packages[@]}"; do
      if ! pacman -Q "$package" >/dev/null 2>&1; then
        omarchy pkg add "$package"
      fi
    done
    mise -C "$root/mise" -E "${MISE_ENV:?}" exec -- python "$root/scripts/configure-mozc.py" "${XDG_CONFIG_HOME:-$HOME/.config}/fcitx5/profile"
    systemctl --user enable --now omarchy-fcitx5.service
    fcitx5-remote -r
    echo 'Japanese input configured. Log out and back in if this is the first installation.'
    ;;
  *) echo "Unknown action: $action" >&2; exit 1 ;;
esac
