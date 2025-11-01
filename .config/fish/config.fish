if status is-interactive
  function link_from_nix_store -a name target
	set -l NIX_DIR_PATH (find /nix/store \
	  -maxdepth 1 \
	  -type d \
	  -name "*-$name*" \
	  -print -quit
	)
	set -l EXISTING_SYMLINK (readlink $target)

	if not set -q EXISTING_SYMLINK; or test "$EXISTING_SYMLINK" != "$NIX_DIR_PATH"
	  echo "Updating symlink for $name"

	  if test -n "$EXISTING_SYMLINK"
	    unlink $target
	  end

	  ln -sf "$NIX_DIR_PATH" "$target"
	end
  end

  link_from_nix_store 'alacritty-theme' ~/.config/alacritty/themes
  link_from_nix_store 'tpm' ~/.config/tmux/plugins/tpm

  zoxide init fish | source
  oh-my-posh init fish --config ~/.config/oh-my-posh/config.toml | source
end

# opencode
fish_add_path /Users/alejandro/.opencode/bin
