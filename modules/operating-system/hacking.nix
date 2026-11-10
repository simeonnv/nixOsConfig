# Copyright 2026 Simeon Vangelov
# SPDX-License-Identifier: MIT

{
  pkgs,
  ownerProfile,
  ...
}: {
  flake.nixosModules.hacking = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      nmap
      whois
      dnslookup
      dig
      ffuf
      hashcat
      hashcat-utils
      sqlmap
      gitleaks
      binaryninja-free
      bettercap
      unixtools.netstat

      aircrack-ng
      iw
      ethtool
      pciutils
      usbutils

      tor-browser
      tor
    ];
  };
}
