#!/bin/bash
# btrfs filesystem and subvolume setup

setup_btrfs() {
    local luks_mapper=/dev/mapper/gentoo_crypt
    
    # Create btrfs filesystem
    mkfs.btrfs -L gentoo "$luks_mapper"
    
    # Create mount point
    mkdir -p /mnt/gentoo
    
    # Mount root subvolume
    mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2 "$luks_mapper" /mnt/gentoo
    
    # Create subvolumes
    btrfs subvolume create /mnt/gentoo/@
    btrfs subvolume create /mnt/gentoo/@root
    btrfs subvolume create /mnt/gentoo/@home
    btrfs subvolume create /mnt/gentoo/@opt
    btrfs subvolume create /mnt/gentoo/@srv
    btrfs subvolume create /mnt/gentoo/@log
    btrfs subvolume create /mnt/gentoo/@tmp
    btrfs subvolume create /mnt/gentoo/@cache
    btrfs subvolume create /mnt/gentoo/@snapshots
    
    # Unmount and remount with subvolumes
    umount /mnt/gentoo
    
    # Mount root subvolume as /
    mount -o subvol=@,noatime,compress=zstd,ssd,discard=async,space_cache=v2 "$luks_mapper" /mnt/gentoo
    
    # Create mount points and mount subvolumes
    mkdir -p /mnt/gentoo/{root,home,opt,srv,var/log,var/tmp,var/cache,.snapshots}
    
    for subvol in @root @home @opt @srv; do
        mountpoint="/mnt/gentoo/${subvol#@}"
        mount -o "subvol=$subvol,noatime,compress=zstd,ssd,discard=async,space_cache=v2" "$luks_mapper" "$mountpoint"
    done
    
    # Mount /var/* subvolumes with nodatacow for logs
    mount -o "subvol=@log,nodatacow,nodatasum,noatime" "$luks_mapper" /mnt/gentoo/var/log
    mount -o "subvol=@tmp,nodatacow,nodatasum,noatime" "$luks_mapper" /mnt/gentoo/var/tmp
    mount -o "subvol=@cache,nodatacow,nodatasum,noatime" "$luks_mapper" /mnt/gentoo/var/cache
    
    # Mount snapshots
    mount -o "subvol=@snapshots,noatime,compress=zstd,ssd,discard=async,space_cache=v2" "$luks_mapper" /mnt/gentoo/.snapshots
    
    # Mount EFI
    mkdir -p /mnt/gentoo/boot
    mount "${DISK}p1" /mnt/gentoo/boot
    
    log_success "btrfs subvolumes mounted"
}
