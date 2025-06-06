if status is-interactive
    set fish_tmux_autostart true
end
set -U fish_greeting ""
fish_vi_key_bindings
set fish_color_valid_path
#fzf_configure_bindings
function fish_mode_prompt
  # NOOP - Disable vim mode indicator
end
alias bat=batcat
alias vi=nvim
