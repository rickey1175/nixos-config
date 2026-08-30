{ config, pkgs, inputs, ... }:

{
  # ---------------------------------------------------------------------------
  # Bootloader Configuration
  # ---------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---------------------------------------------------------------------------
  # Networking & Time Sync
  # ---------------------------------------------------------------------------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  services.timesyncd.enable = true;

  # ---------------------------------------------------------------------------
  # Experimental Nix Features & Unfree License Support
  # ---------------------------------------------------------------------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------------------
  # System Shell, Hyprland & Keybindings
  # ---------------------------------------------------------------------------
  programs.zsh.enable = true;
  programs.hyprland.enable = true;
  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  # ---------------------------------------------------------------------------
  # User Account Configuration
  # ---------------------------------------------------------------------------
  users.users.rickey = {
    isNormalUser = true;
    description = "rickey";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "libvirtd" "kvm" ];
    shell = pkgs.zsh;
  };

  # Automatic TTY1 Login
  services.getty.autologinUser = "rickey";

  # ---------------------------------------------------------------------------
  # Virtualization & Container Services
  # ---------------------------------------------------------------------------
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  # Force socket activation so virt-manager auto-detects qemu:///system
  systemd.services.libvirtd.wantedBy = [ "multi-user.target" ];
  systemd.sockets.virtqemud.enable = true;

  # ---------------------------------------------------------------------------
  # Screencasting & Unified Desktop Portals
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Audio & Bluetooth
  # ---------------------------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ---------------------------------------------------------------------------
  # Font Configuration
  # ---------------------------------------------------------------------------
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # ---------------------------------------------------------------------------
  # Base System Packages (Shared Across Desktop & Laptop)
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Quickshell & Qt Framework
    inputs.quickshell.packages.${pkgs.system}.default
    kdePackages.qtdeclarative
    kdePackages.qtsvg

    # Core Editors, Shell & Terminal Tools
    vim
    git
    wget
    curl
    kitty
    alacritty
    discord
    vscode
    python3
    gh
    tmux
    zellij
    lazygit

    # Creative & Media Stack
    gimp
    inkscape
    audacity
    imagemagick

    # Wayland & Desktop Quality-of-Life
    grim
    slurp
    swappy
    wf-recorder
    cliphist
    brightnessctl

    # Storage & Virtualization Tools
    gparted
    parted
    udisks
    virt-manager
    qemu
    qemu_kvm
    OVMF

    # Desktop Ricing & GUI Stack
    rofi
    hyprlock
    hypridle
    hyprpolkitagent
    networkmanagerapplet

    # KDE Service Framework & MIME Utilities
    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.kservice
    kdePackages.frameworkintegration
    shared-mime-info
    desktop-file-utils

    # System & Hardware Inspection
    pciutils
    lshw

    # Containers & Compression
    podman
    distrobox
    unzip
    p7zip
    unrar

    # Gaming Stack & Utilities
    protonup-qt
    mangohud
    gamescope
    lutris
    heroic
    piper
    goverlay
  ];

  # ---------------------------------------------------------------------------
  # Gaming Optimizations & System Fixes
  # ---------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  # Allow user FUSE mounts
  programs.fuse.userAllowOther = true;

  system.stateVersion = "26.05";
}