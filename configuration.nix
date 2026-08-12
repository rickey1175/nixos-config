{ config, pkgs, ... }:

{
  # Global Unfree License Authorization
  nixpkgs.config.allowUnfree = true;

  # Bootloader & Kernel Settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Mainline Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking & Locale
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Bluetooth Configuration & Blueman Service
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts-color-emoji
  ];

  # SSH Server Daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Storage Auto-Mounting & Power Handling
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "reboot";
  };

  # Display Server & Hyprland
  services.xserver.enable = true;
  services.seatd.enable = true;
  services.displayManager.sddm.enable = false;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.zsh.enable = true;

  # User Account & TTY Setup
  users.users.rickey = {
    isNormalUser = true;
    description = "Rickey";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "gamemode"
      "seat"
      "podman"
      "render"
      "libvirtd"
    ];
    shell = pkgs.zsh;
  };

  # TTY1 Auto-Login
  services.getty.autologinUser = "rickey";

  # Flatpak & Virtualization Stack (QEMU / KVM / Virt-Manager)
  services.flatpak.enable = true;
  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Screencasting & Desktop Portals
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" ];
      };
    };
  };

  # Shared Global System Packages
  environment.systemPackages = with pkgs; [
    # Shell Bar, Launcher, Wallpaper UI & Lock Stack
    waybar
    rofi
    swww
    waypaper
    dunst
    hyprlock
    hypridle
    hyprpolkitagent
    networkmanagerapplet
    eww
    wlogout

    # Core Utilities, Browsers & Media Control
    vim
    git
    wget
    curl
    kitty
    alacritty
    brave
    discord
    vscode
    wl-clipboard
    pavucontrol
    fastfetch
    playerctl
    python3

    # System Monitoring
    btop

    # Media & File Managers
    vlc
    kdePackages.dolphin
    kdePackages.ffmpegthumbs

    # Container & Setup Utilities
    podman
    distrobox
    unzip
    p7zip
    ffmpeg
    pciutils
    lshw

    # Gaming Stack & Base OBS Studio
    protonup-qt
    mangohud
    gamescope
    obs-studio
  ];

  # Gaming Optimizations
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  system.stateVersion = "24.05";
}
