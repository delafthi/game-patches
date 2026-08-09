{
  projectRootFile = "flake.nix";
  programs = {
    deadnix.enable = true;
    just.enable = true;
    keep-sorted.enable = true;
    nixfmt.enable = true;
    rumdl-check.enable = true;
    shfmt.enable = true;
    statix.enable = true;
    typos.enable = true;
  };
}
