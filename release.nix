
{ pkgs ? import <nixpkgs> {}, ... }:

let
  elixir = pkgs.elixir_1_14;
  erlang = pkgs.erlang_25;
  build_inputs = [ elixir erlang ];
in
  pkgs.stdenv.mkDerivation {
    name = "el-magico-cache";
    buildInputs = build_inputs;
    shellHook = ''
      export MIX_ENV=prod
      mix release --env=prod
    '';
    src = ./.;
  }

v