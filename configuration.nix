# =========================================================================
# CORE SYSTEM & RICE STACK BASELINE (SHARED & MAIN PC BASE)
# =========================================================================
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./video.nix  # Nvidia, CUDA, Containers & Video Production Stack
  ];

  # ---------------------------------------------------------------------------
  # Bootloader & Kernel Settings
  # ---------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Prevents /boot overflow
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Mainline kernel for updated Bluetooth, GPU & hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ---------------------------------------------------------------------------
  # Networking & Locale
  # ---------------------------------------------------------------------------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts-color-emoji
  ];

  # ---------------------------------------------------------------------------
  # Storage Auto-Mounting & Removable Media Services
  # ---------------------------------------------------------------------------
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

  # ---------------------------------------------------------------------------
  # Physical Power Button Handling
  # ---------------------------------------------------------------------------
  services.logind.settings.Login = {
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "reboot";
  };

  # ---------------------------------------------------------------------------
  # Display Server & Pure TTY Autologin (SDDM Disabled)
  # ---------------------------------------------------------------------------
  services.xserver.enable = true;
  services.seatd.enable = true;
  
  services.displayManager.sddm.enable = false;
  services.xserver.displayManager.lightdm.enable = false;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.zsh.enable = true;

  # User Account & TTY Autologin Setup
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
  
  services.getty.autologinUser = "rickey";

  # ---------------------------------------------------------------------------
  # Virtualization & Flatpak
  # ---------------------------------------------------------------------------
  services.flatpak.enable = true;
  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;

  # ---------------------------------------------------------------------------
  # Screencasting & Desktop Portals
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" "gtk" ];
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
  # Gaming Optimizations & Storage Mounts
  # ---------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/db1a5ee4-7ab1-4b16-b41d-f23f400ec99c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "x-gvfs-show" ];
  };

  system.stateVersion = "26.05";
}
