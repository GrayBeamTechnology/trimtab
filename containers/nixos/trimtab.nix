# trimtab agent host requirements for NixOS
# Deploy to: /etc/nixos/trimtab.nix
# Then add to imports in configuration.nix:
#   imports = [ ./hardware-configuration.nix ./trimtab.nix ];
#
# Managed by: trimtab init-host
{ config, pkgs, ... }:
{
  # System packages for agent development
  environment.systemPackages = with pkgs; [
    git
    tmux
    podman-compose
  ];

  # nix-ld: required for dynamically linked binaries (Claude Code)
  programs.nix-ld.enable = true;

  # Podman (rootless containers)
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Cgroup delegation for rootless Podman builds
  systemd.services."user@".serviceConfig.Delegate = true;

  # Syncthing
  services.syncthing = {
    enable = true;
    # user/dataDir/configDir set per-host — override in configuration.nix
  };
}
