{ config, pkgs, ... }:

{
  # Power Management & Thermal Daemons
  services.tlp.enable = true;
  services.thermald.enable = true;

  # Wrapped OBS Studio for Intel QuickSync / Wayland PipeWire
  environment.systemPackages = with pkgs; [
    (wrapOBS.override {
      obs-studio = pkgs.obs-studio;
    } {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    })
  ];
}