#!/bin/bash
# Disk partitioning and EFI setup

partition_disk() {
    local disk="$1"
    
    # Clear existing partitions
    sgdisk --zap-all "$disk"
    
    # Create partitions
    # 2GB EFI partition
    sgdisk --new=1:0:+2G --typecode=1:ef00 "$disk"
    # Remaining space for LUKS encrypted btrfs
    sgdisk --new=3:0:0 --typecode=3:8300 "$disk"
    
    # Format EFI partition
    mkfs.vfat -F32 "${disk}p1"
    
    log "Partitioning complete"
}
