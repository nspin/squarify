{ ... }: {

  imports = [
    ./service.nix
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.squarify = {
    serverName = "example.com";
    extraVHostConfig = {
      forceSSL = true;
      sslCertificate = /foo/bar/cert.pem;
      sslCertificateKey = /foo/bar/priv.pem;
    };
  };

}
