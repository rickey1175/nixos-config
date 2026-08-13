# =========================================================================
# LAPTOP CONFIGURATION (INTEL GRAPHICS - NO NVIDIA DEPS)
# =========================================================================
{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Intel Graphics & Hardware Acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # Laptop Power Management
  services.tlp.enable = true;
  services.thermald.enable = true;

  # Standard Wrapped OBS for Intel QuickSync / PipeWire
  environment.systemPackages = with pkgs; [
    (wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    })
  ];
}
