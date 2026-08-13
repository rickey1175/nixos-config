{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking Setup
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time Zone & Locale Settings
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable Hyprland Window Manager
  programs.hyprland.enable = true;

  # Display Manager (SDDM with Wayland Support)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # User Configuration
  users.users.rickey = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Allow Unfree Packages
  nixpkgs.config.allowUnfree = true;

  # System-Wide Packages
  environment.systemPackages = with pkgs; [
    # Core Utilities & Editors
    git
    neovim
    wget
    curl
    kitty

    # Hyprland Ecosystem
    waybar
    rofi-wayland
    dunst
    hyprpaper
    awww
    swaybg

    # Audio Control
    pavucontrol
    pulseaudio

    # Media & File Managers
    vlc
    kdePackages.dolphin
    kdePackages.ffmpegthumbs

    # Container & System Utilities
    podman
    distrobox
    unzip
    p7zip
    ffmpeg
    pciutils
    lshw

    # Gaming Stack
    protonup-qt
    mangohud
    gamescope

    # Fonts for Waybar / Icons
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  # Wrapped OBS Studio with PipeWire Screen Capture & Vulkan Plugins
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-pipewire-audio-plugins
    ];
  };

  # XDG Desktop Portals for Hyprland Screen Sharing
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # PipeWire Audio Setup
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Gaming Optimizations
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  system.stateVersion = "24.05";
}
