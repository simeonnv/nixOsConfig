{self, ...}: {
  flake.nixosModules.firefox-syncserver = {
    config,
    pkgs,
    pkgs-stable,
    ...
  }: {
    services.mysql.package = pkgs.mariadb;

    sops.secrets."firefox-syncserver.env" = {
      sopsFile = self + /secrets/firefox-syncserver.env;
      format = "dotenv";
      restartUnits = ["firefox-syncserver.service"];
    };

    services.firefox-syncserver = {
      enable = true;
      package = pkgs-stable.syncstorage-rs;
      secrets = config.sops.secrets."firefox-syncserver.env".path;

      settings = {
        host = "127.0.0.1";
        port = 5000;
      };

      singleNode = {
        enable = true;
        hostname = "sync.fravs.org";
        url = "https://sync.fravs.org";
        capacity = 5;
        enableNginx = false;
        enableTLS = false;
      };
    };
  };
}
