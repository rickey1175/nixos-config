{ config, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Dedicated Game Storage Mount (Desktop Only)
  # ---------------------------------------------------------------------------
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/db1a5ee4-7ab1-4b16-b41d-f23f400ec99c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "x-gvfs-show" ];
  };

  # ---------------------------------------------------------------------------
  # 1. Hardware Graphics & VA-API Video Acceleration
  # ---------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # ---------------------------------------------------------------------------
  # 2. NVIDIA Driver & NVENC Configuration
  # ---------------------------------------------------------------------------
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # Set to false to ensure NVENC & CUDA support link cleanly
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ---------------------------------------------------------------------------
  # 3. Environment Variables for Hyprland & Video Encoding
  # ---------------------------------------------------------------------------
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # ---------------------------------------------------------------------------
  # Declarative Portal Setup
  # ---------------------------------------------------------------------------
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
}
