{
  findutils,
  nixfmt,
  writeShellApplication,
}:
writeShellApplication {
  name = "omp-nix-fmt";
  runtimeInputs = [
    findutils
    nixfmt
  ];
  text = ''
    if (( $# == 0 )); then
      find . -type f -name '*.nix' -not -path './.git/*' -exec nixfmt {} +
    else
      exec nixfmt "$@"
    fi
  '';
}
