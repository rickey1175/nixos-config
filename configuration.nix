{ config, pkgs, ... }:

{
  # Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking & Time Sync
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  services.timesyncd.enable = true;

  # Enable Experimental Nix Features Globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable System-Level Shell, Hyprland & FZF Keybindings (Ctrl+R / Ctrl+T)
  programs.zsh.enable = true;
  programs.hyprland.enable = true;
  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  # User Account Configuration (Lowercase 'rickey')
  users.users.rickey = {
    isNormalUser = true;
    description = "rickey";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # Automatic TTY1 Login
  services.getty.autologinUser = "rickey";

  # ---------------------------------------------------------------------------
  # Virtualization & Container Services (Virt-Manager & QEMU Auto-Connection)
  # ---------------------------------------------------------------------------
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # Enforce TPM emulation for VMs
    };
  };
  programs.virt-manager.enable = true;

  # Force socket activation so virt-manager auto-detects qemu:///system
  systemd.services.libvirtd.wantedBy = [ "multi-user.target" ];
  systemd.sockets.virtqemud.enable = true;

  # ---------------------------------------------------------------------------
  # Screencasting & Desktop Portals (OBS / Hyprland PipeWire Setup)
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
  # Font Configuration
  # ---------------------------------------------------------------------------
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # ---------------------------------------------------------------------------
  # System Packages Baseline
  # ---------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core Editors, Shell & Tools
    vim git wget curl kitty alacritty brave discord vscode wl-clipboard pavucontrol fastfetch 
    playerctl python3 obs-studio fzf

    # Storage & Virtualization Tools
    gparted parted udisks virt-manager qemu qemu_kvm OVMF

    # Desktop Ricing & GUI Stack
    waybar rofi awww waypaper dunst hyprlock hypridle hyprpolkitagent networkmanagerapplet eww cava wlogout

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
