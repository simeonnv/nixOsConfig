{
  inputs,
  self,
  config,
  ownerProfile,
  ...
}: let
  domains = ["fravs.org" "larp-sec.com"];
  mailHosts = map (domain: "mail.${domain}") domains;
  hostname = "mail.fravs.org";

  sshPort = 2222;
  smtpPort = 25;
  smtpTunnelPort = 2525;
  relayPort = 2526;
  relayAddress = "10.255.255.1";
  relayHost = "relay.syphoria.internal";
  relayUser = "syphoria-relay";

  gatewayHost = config.flake.deploy.nodes.gateway.hostname;
  gatewayHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbNp6vBDs/7HA1mbdvtCUwcwEegSxoLgeZ+cXOllZoy";
  relayPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIct7EjgftogSvc1a7c5qPNUjfbU1/Jwbal8QYvsRSIA syphoria-relay";
  ownerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz6cbpujcaBo5eAb4+c30kaD5T9wUXAtv5XS98BNACI simmeon.nv@proton.me";

  sopsFile = self + /secrets/syphoria.yaml;
in {
  flake.nixosModules.syphoria = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.syphoria;
    secrets = config.sops.secrets;
    stalwartUrl = cfg.settings.stalwart.url;
    knownHosts = pkgs.writeText "syphoria-relay-known-hosts" "${gatewayHost} ${gatewayHostKey}\n";
    mullvad = config.services.mullvad-vpn;
  in {
    imports = [inputs.syphoria.nixosModules.default];

    sops.secrets = {
      stalwart_admin_password = {
        inherit sopsFile;
        restartUnits = ["stalwart.service" "syphoria.service"];
      };
      cloudflare_api_token = {
        inherit sopsFile;
        restartUnits = ["stalwart.service"];
      };
      syphoria_relay_ssh_key = {
        inherit sopsFile;
        restartUnits = ["syphoria-relay-tunnel.service"];
      };
    };

    sops.templates."stalwart-curl.conf" = {
      content = ''
        user = "${cfg.settings.stalwart.admin_user}:${config.sops.placeholder.stalwart_admin_password}"
      '';
      restartUnits = ["stalwart-dkim.service"];
    };

    services.syphoria = {
      enable = true;
      settings = {
        inherit domains;
        server.listen = "127.0.0.1:${toString sshPort}";
        users.${ownerProfile.name} = {
          ssh_keys = [ownerKey];
          inherit domains;
        };
      };
      stalwart = {
        setup = true;
        passwordFile = secrets.stalwart_admin_password.path;
      };
      backup = {
        enable = true;
        startAt = "Mon,Wed,Fri 03:00";
        keep = 10;
      };
    };

    services.stalwart = {
      stateVersion = "26.05";
      package = pkgs.stalwart_0_15;
      credentials.cloudflare-token = secrets.cloudflare_api_token.path;
      settings = {
        server.hostname = hostname;
        server.listener.smtp = {
          bind = ["127.0.0.1:${toString smtpPort}"];
          protocol = "smtp";
          proxy.trusted-networks = ["127.0.0.1"];
        };
        acme.cloudflare = {
          directory = "https://acme-v02.api.letsencrypt.org/directory";
          challenge = "dns-01";
          provider = "cloudflare";
          secret = "%{file:/run/credentials/stalwart.service/cloudflare-token}%";
          contact = [ownerProfile.email];
          domains = mailHosts;
          default = true;
        };
        queue.route.gateway = {
          type = "relay";
          address = relayHost;
          port = relayPort;
          protocol = "smtp";
          tls.implicit = false;
        };
        queue.strategy.route = [
          {
            "if" = "is_local_domain('*', rcpt_domain)";
            "then" = "'local'";
          }
          {"else" = "'gateway'";}
        ];
      };
    };

    systemd.services.stalwart-dkim = {
      description = "Generate Stalwart DKIM keys";
      wantedBy = ["multi-user.target"];
      wants = ["stalwart.service"];
      after = ["stalwart.service"];
      path = [pkgs.curl pkgs.jq config.systemd.package];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = ["curl:${config.sops.templates."stalwart-curl.conf".path}"];
      };
      script = ''
        api() {
          curl -sS --fail-with-body --retry 30 --retry-connrefused --retry-delay 2 \
            -K "$CREDENTIALS_DIRECTORY/curl" "$@"
        }
        created=0
        for domain in ${lib.escapeShellArgs domains}; do
          for algorithm in Rsa Ed25519; do
            reply=$(api -H 'Content-Type: application/json' \
              -d "$(jq -n --arg domain "$domain" --arg algorithm "$algorithm" '{$domain, $algorithm}')" \
              ${stalwartUrl}/api/dkim)
            case $(jq -r '.error // "created"' <<<"$reply") in
              created) created=1 ;;
              fieldAlreadyExists) ;;
              *) echo "$reply" >&2; exit 1 ;;
            esac
          done
        done
        if [ "$created" = 1 ]; then
          systemctl restart stalwart.service
        fi
      '';
    };

    systemd.services.syphoria-relay-tunnel = {
      description = "SSH tunnel to the gateway mail relay";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      requires = ["network-addresses-lo.service"];
      after = ["network-online.target" "network-addresses-lo.service"] ++ lib.optional mullvad.enable "mullvad-daemon.service";
      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          (lib.getExe pkgs.openssh)
          "-N"
          "-i"
          "%d/key"
          "-o"
          "IdentitiesOnly=yes"
          "-o"
          "StrictHostKeyChecking=yes"
          "-o"
          "UserKnownHostsFile=${knownHosts}"
          "-o"
          "ExitOnForwardFailure=yes"
          "-o"
          "ServerAliveInterval=30"
          "-o"
          "ServerAliveCountMax=3"
          "-o"
          "GatewayPorts=yes"
          "-L"
          "${relayAddress}:${toString relayPort}:127.0.0.1:${toString relayPort}"
          "${relayUser}@${gatewayHost}"
        ];
        ExecStartPost = lib.mkIf mullvad.enable "-+${mullvad.package}/bin/mullvad split-tunnel add $MAINPID";
        Restart = "always";
        RestartSec = 10;
        DynamicUser = true;
        LoadCredential = ["key:${secrets.syphoria_relay_ssh_key.path}"];
      };
    };

    networking.interfaces.lo.ipv4.addresses = [
      {
        address = relayAddress;
        prefixLength = 32;
      }
    ];
    networking.hosts.${relayAddress} = [relayHost];

    services.rathole.settings.client.services = {
      syphoria-ssh.local_addr = "127.0.0.1:${toString sshPort}";
      syphoria-smtp.local_addr = "127.0.0.1:${toString smtpPort}";
    };
  };

  flake.nixosModules.syphoria-gateway = {
    lib,
    pkgs,
    ...
  }: {
    services.rathole.settings.server.services = {
      syphoria-ssh.bind_addr = "0.0.0.0:${toString sshPort}";
      syphoria-smtp.bind_addr = "127.0.0.1:${toString smtpTunnelPort}";
    };

    services.haproxy = {
      enable = true;
      config = ''
        defaults
          mode tcp
          timeout connect 10s
          timeout client 5m
          timeout server 5m

        frontend smtp
          bind :${toString smtpPort}
          default_backend stalwart

        backend stalwart
          server prodesk 127.0.0.1:${toString smtpTunnelPort} send-proxy-v2
      '';
    };

    services.postfix = {
      enable = true;
      settings.main = {
        myhostname = hostname;
        mydestination = [];
        inet_interfaces = "loopback-only";
        inet_protocols = "ipv4";
        mynetworks = ["127.0.0.0/8"];
        smtpd_relay_restrictions = ["permit_mynetworks" "reject"];
        smtp_tls_security_level = "may";
      };
      settings.master.smtp_inet.name = lib.mkForce "127.0.0.1:${toString relayPort}";
    };

    users.groups.${relayUser} = {};
    users.users.${relayUser} = {
      isSystemUser = true;
      group = relayUser;
      shell = "${pkgs.shadow}/bin/nologin";
      openssh.authorizedKeys.keys = [
        ''restrict,port-forwarding,permitopen="127.0.0.1:${toString relayPort}" ${relayPublicKey}''
      ];
    };

    networking.firewall.allowedTCPPorts = [smtpPort sshPort];
  };
}
