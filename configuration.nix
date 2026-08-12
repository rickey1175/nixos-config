# =========================================================================
# HYPRLAND + AUTO-MOUNT + GPARTED + VIRT-MANAGER + FLATPAK + SSH (V10)
# =========================================================================
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];
  # ---------------------------------------------------------------------------
  # Bootloader & Kernel Settings
  # ---------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Prevents /boot partition overflow
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  
  # Mainline kernel for updated Bluetooth & hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # ---------------------------------------------------------------------------
  # Networking, Locale & SSH Server Daemon
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

  # SSH Server Daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };
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
  
  # Disable SDDM completely
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
      "libvirtd" # Enables non-root VM management in virt-manager
    ];
    shell = pkgs.zsh;
  };
  
  # TTY1 Auto-Login Direct to User
  services.getty.autologinUser = "rickey";
  # ---------------------------------------------------------------------------
  # Flatpak Integration
  # ---------------------------------------------------------------------------
  services.flatpak.enable = true;
  # ---------------------------------------------------------------------------
  # Virtual Machine Stack (virt-manager / QEMU / KVM)
  # ---------------------------------------------------------------------------
  programs.dconf.enable = true; # Required for virt-manager UI settings
  virtualisation.libvirtd.enable = true; # Handles QEMU, KVM, and OVMF firmware automatically
  # ---------------------------------------------------------------------------
  # Wayland & NVIDIA Environment Variables
  # ---------------------------------------------------------------------------
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
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
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };
  # ---------------------------------------------------------------------------
  # Audio & Bluetooth (PipeWire + WirePlumber)
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
  # NVIDIA Ada Lovelace Drivers & CUDA
  # ---------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      egl-wayland
      cudaPackages.cudatoolkit
    ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false; # Proprietary module for CUDA/NVENC container compatibility
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # ---------------------------------------------------------------------------
  # Container Virtualization (Podman & NVIDIA CDI for DaVinci Resolve)
  # ---------------------------------------------------------------------------
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = true;
  };
  # ---------------------------------------------------------------------------
  # System Packages
  # ---------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Storage & Disk Management Tools
    gparted
    parted
    udisks
    # Virtualization Tools
    virt-manager
    qemu
    qemu_kvm
    OVMF
    # Audio Visualizer & Power Menu
    cava
    wlogout
    # Shell Bar, Launcher, Wallpaper UI & Lock Stack
    waybar
    rofi
    swww                # Wallpaper daemon
    waypaper            # Wallpaper GUI picker
    dunst
    hyprlock            # Lock screen
    hypridle            # Idle daemon
    hyprpolkitagent
    networkmanagerapplet
    eww
    # Core Utilities, Browsers & Media Control
    vim git wget curl kitty alacritty brave discord vscode wl-clipboard pavucontrol fastfetch 
    playerctl           # Live song metadata & album art fetching
    python3
    # System & GPU Monitoring
    btop
    nvtopPackages.nvidia
    # Media & File Managers
    vlc
    kdePackages.dolphin
    kdePackages.ffmpegthumbs
    # Container & Setup Utilities (DaVinci Resolve / CapCut)
    podman
    distrobox
    nvidia-container-toolkit
    unzip
    p7zip
    ffmpeg
    pciutils
    lshw
    # Gaming Stack & OBS Studio with CUDA Support
    protonup-qt
    mangohud
    gamescope
    (wrapOBS.override {
      obs-studio = pkgs.obs-studio.override {
        cudaSupport = true;
      };
    } {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vaapi
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    })
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
