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
    wayland.debug
    wayland-protocols
    wlroots
    zig
    gdb
    weston
    weston.debug
    libxkbcommon
    xlibs.libxcb
  ];
}
