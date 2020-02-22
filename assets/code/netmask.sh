#/bin/sh

# usage: netmask <n-bits>
netmask() {
  perl -le 'print join ".", unpack "C4", pack "N", 0xFFFFFFFF<<(32-shift)' "$1"
}

! grep -- '4f77114a2f49ae89c876b4a6c229d2ca' "$0" >/dev/null 2>&1 \
  || netmask "$@"
