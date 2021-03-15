let
  moz_overlay = import (builtins.fetchTarball https://codeload.github.com/mozilla/nixpkgs-mozilla/tar.gz/master);
  nixpkgs = import <nixpkgs> {
    overlays = [ moz_overlay ];
  };
  rustNightly = (nixpkgs.latest.rustChannels.nightly.rust.override {
    extensions = [ "rust-src" "rust-analysis" ];}
  );
  rustStable = (nixpkgs.latest.rustChannels.stable.rust.override {
    extensions = [ "rust-src" "rust-analysis" ];}
  );
in
  with nixpkgs;
  let
    vimConfigured = neovim.override {
      configure = {
        customRC = ''
          set mouse=
          let g:rustfmt_autosave = 1
        '';

        plug.plugins = with vimPlugins; [
          rust-vim
        ];
      };
    };

  in stdenv.mkDerivation {
    name = "rust";
    nativeBuildInputs = [
      vimConfigured
    ];
    buildInputs = [
      rustNightly
    ];
    #LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
    PROTOBUF_LOCATION = protobuf.out;
    PROTOC = "${protobuf.out}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf.out}/include";

    shellHook = ''
      alias vi="${vimConfigured}/bin/nvim";
      alias vim=vi;
    '';
  }
