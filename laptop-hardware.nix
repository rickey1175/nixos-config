{ config, lib, pkgs, modulesPath, ... }:

{
  # ---------------------------------------------------------------------------
  # Intel Graphics & Hardware Video Acceleration
  # ---------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # Microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}