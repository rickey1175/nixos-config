{ config, pkgs, lib, ... }:

{
  home.username = "rickey";
  home.homeDirectory = lib.mkForce "/home/rickey";

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

      # NixOS Quick Rebuild Shortcuts
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
      nc = "cd ~/nixos && nvim configuration.nix";
      nh = "cd ~/nixos && nvim home.nix";
    };
    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };

  # Native Zoxide Integration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
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

    # Declarative Portal Fix Binary (With Direct Execution Bypass)
    (writeShellScriptBin "fix-portal" ''
      ${dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
      ${systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
      
      # Kill any stuck portal instances
      pkill -f xdg-desktop-portal || true
      
      # Restart the Hyprland backend
      ${systemd}/bin/systemctl --user restart xdg-desktop-portal-hyprland
      sleep 1
      
      # Try starting via systemctl, or fallback to launching directly
      ${systemd}/bin/systemctl --user start xdg-desktop-portal 2>/dev/null || ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal &
    '')
  ];

  # Dotfile Symlinks from ~/nixos
  xdg.configFile."hypr".source = ./hypr;
  xdg.configFile."kitty".source = ./kitty;
  xdg.configFile."waybar".source = ./waybar;
  xdg.configFile."rofi".source = ./rofi;

  home.stateVersion = "24.05";
}