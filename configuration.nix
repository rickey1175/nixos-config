# ---------------------------------------------------------------------------
  # Screencasting & Desktop Portals (Fixes OBS PipeWire Screen Capture)
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
