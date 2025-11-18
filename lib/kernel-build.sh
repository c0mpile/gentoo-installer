#!/bin/bash
# Kernel building with genkernel

build_kernel_chroot() {
    # Configure genkernel.conf
    cat >> /mnt/gentoo/etc/genkernel.conf <<EOF
LUKS="yes"
BTRFS="yes"
ZFS="no"
DRAEUN="yes"
EOF
    
    # Install genkernel and required packages
    chroot /mnt/gentoo emerge -q sys-kernel/gentoo-sources sys-kernel/genkernel dracut
    
    # Get kernel version
    local kernel_version=$(chroot /mnt/gentoo eselect kernel list | grep \* | awk '{print $NF}' | head -1)
    
    # Build kernel with genkernel
    chroot /mnt/gentoo genkernel --luks --btrfs --install all
    
    log_success "Kernel built with genkernel"
}
