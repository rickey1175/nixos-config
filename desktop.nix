{ config, pkgs, ... }:

{
  # Dedicated Game Storage Mount (Desktop Only)
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/db1a5ee4-7ab1-4b16-b41d-f23f400ec99c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "x-gvfs-show" ];
  };

  # Declarative Portal Setup
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
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  # ---------------------------------------------------------------------------
  # MIME Database & Desktop File Associations (Populates "Open With" Lists)
  # ---------------------------------------------------------------------------
  xdg.mime.enable = true;

  # ---------------------------------------------------------------------------
  # Video Processing, Media & Desktop Applications
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Video Transcoding & Encoding
    handbrake
    ffmpeg-full

    # Media Players & Thumbnailers
    vlc
    kdePackages.dolphin
    kdePackages.ffmpegthumbs
    kdePackages.kdegraphics-thumbnailers

    # Document & Office Suite
    libreoffice-fresh

    # XDG & Desktop File Database Integration
    xdg-utils
    shared-mime-info
    desktop-file-utils
  ];
}