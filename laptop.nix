{ config, pkgs, ... }:

{
  # Intel Graphics & VA-API Hardware Acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # Intel Integrated GPU Video Driver
  services.xserver.videoDrivers = [ "modesetting" ];
}
