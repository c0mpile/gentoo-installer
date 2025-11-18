#!/bin/bash
# Install required dependencies from Arch Linux

install_arch_dependencies() {
    local packages=(
       # "arch-chroot"
        "arch-install-scripts"
        "cryptsetup"
        "btrfs-progs"
        "efibootmgr"
        "dosfstools"
        "parted"
    )
    
    pacman -Sy --noconfirm "${packages[@]}"
}
