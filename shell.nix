with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "env";
  buildInputs = [
    python3
    python3Packages.pillow
    python3Packages.flask
  ];
  shellHook = "export PYTHONPATH=$PWD:$PYTHONPATH";
}
