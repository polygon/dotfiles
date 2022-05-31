{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    aww = {
      url = "github:polygon/awesome-wm-widgets/poly";
      flake = false;
    };
    audio.url = "github:polygon/audio.nix";
    microvm = {
      url = "github:astro/microvm.nix";
      #url = "path:/home/admin/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{self, nixpkgs, unstable, home-manager, fup, aww, audio, microvm, ...}:
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
        cloud-hypervisor = channels.unstable.cloud-hypervisor;
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
        home-manager.sharedModules = [ ./hmmodules audio.hmModule ];
        home-manager.extraSpecialArgs = { inherit aww self audio; };
      }
    ];

    hosts.nixbrett = rec {
      system = "x86_64-linux";

      modules = [
        ./systems/nixbrett/nixbrett.nix
				{
          home-manager.users.jan = import ./users/jan/nixbrett.nix;
          home-manager.users.dude = import ./users/dude.nix;
        }
      ];
      
      specialArgs = { unstable = unstable.legacyPackages.${system}; inherit self; };
    };
    
    hosts.travelnix = rec {
      system = "x86_64-linux";

      modules = [
        ./systems/travelnix/travelnix.nix
        {
          home-manager.users.jan = import ./users/jan/common.nix;
        }
      ];
      
      specialArgs = { unstable = unstable.legacyPackages.${system}; inherit self; };
    };
    
    hosts.nixserv = rec {
      system = "x86_64-linux";

      modules = [
        ./systems/nixserv/nixserv.nix
        microvm.nixosModules.host
        {
          home-manager.users.admin = import ./users/admin.nix;
        }
      ];
      
      specialArgs = { unstable = unstable.legacyPackages.${system}; inherit self; };
    };

    hosts.playground = rec {
      system = "x86_64-linux";

      modules = [
        microvm.nixosModules.microvm
        ./systems/microvms/playground
      ];

      channelName = "unstable";
      
      specialArgs = { unstable = unstable.legacyPackages.${system}; inherit self; };
    };

    hosts.paperless = rec {
      system = "x86_64-linux";

      modules = [
        microvm.nixosModules.microvm
        ./systems/microvms/paperless
      ];

      channelName = "unstable";
      
      specialArgs = { unstable = unstable.legacyPackages.${system}; inherit self; };
    };

    outputsBuilder = channels: {
      packages.microvm-kernel = microvm.packages.x86_64-linux.microvm-kernel;
    };

  };
}
