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
      binaryninja-free
      bettercap
      unixtools.netstat

      aircrack-ng
      iw
      ethtool
      pciutils
      usbutils
    ];
  };
}
