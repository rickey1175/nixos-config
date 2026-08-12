{ config, pkgs, ... }:

{
  home.username = "rickey";
  home.homeDirectory = "/home/rickey";

  # User-space packages
  home.packages = with pkgs; [
    fastfetch
    btop
    pavucontrol
  ];

  # Symlink dotfiles directly from ~/nixos into ~/.config
  home.file.".config/hypr".source = ./hypr;
  home.file.".config/waybar".source = ./waybar;
  home.file.".config/kitty".source = ./kitty;
  home.file.".config/rofi".source = ./rofi;

  # Allow Home Manager to manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
