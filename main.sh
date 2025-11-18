#!/bin/bash
#
# Gentoo Linux Automated Installer
# Main orchestration script
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/gentoo-install-$(date +%s).log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
fi

# Source helper scripts
source "$SCRIPT_DIR/lib/arch-deps.sh"
source "$SCRIPT_DIR/lib/disk-partitioner.sh"
source "$SCRIPT_DIR/lib/luks-setup.sh"
source "$SCRIPT_DIR/lib/btrfs-setup.sh"
source "$SCRIPT_DIR/lib/chroot-base.sh"
source "$SCRIPT_DIR/lib/portage-config.sh"
source "$SCRIPT_DIR/lib/kernel-build.sh"
source "$SCRIPT_DIR/lib/bootloader-setup.sh"
source "$SCRIPT_DIR/lib/swap-setup.sh"
source "$SCRIPT_DIR/lib/user-setup.sh"
source "$SCRIPT_DIR/lib/hyprland-setup.sh"

main() {
    log "=== Gentoo Linux Automated Installer ==="
    log "Log file: $LOG_FILE"
    
    # Step 1: Install Arch dependencies
    log "Step 1/11: Installing Arch Linux dependencies..."
    install_arch_dependencies
    log_success "Arch dependencies installed"
    
    # Step 2: Prompt for target disk
    log "Step 2/11: Determining target disk..."
    local target_disk
    read -p "Enter target block device (default: /dev/nvme0n1): " target_disk
    target_disk="${target_disk:-/dev/nvme0n1}"
    
    if [[ ! -b "$target_disk" ]]; then
        log_error "Target disk does not exist: $target_disk"
        exit 1
    fi
    
    log "Target disk: $target_disk"
    read -p "WARNING: This will destroy all data on $target_disk. Continue? (yes/no): " confirm
    [[ "$confirm" == "yes" ]] || exit 1
    
    # Step 3: Partition disk
    log "Step 3/11: Partitioning disk..."
    partition_disk "$target_disk"
    log_success "Disk partitioned"
    
    # Step 4: Setup LUKS encryption
    log "Step 4/11: Setting up LUKS encryption..."
    local luks_partition="${target_disk}p3"
    setup_luks "$luks_partition"
    log_success "LUKS encryption configured"
    
    # Step 5: Setup btrfs
    log "Step 5/11: Setting up btrfs with subvolumes..."
    setup_btrfs
    log_success "btrfs setup complete"
    
    # Step 6: Download and extract stage3
    log "Step 6/11: Downloading and extracting stage3..."
    download_and_extract_stage3
    log_success "Stage3 extracted"
    
    # Step 7: Chroot and configure portage
    log "Step 7/11: Chrooting and configuring portage..."
    configure_portage_chroot
    log_success "Portage configured"
    
    # Step 8: Build kernel
    log "Step 8/11: Building kernel with genkernel..."
    build_kernel_chroot
    log_success "Kernel built"
    
    # Step 9: Setup systemd-boot
    log "Step 9/11: Setting up systemd-boot..."
    setup_bootloader_chroot
    log_success "Bootloader configured"
    
    # Step 10: Setup swap
    log "Step 10/11: Setting up swap..."
    local swap_size
    read -p "Enter swap size in GB (leave empty for zram): " swap_size
    if [[ -z "$swap_size" ]]; then
        setup_zram_chroot
    else
        setup_swapfile_chroot "$swap_size"
    fi
    log_success "Swap configured"
    
    # Step 11: Create user account
    log "Step 11/11: Creating user account and setting passwords..."
    create_user_account_chroot
    log_success "User account created"
    
    # Install Hyprland and DankMaterialShell
    log "Installing Hyprland and DankMaterialShell..."
    install_hyprland_dms_chroot
    log_success "Hyprland and DMS installed"
    
    log_success "=== Gentoo installation complete! ==="
    log "System will reboot in 10 seconds. Press Ctrl+C to cancel."
    sleep 10
    reboot
}

main "$@"
