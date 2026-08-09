{
  mkShell,
  config,
  just,
  uv,
}:
mkShell {
  name = "default";
  inputsFrom = [ config.treefmt.build.devShell ];
  packages = [
    just
    uv
  ];
}
