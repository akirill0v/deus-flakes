{ stdenv, lib, fetchFromGitHub, buildGoModule }:

let
  metadata = import ./metadata.nix;
in
buildGoModule rec {
  pname   = "vault-medusa";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner  = "jonasvinther";
    repo   = "medusa";
    rev    = version;
    sha256 = metadata.sha256;
  };

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A cli tool for importing and exporting Hashicorp Vault secrets";
    homepage    = meta.repo_git;
    license     = licenses.mit;
  };
}
