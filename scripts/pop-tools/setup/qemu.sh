#!/usr/bin/env bash

set -euox pipefail

# https://christitus.com/vm-setup-in-archlinux/
if (($(grep -E -c '(vmx|svm)' /proc/cpuinfo) > 0)); then
    # yay -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables libguestfs --needed
    yay -S qemu-desktop virt-manager --needed

    sudo usermod -a -G libvirt "$(whoami)"
    newgrp libvirt

    sudo sed -i 's/^#\(unix_sock_group = "libvirt"\)/\1/' /etc/libvirt/libvirtd.conf
    sudo sed -i 's/^#\(unix_sock_rw_perms = "0770"\)/\1/' /etc/libvirt/libvirtd.conf

    sudo systemctl enable --now libvirtd
    sudo systemctl start libvirtd

    # Note seem to need a restart to work
else
    echo "Missing virtualization extension!!!"
    exit 10
fi
