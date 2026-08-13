# =========================================================================
# NVIDIA GPU, CUDA & VIDEO PRODUCTION MODULE (MAIN PC ONLY)
# =========================================================================
{ config, pkgs, ... }:

{
  # Bootloader Early KMS Modules for Nvidia
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];

  # Wayland Environment Variables for Nvidia
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # NVIDIA Ada Lovelace Drivers & CUDA Toolkit
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
    open = false; # Proprietary module required for container NVENC/CUDA symbol mapping
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Container Virtualization (Podman & NVIDIA CDI for DaVinci Resolve)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = true;
  };

  # Nvidia Monitoring & CUDA OBS Studio Stack
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    nvidia-container-toolkit
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
}

