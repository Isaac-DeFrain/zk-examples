{
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs?ref=931494da4b60fb26719e231d6de4b2c96167a1ce";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
    ] (system: let
      overlays = [(import rust-overlay)];

      pkgs = import nixpkgs {inherit system overlays;};

      # format with alejandra
      formatter.system = pkgs.legacyPackages.x86_64-linux.alejandra;

      rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      rustPlatform = pkgs.makeRustPlatform {
        cargo = rust;
        rustc = rust;
      };

      runtimeDependencies = with pkgs; [];

      buildDependencies = with pkgs;
        [
          cargo-nextest
          clang
          libclang.lib
          mold-wrapped # https://github.com/rui314/mold#mold-a-modern-linker
          pkg-config
          rustPlatform.bindgenHook
        ]
        ++ runtimeDependencies;

      # used to ensure rustfmt is nightly version to support unstable features
      nightlyToolchain =
        pkgs.rust-bin.selectLatestNightlyWith (toolchain:
          toolchain.minimal.override {extensions = ["rustfmt"];});

      developmentDependencies = with pkgs;
        [
          alejandra
          biome
          cargo-audit
          cargo-machete
          git
          just
          nightlyToolchain.passthru.availableComponents.rustfmt
          rust
          shfmt
          mdformat
        ]
        ++ buildDependencies;

      cargo-toml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
    in
      with pkgs; {
        packages = flake-utils.lib.flattenTree rec {
          zk-examples = rustPlatform.buildRustPackage rec {
            meta = with lib; {
              description = ''
                zk examples
              '';
            #   homepage = "https://github.com/Isaac-DeFrain/zk-examples";
            #   license = licenses.asl20;
            #   mainProgram = "zk-examples";
            #   platforms = platforms.all;
              maintainers = [];
            };

            pname = cargo-toml.package.name;

            version = cargo-toml.package.version;

            src = lib.cleanSourceWith {
              src = lib.cleanSource ./.;
              filter = path: type:
                (path != ".direnv")
                && (path != "Justfile")
                && (path != "target")
                && (path != "tests");
            };

            cargoLock = {lockFile = ./Cargo.lock;};

            nativeBuildInputs = buildDependencies;

            buildInputs = runtimeDependencies;

            # env = { LIBCLANG_PATH = "${libclang.lib}/lib"; };

            # This is equivalent to `git rev-parse --short=8 HEAD`
            gitCommitHash = builtins.substring 0 8 (self.rev or "dev");

            # postPatch = ''ln -s "${./Cargo.lock}" Cargo.lock'';
            preBuild = ''
              export GIT_COMMIT_HASH=${gitCommitHash}
            '';
            checkPhase = ''
              set -ex
              cargo clippy --all-targets --all-features -- -D warnings
              cargo nextest run --release
            '';
            preInstall = "mkdir -p $out/var/log/zk-examples";
          };

          default = zk-examples;

        #   dockerImage = pkgs.dockerTools.buildImage {
        #     name = "zk-examples";
        #     created = "now";
        #     tag = builtins.substring 0 8 (self.rev or "dev");
        #     copyToRoot = pkgs.buildEnv {
        #       paths = with pkgs; [zk-examples bash self];
        #       name = "zk-examples-root";
        #       pathsToLink = ["/bin" "/share"];
        #     };
        #     config.Cmd = ["${pkgs.lib.getExe zk-examples}"];
        #   };
        };

        devShells.default = mkShell {
          env = {LIBCLANG_PATH = "${libclang.lib}/lib";};
          buildInputs = developmentDependencies;
          shellHook = "export TMPDIR=/var/tmp";
        };
      });
}
