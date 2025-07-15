{
  # Refresh using  "darwin-rebuild switch --flake ~/nix"

  description = "Lux nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
	  pkgs.obsidian
	  pkgs.mkalias
	  pkgs.vscodium
        ];

	homebrew = {
	  enable = true;
	  brews = [ # Standard Brew Packages
	    "mas"
	    "git"
	    "starship"
	    "syncthing"
	    "sketchybar"
	    "lua"
	  ];
	  casks = [ # Native Mac Apps ex: VSCode Chrome
	    "firefox"
	    "spotify"
	    "ghostty"
	    "nikitabobko/tap/aerospace"
	    "raycast"
	    "surfshark"
	    "vlc"
	    "localsend"
	    "brave-browser"
	    "balenaetcher"
	    "mpv"
	    ];
	  taps = [
	    #"FelixKratz/formulae"
	  ];
	  masApps = { # Mac App Store Apps
	   # "Yoink" = 1260915283;  # Do mas search *appname* for id
	    };
	    onActivation.cleanup = "zap";
	    onActivation.autoUpdate = true;
	    onActivation.upgrade = true;
	};

      fonts.packages = [
      pkgs.nerd-fonts.caskaydia-mono
      ];

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
          while IFS= read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      system.defaults = { # System Settings
      	dock.autohide = true;
	dock.persistent-apps = [
	"/Applications/Firefox.app"
	"${pkgs.obsidian}/Applications/Obsidian.app"
	"/Applications/Ghostty.app"
	"/Applications/Spotify.app"
	"${pkgs.vscodium}/Applications/VSCodium.app"
	];
      	finder.FXPreferredViewStyle = "clmv";
	NSGlobalDomain.AppleInterfaceStyle = "Dark";
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Adams-MacBook-Air
    darwinConfigurations."Adams-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [
      configuration
      nix-homebrew.darwinModules.nix-homebrew
      {
      	nix-homebrew = {
		enable = true;
		# Apple Silicon Only
		enableRosetta = true;
		# User owning the Homebrew prefix
		user = "lux";
	};
      }
    ];
    };
    };
}
