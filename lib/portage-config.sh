#!/bin/bash
# Portage configuration

configure_portage_chroot() {
    local nproc=$(nproc)
    local makeopts="-j$((nproc + 1)) -l$nproc"
    local emerge_opts="--jobs=$((nproc / 2)) --load-average=$nproc"
    
    # Create make.conf
    cat > /mnt/gentoo/etc/portage/make.conf <<EOF
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="~amd64"

MAKEOPTS="$makeopts"
EMERGE_DEFAULT_OPTS="$emerge_opts --keep-going"

FEATURES="getbinpkg binpkg-multi-instance"
BINPKG_COMPRESS="zstd"
BINPKG_COMPRESS_FLAGS="-9 -T0"

# Desktop installation
USE="wayland pipewire alsa pulseaudio -pulseaudio -alsa opengl"
USE="\$USE X gtk gnome wayland vulkan opengl"
USE="\$USE lua python ruby"
USE="\$USE systemd udev"

# Display server and window manager
USE="\$USE hyprland wayland xwayland"

# Video drivers
USE="\$USE -radeon -nouveau -freedreno intel nvidia"

LANG="en_US.UTF-8"
LC_COLLATE="C.UTF-8"
EOF
    
    # Enable GURU overlay
    mkdir -p /mnt/gentoo/etc/portage/repos.conf
    eselect repository enable guru --root=/mnt/gentoo || true
    
    # Configure CPU flags
    chroot /mnt/gentoo emerge -q app-portage/cpuid2cpuflags
    chroot /mnt/gentoo bash -c 'echo "*/* \$(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags'
    
    # Sync portage
    chroot /mnt/gentoo emerge --sync
    
    log_success "Portage configured"
}
