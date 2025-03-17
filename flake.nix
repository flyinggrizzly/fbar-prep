{
  description = "env for fbar-prep";

  outputs = { self, nixpkgs }:
    let
      # Helper to provide system-specific attributes
      forAllSupportedSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      supportedSystems = [
        "aarch64-darwin"
        #"aarch64-linux"
        #"x86_64-darwin"
        #"x86_64-linux"
      ];
    in

    {
      devShells = forAllSupportedSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            bundix
            git
            gnumake
            nixpkgs-fmt
            ruby_3_4
          ];

          shellHook = ''
            bundle install
          '';
        };
      });
    };
}
