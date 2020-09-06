#!/bin/sh
url='https://github.polettix.it/ETOOBUSY/assets/other/busybox-1.31.0-x86_64'
case "$1" in
    (--go)
        curl -Lo busybox "$url" &&
        chmod +x busybox &&
        ./busybox --install .
        ;;
    (*)
        cat >&2 <<END
WARNING: this installs busybox and ALL ITS ALIASES in the current directory.
If you are OK, re-run as: $0 --go
END
        exit 1
        ;;
esac
