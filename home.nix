{ config, pkgs, lib, ... }:

{
  home.username = "rickey";
  home.homeDirectory = lib.mkForce "/home/rickey";

  # ---------------------------------------------------------------------------
  # Zsh Configuration & Shell Aliases
  # ---------------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    shellAliases = {
      # File Manager Shortcuts
      fm = "yazi";
      filemanager = "dolphin . &";

      # Core Replacements
      ls = "eza --icons";
      ll = "eza -la --icons";
      cat = "bat";

      # NixOS Quick Shortcuts
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
      nc = "cd ~/nixos && nvim configuration.nix";
      nh = "cd ~/nixos && nvim home.nix";
    };
    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
    initContent = ''
      fastfetch
    '';
  };

  # Native Zoxide Integration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ---------------------------------------------------------------------------
  # User-Space Packages
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    # GUI Applications
    brave
    waypaper

    # Wallpaper Daemons
    hyprpaper
    awww
    swaybg

    # Terminal UI & CLI Utilities
    yazi
    fzf
    eza
    bat
    zoxide
    cava
    fastfetch
    btop
    pavucontrol
    ripgrep
    fd
    jq
    unzip
    p7zip
    wl-clipboard
    playerctl

    # Declarative Portal Fix Script
    (writeShellScriptBin "fix-portal" ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
      ${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
      
      # Kill any stuck portal instances
      pkill -f xdg-desktop-portal || true
      
      # Restart the Hyprland backend
      ${pkgs.systemd}/bin/systemctl --user restart xdg-desktop-portal-hyprland
      sleep 1
      
      # Try starting via systemctl, or fallback to direct execution
      ${pkgs.systemd}/bin/systemctl --user start xdg-desktop-portal 2>/dev/null || ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal &
    '')
  ];

  # ---------------------------------------------------------------------------
  # Dotfile Symlinks
  # ---------------------------------------------------------------------------
  xdg.configFile."hypr".source = ./hypr;
  xdg.configFile."kitty".source = ./kitty;
  xdg.configFile."waybar".source = ./waybar;
  xdg.configFile."rofi".source = ./rofi;
  xdg.configFile."waypaper".source = ./waypaper;
  xdg.configFile."cava".source = ./cava;

  home.stateVersion = "26.05";
}