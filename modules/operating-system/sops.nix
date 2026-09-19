{inputs, ...}: {
  flake.nixosModules.sops = {pkgs, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    environment.sessionVariables.SOPS_AGE_KEY_CMD = "${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i $HOME/.ssh/id_ed25519";

    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];
  };
}
