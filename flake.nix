{
  description = "WordPress Local (LocalWP) FHS environment for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      version = "9.0.5";
      
      # Official LocalWP release download
      src = pkgs.fetchurl {
        url = "https://cdn.localwp.com/releases-stable/${version}+6706/local-${version}-linux.deb";
        # Set to empty string initially so Nix throws a hash mismatch error with the correct hash
        hash = "sha256-ti7OiqIzTQh2yXJyHGp9rXh01KASuDVHzxbR+Y7qU3o="; 
      };

      # Unpack .deb into the Nix store
      localwp-unwrapped = pkgs.stdenv.mkDerivation {
        pname = "localwp-unwrapped";
        inherit version src;
        nativeBuildInputs = [ pkgs.dpkg ];
        unpackPhase = "dpkg-deb -x $src .";
        installPhase = ''
          mkdir -p $out
          cp -r opt usr $out/
        '';
      };
    in {
      packages.${system} = {
        local = pkgs.buildFHSEnv {
          name = "local";
          targetPkgs = pkgs: with pkgs; [
            # Core UI / Electron dependencies
            glibc glib nspr nss atk at-spi2-atk at-spi2-core cups dbus
            cairo gtk3 pango libx11 libxcomposite libxdamage
            libxext libxfixes libxrandr mesa libgbm expat libdrm
            libxcb libxkbcommon systemd alsa-lib libglvnd numactl

            # Runtime Site Services (Nginx, PHP, MariaDB, WP-CLI, Router)
            openssl zlib libxml2 libxslt sqlite icu libaio ncurses
            libxcrypt-legacy lsof procps libcap libtirpc
          ];

          runScript = "${localwp-unwrapped}/opt/Local/local";
        };

        default = self.packages.${system}.local;
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.local}/bin/local";
      };
    };
}
