{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
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
	{
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.alacritty
		  pkgs.docker
		  pkgs.elixir_1_18
          pkgs.fish
          pkgs.git
		  pkgs.gleam
		  pkgs.just
		  pkgs.mkalias
          pkgs.neovim
          pkgs.nodejs
		  pkgs.oh-my-posh
		  pkgs.php82
		  pkgs.php82Packages.composer
		  pkgs.python311
		  pkgs.python311Packages.pip
		  pkgs.redis
		  pkgs.ripgrep
		  pkgs.rustup
          pkgs.stow
		  pkgs.tmux
		  pkgs.twitch-cli
		  pkgs.xz
		  pkgs.yarn
		  pkgs.zig
		  pkgs.zoxide
		  tmuxplugins
        ];
	  
	  fonts.packages = [
		pkgs.nerd-fonts.fira-code
	    pkgs.nerd-fonts.jetbrains-mono
	  ];

	  homebrew = {
		enable = true;
		brews = [
			"imagemagick"
			{
				name = "postgresql@17";
				start_service = true;
			}
		];
		casks = [
		  "amethyst"
		  "discord"
		  "firefox"
		  "ghostty"
		  "google-chrome"
		  "notion"
		  "obs"
		  "rar"
		  "steam"
		];
		onActivation.cleanup = "zap";
		onActivation.autoUpdate = true;
		onActivation.upgrade = true;
	  };

	  services.postgresql = {
		enable = true;
		package = pkgs.postgresql_16;
		dataDir = "/Users/arze/.local/share/postgres";
		authentication = ''
		local   all   all                  trust
		host    all   all   127.0.0.1/32   trust
		host    all   all   ::1/128        trust
		'';
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
		  "/Applications/Firefox.app"
		  "/Applications/Ghostty.app"
		];
		finder.FXPreferredViewStyle = "clmv";
		NSGlobalDomain.AppleICUForce24HourTime = true;
	  };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
	  users.knownUsers = [ "arze" ];
	  users.users.arze.uid = 501;
	  users.users.arze.shell = pkgs.fish;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

	  system.primaryUser = "arze";

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
	  nixpkgs.config.allowUnfree = true;
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
			user = "arze";
		  };
		}
	  ];
    };
  };
}
