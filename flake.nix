{
  description = "Application packaged using poetry2nix";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, nix2container }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        p2n = import poetry2nix { inherit pkgs; };

        poetry_env = p2n.mkPoetryEnv {
          python = pkgs.python3;
          projectDir = self;
          preferWheels = true; # TODO only use wheels when needed 
        };

        poetry_app = p2n.mkPoetryApplication {
          python = pkgs.python3;
          projectDir = self;
          preferWheels = true;
        };

        pkgs = nixpkgs.legacyPackages.${system};

        nix2containerPkgs = nix2container.packages.x86_64-linux;
      in
      {

        devShells.default =
          pkgs.mkShell { packages = [ pkgs.poetry pkgs.just poetry_env ]; };

        packages = {
          minimal-example = nix2containerPkgs.nix2container.buildImage {
            name = "minimal-example";
            tag = "latest";
            config = {
              cmd = ["run"];
            };
            copyToRoot = pkgs.buildEnv {
              name = "root";
              paths = [ pkgs.bashInteractive pkgs.coreutils poetry_app ];
              pathsToLink = [ "/bin" ];
            };
          };
          default = self.packages.${system}.minimal-example;
        };
      });

}
