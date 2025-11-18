#!/bin/bash
# Swap configuration (zram or swapfile)

setup_zram_chroot() {
    # Configure zram in kernel
    cat >> /mnt/gentoo/etc/modprobe.d/zram.conf <<EOF
options zram num_devices=1
EOF
    
    # Create systemd service for zram
    cat > /mnt/gentoo/etc/systemd/system/zram.service <<EOF
[Unit]
Description=Zram setup
After=sys-kernel-mm-ksm.device

[Service]
Type=oneshot
ExecStart=/usr/bin/zramctl -a zstd -s 4G /dev/zram0
ExecStart=/usr/sbin/mkswap /dev/zram0
ExecStart=/usr/sbin/swapon /dev/zram0

[Install]
WantedBy=multi-user.target
EOF
    
    chroot /mnt/gentoo systemctl enable zram.service
    log_success "zram configured"
}

setup_swapfile_chroot() {
    local swap_size="$1"
    
    # Create swap subvolume if not exists
    chroot /mnt/gentoo btrfs subvolume create /var/swap 2>/dev/null || true
    
    # Create swapfile
    local swapfile=/var/swap/swapfile
    chroot /mnt/gentoo truncate -s 0 "$swapfile"
    chroot /mnt/gentoo chattr +C "$swapfile"
    chroot /mnt/gentoo btrfs property set "$swapfile" compression none
    chroot /mnt/gentoo dd if=/dev/zero of="$swapfile" bs=1M count="$((swap_size * 1024))"
    chroot /mnt/gentoo chmod 600 "$swapfile"
    chroot /mnt/gentoo mkswap "$swapfile"
    chroot /mnt/gentoo swapon "$swapfile"
    
    # Add to fstab
    local swapfile_uuid=$(chroot /mnt/gentoo swapoff -s | grep swapfile | awk '{print $1}')
    echo "$swapfile none swap sw 0 0" >> /mnt/gentoo/etc/fstab
    
    log_success "Swap file configured ($swap_size GB)"
}
