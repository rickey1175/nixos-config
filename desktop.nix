{ config, pkgs, ... }:

{
  # NVIDIA Ada Lovelace Drivers & CUDA Support
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
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Session Environment Variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # Container Virtualization & NVIDIA CDI
  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = true;
  };

  # Desktop-Only System Packages (CUDA OBS & NVTop)
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

  # Dedicated Game Storage Mount (Desktop Only)
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/db1a5ee4-7ab1-4b16-b41d-f23f400ec99c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "x-gvfs-show" ];
  };
}
