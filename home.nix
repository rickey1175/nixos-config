{ config, pkgs, ... }:

{
  home.username = "rickey";
  home.homeDirectory = "/home/rickey";

  # Complete User-Space Packages List
  home.packages = with pkgs; [
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

    # Prompt
    starship
  ];

  # Full Zsh Integration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Custom Shell Aliases
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
      rebuild-laptop = "sudo nixos-rebuild switch --flake ~/nixos#laptop";
      ls = "eza --icons";
      ll = "eza -la --icons";
      cat = "bat";
      ff = "fastfetch";
      fm = "yazi";
    };

    initExtra = ''
      export PATH=$HOME/.local/bin:$PATH
    '';
  };

  # Shell Program Integrations
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Enable fzf shell keybindings
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Symlink Dotfiles from ~/nixos to ~/.config
  home.file.".config/hypr".source = ./hypr;
  home.file.".config/waybar".source = ./waybar;
  home.file.".config/kitty".source = ./kitty;
  home.file.".config/rofi".source = ./rofi;

  # Allow Home Manager to manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
