#! /usr/bin/env bash

# Create a default.nix file
echo "Creating default.nix file..."
echo "
{ pkgs ? import <nixpkgs> {}, ... }:

let
  elixir = pkgs.elixir_1_14;
  erlang = pkgs.erlang_25;
  build_inputs = [ elixir erlang ];
in
  pkgs.stdenv.mkDerivation {
    name = \"el-magico-cache\";
    buildInputs = build_inputs;
    shellHook = ''
      export MIX_ENV=prod
    '';
    src = ./.;
  }
" > default.nix

# Create a release.nix file
echo "Creating release.nix file..."
echo "
{ pkgs ? import <nixpkgs> {}, ... }:

let
  elixir = pkgs.elixir_1_14;
  erlang = pkgs.erlang_25;
  build_inputs = [ elixir erlang ];
in
  pkgs.stdenv.mkDerivation {
    name = \"el-magico-cache\";
    buildInputs = build_inputs;
    shellHook = ''
      export MIX_ENV=prod
      mix release --env=prod
    '';
    src = ./.;
  }
" > release.nix

# Create a shell.nix file
echo "Creating shell.nix file..."
echo "
{ pkgs ? import <nixpkgs> {}, ... }:

let
  elixir = pkgs.elixir_1_14;
  erlang = pkgs.erlang_25;
  build_inputs = [ elixir erlang ];
in
  pkgs.stdenv.mkDerivation {
    name = \"el-magico-cache\";
    buildInputs = build_inputs;
    shellHook = ''
      export MIX_ENV=dev
    '';
    src = ./.;
  }
" > shell.nix

# Create a nixpack.nix file
echo "Creating nixpack.nix file..."
echo "
{ pkgs ? import <nixpkgs> {}, ... }:

let
  elixir = pkgs.elixir_1_14;
  erlang = pkgs.erlang_25;
  build_inputs = [ elixir erlang ];
in
  pkgs.nixpack.mkNixPack {
    name = \"el-magico-cache\";
    buildInputs = build_inputs;
    src = ./.;
  }
" > nixpack.nix

# Create a config directory
echo "Creating config directory..."
mkdir config

# Create a config/config.exs file
echo
