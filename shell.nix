{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    libGL
    libdrm
    libinput
    pixman
    pkg-config
    udev
    wayland
    wayland-protocols
    wlroots
    libxkbcommon
    xlibs.libxcb
  ];
}
