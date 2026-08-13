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

  # Enable system-level Zsh environment
  programs.zsh.enable = true;

  # User Account Configuration
  users.users.rickey = {
    isNormalUser = true;
    description = "Rickey";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # ---------------------------------------------------------------------------
  # Screencasting & Desktop Portals (OBS PipeWire Fix)
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;
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
    playerctl python3

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
