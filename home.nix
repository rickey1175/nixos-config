{ config, pkgs, ... }:

{
  home.username = "rickey";
  home.homeDirectory = "/home/rickey";

  # Enable Zsh, custom aliases, and auto-start Hyprland on TTY1 login
  programs.zsh = {
    enable = true;
    shellAliases = {
      # File Manager Shortcuts
      fm = "yazi";
      filemanager = "dolphin . &";

      # Core Utility Replacements
      ls = "eza --icons";
      ll = "eza -la --icons";
      cat = "bat";
      cd = "z";

      # NixOS Quick Rebuild Shortcuts
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
      nc = "cd ~/nixos && nvim configuration.nix";
      nh = "cd ~/nixos && nvim home.nix";
    };
    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec start-hyprland
      fi
    '';
  };

  # Complete User-Space Packages List
  home.packages = with pkgs; [
    # Desktop Applications
    brave
    waypaper

    # Wallpaper Daemons & Backends
    hyprpaper
    awww
    swaybg

    # Terminal UI Tools & File Managers
    yazi
    fzf
    eza
    bat
    zoxide
    cava
    fastfetch
    btop
    pavucontrol

    # CLI & Development Utilities
    ripgrep
    fd
    jq
    unzip
    p7zip
    wl-clipboard
    playerctl
  ];

  # Dotfile Symlinks from ~/nixos
  xdg.configFile."hypr".source = ./hypr;
  xdg.configFile."kitty".source = ./kitty;
  xdg.configFile."waybar".source = ./waybar;
  xdg.configFile."rofi".source = ./rofi;

  home.stateVersion = "24.05";
}
