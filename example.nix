{ pkgs, config, ... }:

let

  squarifyServerName = "example.com";
  squarifyCert = /foo/bar/cert.pem;
  squarifyPriv = /foo/bar/priv.pem;

in {

  nixpkgs.overlays = [(pkgsself: pkgssuper: {
    python = pkgssuper.python.override {
      packageOverrides = self: super: {
        squarify = self.callPackage ./pkg.nix {};
      };
    };
    # TODO(nspin) nothing like this should be necessary
    pythonPackages = pkgsself.python.pkgs;
  })];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    virtualHosts."${squarifyServerName}" = {
      forceSSL = true;
      sslCertificate = squarifyCert;
      sslCertificateKey = squarifyPriv;
      locations = {
        "/squarify" = {
          extraConfig = ''
            uwsgi_pass unix:${config.services.uwsgi.instance.vassals.squarify.socket};
          '';
        };
        "/" = {
          index = "index.html";
          root = "${pkgs.pythonPackages.squarify}/lib/python3.6/site-packages/squarify/resources";
        };
      };
    };
  };

  services.uwsgi = {
    enable = true;
    plugins = [
      "python3"
    ];
    instance = {
      type = "emperor";
      vassals = {
        squarify = {
          type = "normal";
          socket = "${config.services.uwsgi.runDir}/squarify.sock";
          chmod-socket = 666;
          module = "squarify.web:app";
          pythonPackages = self: with self; [
            squarify
          ];
        };
      };
    };
  };

}
