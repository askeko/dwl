{ lib
, stdenv
, fetchFromGitHub
, installShellFiles
, libX11
, libinput
, libxcb
, libxkbcommon
, pixman
, pkg-config
, substituteAll
, wayland-scanner
, wayland
, wayland-protocols
, wlroots
, writeText
, xcbutilwm
, xwayland
, enableXWayland ? true
, conf ? null
}:

stdenv.mkDerivation ({
  pname = "dwl";
  version = "0.5";

  src = builtins.path { name = "dwl-custom"; path = ./.; };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    gnumake
  ];

  buildInputs = [
    libinput
    libxcb
    libxkbcommon
    pixman
    wayland
    wayland-protocols
    wlroots
  ] ++ lib.optionals enableXWayland [
    libX11
    xcbutilwm
    xwayland
  ];

  outputs = [ "out" "man" ];

  makeFlags = [
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
    "WAYLAND_SCANNER=wayland-scanner"
    "PREFIX=$(out)"
    "MANDIR=$(man)/share/man"
  ];

  preBuild = ''
    makeFlagsArray+=(
      XWAYLAND=${lib.optionalString enableXWayland "-DXWAYLAND"}
      XLIBS=${lib.optionalString enableXWayland "xcb\\ xcb-icccm"}
    )
  '';

  meta = {
    homepage = "https://github.com/askeko/dwl/";
    description = "Dynamic window manager for Wayland";
    longDescription = ''
      dwl is a compact, hackable compositor for Wayland based on wlroots. It is
      intended to fill the same space in the Wayland world that dwm does in X11,
      primarily in terms of philosophy, and secondarily in terms of
      functionality. Like dwm, dwl is:

      - Easy to understand, hack on, and extend with patches
      - One C source file (or a very small number) configurable via config.h
      - Limited to 2000 SLOC to promote hackability
      - Tied to as few external dependencies as possible
    '';
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.AndersonTorres ];
    inherit (wayland.meta) platforms;
    mainProgram = "dwl";
  };
})
