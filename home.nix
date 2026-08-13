{ config, pkgs, ... }:

{
  home.username = "rickey";
  home.homeDirectory = "/home/rickey";

  # Allow unfree packages inside Home Manager
  nixpkgs.config.allowUnfree = true;

  # Complete User-Space Packages List
  home.packages = with pkgs; [
    # Applications
    brave
    obs-studio

    # Wallpaper Daemons
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

  # Dotfile Symlinks
  xdg.configFile."hypr".source = ./hypr;
  xdg.configFile."kitty".source = ./kitty;
  xdg.configFile."waybar".source = ./waybar;
  xdg.configFile."rofi".source = ./rofi;

  home.stateVersion = "24.05";
}
