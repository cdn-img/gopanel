TARGETS = mountkernfs.sh hostname.sh keyboard-setup mountdevsubfs.sh checkroot.sh console-setup mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh networking urandom procps kbd bootmisc.sh x11-common udev-finish kmod checkroot-bootclean.sh
INTERACTIVE = keyboard-setup checkroot.sh console-setup kbd
keyboard-setup: mountkernfs.sh
mountdevsubfs.sh: mountkernfs.sh
checkroot.sh: mountdevsubfs.sh hostname.sh keyboard-setup
console-setup: mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh kbd
mountnfs.sh: mountall-bootclean.sh networking
mountnfs-bootclean.sh: mountall-bootclean.sh mountnfs.sh
networking: mountkernfs.sh mountall-bootclean.sh urandom procps
urandom: mountall-bootclean.sh
procps: mountkernfs.sh mountall-bootclean.sh
kbd: mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
bootmisc.sh: mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh checkroot-bootclean.sh
x11-common: mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
udev-finish: mountall-bootclean.sh
kmod: checkroot.sh
checkroot-bootclean.sh: checkroot.sh
