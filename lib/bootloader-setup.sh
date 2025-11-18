#!/bin/bash
# systemd-boot bootloader setup

setup_bootloader_chroot() {
    # Install systemd and bootctl
    chroot /mnt/gentoo emerge -q sys-apps/systemd
    
    # Create boot entry
    local esp_path="/boot"
    mkdir -p "${esp_path}/loader/entries"
    
    # Get root UUID
    local root_uuid=$(blkid -s UUID -o value /dev/mapper/gentoo_crypt)
    
    # Find kernel name
    local kernel_image=$(chroot /mnt/gentoo ls /boot/kernel-* 2>/dev/null | head -1 || echo "/boot/kernel-gentoo")
    local initramfs=$(chroot /mnt/gentoo ls /boot/initramfs-* 2>/dev/null | head -1 || echo "/boot/initramfs")
    
    # Create boot entry
    cat > /mnt/gentoo/boot/loader/entries/gentoo.conf <<EOF
title Gentoo Linux
linux ${kernel_image#/mnt/gentoo}
initrd ${initramfs#/mnt/gentoo}
options root=UUID=$root_uuid rootflags=subvol=@ rd.luks=1 rd.luks.uuid=$(blkid -s UUID -o value ${LUKS_PARTITION}) rd.luks.name=$(blkid -s UUID -o value ${LUKS_PARTITION})=gentoo_crypt rw
EOF
    
    # Create loader.conf
    cat > /mnt/gentoo/boot/loader/loader.conf <<EOF
default gentoo
timeout 3
EOF
    
    # Install systemd-boot
    chroot /mnt/gentoo bootctl install --path=/boot
    
    log_success "systemd-boot configured"
}
