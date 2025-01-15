{ lib
, stdenv
, mkMesonLibrary

, nix-store-c
, nix-expr-c
, nix-flake

# Configuration Options

, version
}:

let
  inherit (lib) fileset;
in

mkMesonLibrary (finalAttrs: {
  pname = "nix-flake-c";
  inherit version;

  workDir = ./.;
  fileset = fileset.unions [
    ../../nix-meson-build-support
    ./nix-meson-build-support
    ../../.version
    ./.version
    ./meson.build
    # ./meson.options
    (fileset.fileFilter (file: file.hasExt "cc") ./.)
    (fileset.fileFilter (file: file.hasExt "hh") ./.)
    (fileset.fileFilter (file: file.hasExt "h") ./.)
  ];

  propagatedBuildInputs = [
    nix-expr-c
    nix-store-c
    nix-flake
  ];

  preConfigure =
    # "Inline" .version so it's not a symlink, and includes the suffix.
    # Do the meson utils, without modification.
    ''
      chmod u+w ./.version
      echo ${version} > ../../.version
    '';

  mesonFlags = [
  ];

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
