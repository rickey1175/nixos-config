{ config, pkgs, ... }:

{
  # Intel Graphics & Hardware Acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  services.xserver.videoDrivers = [ "modesetting" ];

  # Power Management & Thermal Controls
  services.tlp.enable = true;
  services.thermald.enable = true;
}
