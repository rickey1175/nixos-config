outputs = { self, nixpkgs, ... }@inputs: {
  nixosConfigurations = {
    # Main Desktop
    nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        ./desktop.nix
      ];
    };

    # Laptop
    laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./laptop-hardware.nix  # <--- MUST BE HERE
        ./configuration.nix
        ./laptop.nix
      ];
    };
  };
};
