{
  flake.nixosModules.sudo-server = {
    security.sudo.extraRules = [
      {
        groups = ["wheel"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
