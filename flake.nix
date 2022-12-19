{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    aww = {
      url = "github:polygon/awesome-wm-widgets/poly";
      flake = false;
    };
    audio.url = "github:polygon/audio.nix";
    microvm = {
      url = "github:astro/microvm.nix/v0.2.2";
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
  };

  outputs = inputs@{ self, nixpkgs, unstable, home-manager, fup, aww, audio, microvm, scalpel, secrets, sops-nix, mqtt2psql, ... }:
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
          siril = channels.unstable.siril;
          vscodium = channels.unstable.vscodium;
          zsh-prezto = super.zsh-prezto.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./zsh/0001-poly-prompt.patch
            ];
          });
        })
      ];

      overlay =
        let
          pkgsunstable = unstable.legacyPackages.x86_64-linux;
        in
        (final: super: {
          geeqie = pkgsunstable.geeqie;
          blender = pkgsunstable.blender;
          zsh-prezto = super.zsh-prezto.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./zsh/0001-poly-prompt.patch
            ];
          });
        });

      hostDefaults.modules = [
        ./modules

        home-manager.nixosModules.home-manager
        {
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

      outputsBuilder = channels: {
        packages.microvm-kernel = microvm.packages.x86_64-linux.microvm-kernel;
      };

      nixosConfigurations =
        let
          nixosSystem' =
            # Custom NixOS builder
            { nixpkgs ? inputs.nixpkgs, modules, extraArgs ? { }, system ? "x86_64-linux", specialArgs ? { } }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                ({ pkgs, ... }: {
                  nixpkgs = {
                    overlays = [ self.overlay ];
                  };
                })
                ./modules

                home-manager.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.sharedModules = [ ./hmmodules audio.hmModule ];
                  home-manager.extraSpecialArgs = { inherit aww self audio; };
                }
              ] ++ modules;
              specialArgs = {
                unstable = unstable.legacyPackages.${system};
                inherit self secrets;
              } // specialArgs;
            };
        in
        {
          playground =
            let
              base = nixosSystem' rec {
                system = "x86_64-linux";

                modules = [
                  microvm.nixosModules.microvm
                  sops-nix.nixosModules.sops
                  ./systems/microvms/playground
                ];
              };
            in
            base.extendModules {
              modules = [
                scalpel.nixosModules.scalpel
                ./systems/microvms/playground/scalpel.nix
              ];
              specialArgs = { prev = base; };
            };

          hal =
            let
              base = nixosSystem' rec {
                system = "x86_64-linux";

                modules = [
                  microvm.nixosModules.microvm
                  sops-nix.nixosModules.sops
                  ./systems/microvms/hal
                ];
                specialArgs = { inherit mqtt2psql; };
              };
            in
            base.extendModules {
              modules = [
                scalpel.nixosModules.scalpel
                ./systems/microvms/hal/scalpel
              ];
              specialArgs = { prev = base; };
            };

          paperless =
            let
              base = nixosSystem' rec {
                system = "x86_64-linux";

                modules = [
                  microvm.nixosModules.microvm
                  sops-nix.nixosModules.sops
                  ./systems/microvms/paperless
                ];
              };
            in
            base.extendModules {
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
            ];
          };

        };
    };
}

