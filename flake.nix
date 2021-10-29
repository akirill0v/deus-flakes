{
  description = "My extra packages";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = genAttrs supportedSystems;
      pkgsFor = pkgs: system: overlays:
        import pkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
      pkgs_ = genAttrs (builtins.attrNames inputs) (inp: genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys []));
      opkgs_ = overlays: genAttrs (builtins.attrNames inputs) (inp: genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys overlays));
    in
    rec {
      devShell = forAllSystems (system:
        pkgs_.nixpkgs.${system}.mkShell {
          nativeBuildInputs = []
            ++ (with pkgs_.nixpkgs.${system}; [
                cachix
                nixUnstable nix-prefetch nix-build-uncached
                bash cacert curl git jq openssh ripgrep parallel #mercurial
                haskellPackages.dhall-json
            ]); });
      packages = forAllSystems (system:
        (opkgs_ [overlay]).nixpkgs.${system}.deusPkgs);

      overlay = final: prev:
        let
          deusPkgs = rec {
            vault-medusa = prev.callPackage ./pkgs/vault-medusa {};
          };
        in
          deusPkgs // { inherit deusPkgs; };
    };
}
