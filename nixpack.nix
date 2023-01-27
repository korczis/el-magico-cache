
{ pkgs ? import <nixpkgs> {}, ... }:

let
  elixir = pkgs.elixir_1_14;
  erlang = pkgs.erlang_25;
  build_inputs = [ elixir erlang ];
in
  pkgs.nixpack.mkNixPack {
    name = "el-magico-cache";
    buildInputs = build_inputs;
    src = ./.;
  }

