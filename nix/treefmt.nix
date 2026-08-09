{ pkgs }:
{
  projectRootFile = "flake.nix";
  programs = {
    deadnix.enable = true;
    just.enable = true;
    keep-sorted.enable = true;
    nixfmt.enable = true;
    ruff-check.enable = true;
    ruff-format.enable = true;
    rumdl-check.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    typos.enable = true;
  };
  settings.formatter.plutil = {
    command = "${pkgs.re-plistbuddy}/bin/plutil";
    options = [ "-lint" ];
    includes = [ "*.plist" ];
  };
}
