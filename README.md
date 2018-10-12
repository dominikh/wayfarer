# Wayfarer

Wayfarer is an experimental project, implementing a Wayland compositor in Go.
It is not usable, not complete, and not designed for widespread use.

Currently, it acts as a playground for experimenting with APIs.

The following assumptions are being made in its implementation

- EGL and OpenGL 4.x required – the API will not accomodate different render APIs
- Support for multiple backends (KMS, X11), but do note the previous point
- Fast hardware only; the experiments will not strive to work on old hardware or Intel GPUs.
- Linux only

None of the exported APIs in this repository are stable or meant for public consumption.

Don't bother filing issues or sending PRs;
at this point, this repository is just a mirror of my local experiments.
