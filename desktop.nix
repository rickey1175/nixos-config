{ config, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # Dedicated Game Storage Mount (Desktop NVMe)
  # ---------------------------------------------------------------------------
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/db1a5ee4-7ab1-4b16-b41d-f23f400ec99c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "x-gvfs-show" ];
  };

  # MIME Database & Desktop File Associations
  xdg.mime.enable = true;

  # ---------------------------------------------------------------------------
  # Desktop Applications & Media Utilities
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    handbrake
    ffmpeg-full
    vlc
    kdePackages.dolphin
    kdePackages.ffmpegthumbs
    kdePackages.kdegraphics-thumbnailers
    libreoffice-fresh
    xdg-utils
  ];
}