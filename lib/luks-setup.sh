#!/bin/bash
# LUKS encryption setup

setup_luks() {
    local luks_partition="$1"
    
    log "Setting up LUKS encryption on $luks_partition"
    
    # Format with LUKS
    read -sp "Enter LUKS passphrase: " passphrase
    echo
    read -sp "Confirm passphrase: " passphrase_confirm
    echo
    
    if [[ "$passphrase" != "$passphrase_confirm" ]]; then
        log_error "Passphrases do not match"
        exit 1
    fi
    
    # Create LUKS volume
    echo -n "$passphrase" | cryptsetup luksFormat -c aes-xts-plain64 -s 512 -h sha512 "$luks_partition" -
    
    # Open LUKS volume
    echo -n "$passphrase" | cryptsetup luksOpen "$luks_partition" gentoo_crypt -
    
    log_success "LUKS encryption configured"
}
