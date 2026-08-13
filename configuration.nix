{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./video.nix
    ./desktop.nix
  ];

  # Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking & Hostname
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Enable System-Level Zsh Environment
  programs.zsh.enable = true;

  # User Account Configuration
  users.users.rickey = {
    isNormalUser = true;
    description = "Rickey";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # ---------------------------------------------------------------------------
  # Login Manager (greetd + tuigreet)
  # ---------------------------------------------------------------------------
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # System security & keyring
  security.polkit.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # ---------------------------------------------------------------------------
  # Screencasting & Desktop Portals
  # ---------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
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
  # System Packages Baseline
  # ---------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core Editors, Shell & Tools
    vim git wget curl kitty alacritty brave discord vscode wl-clipboard pavucontrol fastfetch 
    playerctl python3 tuigreet

    # Storage & Virtualization Tools
    gparted parted udisks virt-manager qemu qemu_kvm OVMF

    # Desktop Ricing & GUI Stack
    waybar rofi swww waypaper dunst hyprlock hypridle hyprpolkitagent networkmanagerapplet eww cava wlogout

    # System Monitoring
    btop

    # Media & File Management
    vlc kdePackages.dolphin kdePackages.ffmpegthumbs

    # Container & Compression Utilities
    podman distrobox unzip p7zip ffmpeg pciutils lshw

    # Gaming Stack
    protonup-qt mangohud gamescope
  ];

  # ---------------------------------------------------------------------------
  # Gaming Optimizations
  # ---------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  system.stateVersion = "26.05";
}
