{
  mkShell,
  config,
  just,
}:
mkShell {
  name = "default";
  inputsFrom = [ config.treefmt.build.devShell ];
  packages = [
    just
  ];
}
