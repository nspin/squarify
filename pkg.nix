{ python3Packages }:

python3Packages.buildPythonPackage rec {
  name = "squarify-0.1.0.0";
  src = ./.;
  propagatedBuildInputs = with python3Packages; [
    pillow
    flask
  ];
}
