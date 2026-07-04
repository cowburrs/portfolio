{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {

      packages.x86_64-linux =
        let
          website = pkgs.stdenv.mkDerivation {
            name = "mdbook";
            src = ./.;
            nativeBuildInputs = with pkgs; [
              zola
            ];
            installPhase = ''
              runHook preInstall
              zola build
              cp -r ./public $out
              runHook postInstall
            '';
          };
        in
        {
          default = website;
          book = pkgs.writeShellApplication {
            name = "mkbook";
            text = ''
              python3 -m http.server 8000 -d ./public/ &
              xdg-open http://0.0.0.0:8000/
            '';
          };
        };

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          zola
          djlint
          mdformat
        ];

        shellHook = ''
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          export PS1="\n\[\033[1;32m\][nix-shell:\w]\$\[\033[0m\] "
          export XDG_DATA_DIRS="$GSETTINGS_SCHEMAS_PATH" # Needed on Wayland to report the correct display scale
        '';
      };
    };
}
