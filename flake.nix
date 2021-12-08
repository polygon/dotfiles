{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    aww = {
      url = "github:polygon/awesome-wm-widgets/poly";
      flake = false;
    };
  };

  outputs = inputs@{self, nixpkgs, unstable, home-manager, fup, aww, ...}:
  fup.lib.mkFlake {
    inherit self inputs;

    supportedSystems = [ "x86_64-linux" ];

    channelsConfig = {
      allowUnfree = true;
    };

    channels.nixpkgs.overlaysBuilder = channels: [
      (final: super: {
	      geeqie = channels.unstable.geeqie;
  	    blender = channels.unstable.blender;
    	  zsh-prezto = super.zsh-prezto.overrideAttrs (old: {
      	  patches = (old.patches or []) ++ [
        	  ./zsh/0001-poly-prompt.patch
        	];
      	});
			})
    ];

    hostDefaults.modules = [
      ./modules

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ ./hmmodules ];
        home-manager.extraSpecialArgs = { inherit aww self; };
      }
    ];

    hosts.nixbrett = rec {
      system = "x86_64-linux";

      modules = [
        ./systems/nixbrett/nixbrett.nix
				{
          home-manager.users.jan.imports = [ ./users/jan.nix ];
          home-manager.users.dude.imports = [ ./users/dude.nix ];
        }
      ];
      
			specialArgs = { unstable = unstable.legacyPackages.${system}; inherit self; };
    };
  };
}

