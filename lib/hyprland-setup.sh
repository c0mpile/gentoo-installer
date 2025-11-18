#!/bin/bash
# Hyprland and DankMaterialShell installation

install_hyprland_dms_chroot() {
    # Install Hyprland and dependencies
    chroot /mnt/gentoo emerge -q gui-wm/hyprland wayland-protocols wayland
    
    # Install PipeWire and audio packages
    chroot /mnt/gentoo emerge -q media-sound/pipewire media-sound/wireplumber
    
    # Install terminal emulator
    chroot /mnt/gentoo emerge -q x11-misc/alacritty
    
    # Install display manager
    chroot /mnt/gentoo emerge -q x11-misc/sddm
    chroot /mnt/gentoo systemctl enable sddm
    
    # Install necessary tools for Hyprland
    chroot /mnt/gentoo emerge -q gui-apps/waybar app-misc/brightnessctl
    
    # Clone DankMaterialShell repository for default user
    # This will be done by the user after boot
    
    log_success "Hyprland and dependencies installed"
}
