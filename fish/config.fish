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

set -gx CLAUDE_GCLOUD_ACCOUNT claude-readonly@daekon-ai.iam.gserviceaccount.com

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/david/Downloads/google-cloud-sdk/path.fish.inc' ]; . '/Users/david/Downloads/google-cloud-sdk/path.fish.inc'; end
