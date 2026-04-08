#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-root}"

mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

# X server for VNC desktop
# Prefer Xorg dummy (better GLX compatibility for RViz), fall back to Xvfb.
DISPLAY_NUM="${DISPLAY#:}"
XORG_CONF="/tmp/xorg.conf"

cat > "${XORG_CONF}" <<'EOF'
Section "Device"
  Identifier "DummyDevice"
  Driver "dummy"
  VideoRam 256000
EndSection

Section "Monitor"
  Identifier "DummyMonitor"
  HorizSync 28.0-80.0
  VertRefresh 48.0-75.0
EndSection

Section "Screen"
  Identifier "DummyScreen"
  Device "DummyDevice"
  Monitor "DummyMonitor"
  DefaultDepth 24
  SubSection "Display"
    Depth 24
    Modes "1280x800"
  EndSubSection
EndSection

Section "ServerLayout"
  Identifier "DummyLayout"
  Screen "DummyScreen"
EndSection

Section "ServerFlags"
  Option "DontVTSwitch" "true"
  Option "DontZap" "true"
EndSection

Section "Extensions"
  Option "GLX" "Enable"
  Option "DRI2" "Enable"
  Option "DRI3" "Disable"
EndSection
EOF

if command -v Xorg >/dev/null 2>&1; then
  # +iglx enables indirect GLX (needed for some software GLX clients).
  Xorg "${DISPLAY}" +iglx -config "${XORG_CONF}" -noreset -nolisten tcp -logfile /tmp/Xorg.log >/tmp/xorg.stdout 2>&1 &
else
  Xvfb "${DISPLAY}" -screen 0 1280x800x24 -ac +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 &
fi

# Lightweight window manager
fluxbox >/tmp/fluxbox.log 2>&1 &

# VNC server
x11vnc -display "${DISPLAY}" -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900 >/tmp/x11vnc.log 2>&1 &

NOVNC_WEB_ROOT=""
if [[ -d /usr/share/novnc ]]; then
  NOVNC_WEB_ROOT="/usr/share/novnc"
elif [[ -d /usr/share/novnc/www ]]; then
  NOVNC_WEB_ROOT="/usr/share/novnc/www"
fi

if [[ -n "${NOVNC_WEB_ROOT}" ]]; then
  # noVNC web client (HTTP :6080) -> websockify -> VNC (:5900)
  websockify --web "${NOVNC_WEB_ROOT}" 6080 localhost:5900 >/tmp/websockify.log 2>&1 &
  echo "noVNC ready on http://localhost:6080 (DISPLAY=${DISPLAY})"
else
  echo "VNC ready on port 5900 (DISPLAY=${DISPLAY})"
  echo "noVNC web root not found; install novnc/websockify or use a VNC client."
fi

exec bash

