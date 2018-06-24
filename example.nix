{ config, ... }: {

  imports = [
    ./service.nix
  ];

  networking.firewall.allowedTCPPorts = map (builtins.getAttr "port") config.services.squarify.listen;

  services.squarify = {
    serverName = "example.com";
    listen = [{
      addr = "0.0.0.0";
      port = 80;
    }];
  };

}
