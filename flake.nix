{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    aww = {
      url = "github:polygon/awesome-wm-widgets/poly";
      flake = false;
    };
    audio = {
      url = "github:polygon/audio.nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix/v0.5.0";
      #url = "path:/home/admin/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets.url = "git+ssh://git@github.com/polygon/secrets.git";
    scalpel = {
      url = "github:polygon/scalpel";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.sops-nix.follows = "sops-nix";
    };
    mqtt2psql = {
      url = "github:polygon/mqtt2psql";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-db.url = "github:Mic92/nix-index-database";
    nixd.url = "github:nix-community/nixd";
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver.url =
      "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
    nixpkgs-spacenavd.url = "github:polygon/nixpkgs/update-spacenavd";
    blender-bin = {
      url = "github:edolstra/nix-warez?dir=blender";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    midimaxe = {
      url = "github:polygon/midimaxe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hover = {
      url = "github:max-privatevoid/hover";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #    winery = {
    #      url = "path:/home/jan/Projects/winery";
    #      inputs.nixpkgs.follows = "nixpkgs";
    #    };
  };

  outputs = inputs@{ self, nixpkgs, unstable, home-manager, fup, aww, audio
    , microvm, scalpel, secrets, sops-nix, mqtt2psql, nix-index-db, nixd
    , vscode-server, simple-nixos-mailserver, nixpkgs-spacenavd, blender-bin
    , midimaxe, nixos-hardware, hover, ... }:
    fup.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" ];

      channelsConfig = { allowUnfree = true; };

      channels.nixpkgs.overlaysBuilder = channels:
        [
          (final: super: {
            geeqie = channels.unstable.geeqie;
            #blender = channels.unstable.blender;
            siril = channels.unstable.siril;
            vscodium = channels.unstable.vscodium;
            bitwig-studio = channels.unstable.bitwig-studio;
            zsh-prezto = super.zsh-prezto.overrideAttrs (old: {
              patches = (old.patches or [ ])
                ++ [ ./zsh/0001-poly-prompt.patch ];
            });
          })
        ];

      overlay = let
        system = "x86_64-linux";
        pkgsunstable = import unstable {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [ "electron-25.9.0" ];
        };
        pkgs = import nixpkgs { inherit system; };
      in (final: super: {
        geeqie = pkgsunstable.geeqie;
        #blender = pkgsunstable.blender;
        zsh-prezto = super.zsh-prezto.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./zsh/0001-poly-prompt.patch ];
        });
        siril = pkgsunstable.siril;
        vscodium = pkgsunstable.vscodium;
        obsidian = pkgsunstable.obsidian;
        nixd = nixd.packages.${system}.nixd;
        #distrho = pkgsunstable.distrho;
        #geonkick = pkgsunstable.geonkick;
        #x42-plugins = pkgsunstable.x42-plugins;
        #dragonfly-reverb = pkgsunstable.dragonfly-reverb;
        #yabridge = pkgsunstable.yabridge;
        #yabridgectl = pkgsunstable.yabridgectl;
        syncthing = pkgsunstable.syncthing;
        freecad = pkgsunstable.freecad;
        spacenavd = nixpkgs-spacenavd.legacyPackages.${system}.spacenavd;
        blender-bin = blender-bin.packages.${system}.blender_4_1;
        midimaxe = midimaxe.packages.${system}.midimaxe;
        hover = hover.packages.${system}.default;
      });

      hostDefaults.modules = [
        ./modules

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ ./hmmodules ];
          home-manager.extraSpecialArgs = { inherit aww self audio; };
        }
      ];

      outputsBuilder = channels: {
        packages.microvm-kernel = microvm.packages.x86_64-linux.microvm-kernel;
      };

      nixosConfigurations = let
        nixosSystem' =
          # Custom NixOS builder
          { nixpkgs ? inputs.nixpkgs, modules, extraArgs ? { }
          , system ? "x86_64-linux", specialArgs ? { }, allowUnfree ? false }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ({ pkgs, ... }: {
                nixpkgs = {
                  overlays = [ self.overlay audio.overlays.default ];
                };
              })
              ./modules

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.sharedModules = [
                  ./hmmodules
                  "${vscode-server}/modules/vscode-server/home.nix"
                  nix-index-db.hmModules.nix-index
                ];
                home-manager.extraSpecialArgs = { inherit aww self audio; };
              }
            ] ++ modules;
            specialArgs = {
              unstable = unstable.legacyPackages.${system};
              inherit self secrets simple-nixos-mailserver;
            } // specialArgs;
          };
      in {
        playground = let
          base = nixosSystem' rec {
            system = "x86_64-linux";

            modules = [
              microvm.nixosModules.microvm
              sops-nix.nixosModules.sops
              ./systems/microvms/playground
            ];
          };
        in base.extendModules {
          modules = [
            scalpel.nixosModules.scalpel
            ./systems/microvms/playground/scalpel.nix
          ];
          specialArgs = { prev = base; };
        };

        hal = let
          base = nixosSystem' rec {
            system = "x86_64-linux";

            modules = [
              microvm.nixosModules.microvm
              sops-nix.nixosModules.sops
              ./systems/microvms/hal
            ];
            specialArgs = { inherit mqtt2psql; };
          };
        in base.extendModules {
          modules =
            [ scalpel.nixosModules.scalpel ./systems/microvms/hal/scalpel ];
          specialArgs = { prev = base; };
        };

        paperless = let
          base = nixosSystem' rec {
            system = "x86_64-linux";

            modules = [
              microvm.nixosModules.microvm
              sops-nix.nixosModules.sops
              ./systems/microvms/paperless
            ];
          };
        in base.extendModules {
          modules = [
            scalpel.nixosModules.scalpel
            ./systems/microvms/paperless/scalpel.nix
          ];
          specialArgs = { prev = base; };
        };

        cloud = nixosSystem' rec {
          system = "x86_64-linux";

          modules = [
            microvm.nixosModules.microvm
            sops-nix.nixosModules.sops
            ./systems/microvms/cloud
          ];
        };

        cube = nixosSystem' rec {
          system = "x86_64-linux";

          modules = [
            ./systems/cube
            audio.nixosModules.yabridgemgr
            {
              home-manager.users.jan = import ./users/jan/cube.nix;
              home-manager.users.dude = import ./users/dude.nix;
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };

        nixbrett = nixosSystem' rec {
          system = "x86_64-linux";

          modules = [
            ./systems/nixbrett
            audio.nixosModules.yabridgemgr
            {
              home-manager.users.jan = import ./users/jan/nixbrett.nix;
              home-manager.users.dude = import ./users/dude.nix;
              nixpkgs.config.allowUnfree = true;
            }
            sops-nix.nixosModules.sops
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
          ];
        };

        nubego = nixosSystem' rec {
          system = "x86_64-linux";

          modules = [
            ./systems/nubego
            simple-nixos-mailserver.nixosModule
            { home-manager.users.admin = import ./users/admin.nix; }
            sops-nix.nixosModules.sops
          ];
        };

        nixserv = nixosSystem' rec {
          system = "x86_64-linux";

          modules = [
            ./systems/nixserv/nixserv.nix
            microvm.nixosModules.host
            { home-manager.users.admin = import ./users/admin.nix; }
          ];

          specialArgs = {
            unstable = unstable.legacyPackages.${system};
            inherit self;
          };
        };

        midimaxe = nixosSystem' {
          system = "x86_64-linux";

          modules = [
            ./systems/travelnix/midimaxe.nix
            { home-manager.users.midimaxe = import ./users/midimaxe.nix; }
          ];
        };
      };
    };
}
