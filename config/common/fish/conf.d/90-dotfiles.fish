# Shared interactive settings for macOS and Omarchy.
# conf.d keeps the user's config.fish available for local overrides.
status is-interactive; or return

if not set -q HOMEBREW_PREFIX
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv fish | source
    else if test -x /usr/local/bin/brew
        /usr/local/bin/brew shellenv fish | source
    end
end
fish_add_path --global --path "$HOME/.local/bin" "$HOME/bin"

if command -q mise
    mise activate fish | source
end

if not set -q EDITOR; or test -z "$EDITOR"
    if command -q nvim
        set -gx EDITOR nvim
    else
        set -gx EDITOR vi
    end
end
if not set -q VISUAL; or test -z "$VISUAL"
    set -gx VISUAL "$EDITOR"
end
if not set -q PAGER; or test -z "$PAGER"
    set -gx PAGER less
end
if not set -q LESS; or test -z "$LESS"
    set -gx LESS '-R -F'
end
if not set -q CLICOLOR; or test -z "$CLICOLOR"
    set -gx CLICOLOR 1
end
if not set -q FZF_DEFAULT_OPTS; or test -z "$FZF_DEFAULT_OPTS"
    set -gx FZF_DEFAULT_OPTS '--height=40% --layout=reverse --border'
end

if command -q lsd
    alias ls 'lsd'
    alias lt 'lsd --tree'
    alias lS 'lsd --sizesort'
end
alias ll 'ls -laF'
alias l 'ls -1'
alias .. 'cd ..'
alias ... 'cd ../..'

if command -q starship
    starship init fish | source
end
if command -q zoxide
    zoxide init fish | source
end
