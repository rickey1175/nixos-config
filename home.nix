{ config, pkgs, lib, inputs, ... }:

{
  home.username = "rickey";
  home.homeDirectory = lib.mkForce "/home/rickey";

  programs.zsh = {
    enable = true;
    shellAliases = {
      fm = "yazi";
      filemanager = "dolphin . &";
      ls = "eza --icons";
      ll = "eza -la --icons";
      cat = "bat";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      nc = "cd ~/nixos-config && nvim configuration.nix";
      nh = "cd ~/nixos-config && nvim home.nix";
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    inputs.hyprland-plugins.packages.${pkgs.system}.hyprscroller or pkgs.emptyDirectory
    brave
    hyprpaper
    swww
    swaybg
    pywal
    matugen
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
    brightnessctl
    grim
    slurp
    swappy

    # Zero-argument binary wrappers for Hyprland dispatch
    (writeShellScriptBin "qs-launcher" ''
      exec quickshell ipc call launcher toggle
    '')

    (writeShellScriptBin "qs-powermenu" ''
      exec quickshell ipc call powermenu toggle
    '')

    (writeShellScriptBin "qs-wallpapers" ''
      exec quickshell ipc call wallpapers toggle
    '')

    (writeShellScriptBin "set_theme.sh" ''
      exec "${config.home.homeDirectory}/nixos-config/quickshell/scripts/set_theme.sh" "$@"
    '')

    (writeShellScriptBin "fix-portal" ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
      ${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
      pkill -f xdg-desktop-portal || true
      ${pkgs.systemd}/bin/systemctl --user restart xdg-desktop-portal-hyprland
      sleep 1
      ${pkgs.systemd}/bin/systemctl --user start xdg-desktop-portal 2>/dev/null || ${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal &
    '')
  ];

  xdg.configFile."hypr".source = ./hypr;
  xdg.configFile."kitty".source = ./kitty;
  xdg.configFile."cava".source = ./cava;
  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/quickshell";

  home.stateVersion = "26.05";
}