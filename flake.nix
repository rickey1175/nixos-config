{
  description = "Rickey's Declarative NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, quickshell, hyprland-plugins, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      sharedHomeManager = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.rickey = import ./home.nix;
      };
    in
    {
      nixosConfigurations = {
        # Desktop Workstation (Ryzen 9 7900X + RTX 4080 Super)
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hardware-configuration.nix
            ./video.nix
            ./configuration.nix
            ./desktop.nix
            home-manager.nixosModules.home-manager
            sharedHomeManager
          ];
        };

        # Laptop Target (Intel Mobile Graphics)
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./laptop-hardware.nix
            ./configuration.nix
            ./laptop.nix
            home-manager.nixosModules.home-manager
            sharedHomeManager
          ];
        };
      };
    };
}