{ config, pkgs, ... }:

{
  # Allow unfree software
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

  # Power Management & Thermal Control
  services.tlp.enable = true;
  services.thermald.enable = true;

  # XDG Desktop Portal for PipeWire Screen Sharing in OBS
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Sound & PipeWire Setup
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
