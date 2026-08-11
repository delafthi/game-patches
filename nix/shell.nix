{
  mkShell,
  config,
  bashInteractive,
  just,
  uv,
}:
mkShell {
  name = "default";
  inputsFrom = [ config.treefmt.build.devShell ];
  packages = [
    bashInteractive
    just
    uv
  ];
}
