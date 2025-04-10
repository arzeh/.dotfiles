{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/53d0f0ed11487a4476741fde757d0feabef4cc4e";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
	nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, lib, ... }:
	let tmuxplugins = pkgs.stdenv.mkDerivation {
	  name = "tpm";
	  src = pkgs.fetchFromGitHub {
	    owner = "tmux-plugins";
		repo = "tpm";
		rev = "99469c4a9b1ccf77fade25842dc7bafbc8ce9946";
		sha256 = "hW8mfwB8F9ZkTQ72WQp/1fy8KL1IIYMZBtZYIwZdMQc=";
	  };
	  installPhase = ''
	  cp -r $src $out
	  '';
	};
	in
	let alacritty-theme = pkgs.stdenv.mkDerivation {
	  name = "alacritty-theme";
	  src = pkgs.fetchFromGitHub {
	    owner = "alacritty";
		repo = "alacritty-theme";
		rev = "aff9d111d43e1ad5c22d4e27fc1c98176e849fb9";
		sha256 = "IQubMo048bS+RFw/5Gcwlj6fTuadn8r2Q1kZ3ezJR9Q=";
	  };
	  installPhase = ''
	  cp -r $src $out
	  '';
	};
	in
	{
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
		  alacritty-theme
          pkgs.alacritty
		  pkgs.elixir_1_18
          pkgs.fish
          pkgs.git
		  pkgs.mkalias
          pkgs.neovim
          pkgs.nodejs
		  pkgs.ripgrep
          pkgs.stow
		  pkgs.tmux
		  pkgs.twitch-cli
		  pkgs.yarn
		  pkgs.zoxide
		  tmuxplugins
        ];
	  
	  fonts.packages = [
	    pkgs.nerd-fonts.jetbrains-mono
	  ];

	  homebrew = {
		enable = true;
		casks = [
		  "amethyst"
		  "discord"
		  "firefox"
		  "google-chrome"
		  "jandedobbeleer/oh-my-posh/oh-my-posh"
		  "notion"
		  "obs"
		  "steam"
		];
		onActivation.cleanup = "zap";
		onActivation.autoUpdate = true;
		onActivation.upgrade = true;
	  };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

	  system.defaults = {
	    dock.autohide = true;
		dock.persistent-apps = [
		  "${pkgs.alacritty}/Applications/Alacritty.app"
		  "/Applications/Firefox.app"
		];
		finder.FXPreferredViewStyle = "clmv";
		NSGlobalDomain.AppleICUForce24HourTime = true;
	  };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
	  users.knownUsers = [ "alejandro" ];
	  users.users.alejandro.uid = 501;
	  users.users.alejandro.shell = pkgs.fish;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [
	    configuration
		nix-homebrew.darwinModules.nix-homebrew {
		  nix-homebrew = {
			enable = true;
			enableRosetta = true;
			user = "alejandro";
		  };
		}
	  ];
    };
  };
}
