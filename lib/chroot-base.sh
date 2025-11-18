#!/bin/bash
# Base chroot operations

download_and_extract_stage3() {
    local mirror="https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/"
    local stage3_dir=/mnt/gentoo
    
    cd /tmp
    
    # Download latest stage3 with systemd
    log "Downloading stage3 tarball..."
    
    # Get the latest filename
    local stage3_file=$(curl -s "$mirror" | grep -oP 'stage3-amd64-systemd-\d{8}T\d{6}Z\.tar\.xz' | tail -1)
    
    if [[ -z "$stage3_file" ]]; then
        log_error "Could not determine stage3 filename"
        exit 1
    fi
    
    wget "${mirror}${stage3_file}"
    
    # Extract stage3
    log "Extracting stage3..."
    tar xpf "$stage3_file" -C "$stage3_dir" --xattrs-include='*.*' --numeric-owner
    
    log_success "Stage3 extracted"
}
