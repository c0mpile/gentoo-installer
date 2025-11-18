# Gentoo Linux Automated Installer

A complete automated installation script for Gentoo Linux featuring LUKS encryption, btrfs subvolumes, systemd-boot, and a fully configured Hyprland desktop environment with DankMaterialShell.

## Features

- **Automated Disk Partitioning**: Creates 2GB EFI partition and encrypted root partition
- **LUKS Encryption**: Secure root filesystem with AES-XTS encryption
- **btrfs Subvolumes**: Comprehensive subvolume layout for optimal system organization:
  - `@` → `/`
  - `@root` → `/root`
  - `@home` → `/home`
  - `@opt` → `/opt`
  - `@srv` → `/srv`
  - `@log` → `/var/log`
  - `@tmp` → `/var/tmp`
  - `@cache` → `/var/cache`
  - `@snapshots` → `/.snapshots`

- **systemd-boot**: Modern EFI bootloader with simple configuration
- **Genkernel**: Automatic kernel compilation with encrypted btrfs support
- **PipeWire Audio**: Modern audio subsystem with full feature support
- **Hyprland**: Modern wayland compositor with exceptional configurability
- **DankMaterialShell**: Beautiful Material You-inspired shell with comprehensive configuration
- **CPU Detection**: Automatic CPU flags detection and optimization
- **Flexible Swap**: Choose between zram or traditional swapfile
- **Portage Optimization**: Automatic nproc detection and optimal MAKEOPTS/EMERGE_DEFAULT_OPTS

## Prerequisites

- Boot from **Arch Linux live environment** (recommended for package availability)
- Internet connectivity
- Target disk with at least 50GB capacity (100GB+ recommended for comfortable development)
- UEFI firmware support

## Usage

### 1. Boot Arch Linux Live Environment

```bash
# Connect to network if needed
iwctl

# Clone installer repository
git clone https://github.com/c0mpile/gentoo-installer
cd gentoo-installer

# Make scripts executable
chmod +x main.sh
chmod +x lib/*.sh

# Run installer (requires root)
sudo ./main.sh
```

### 2. Follow Interactive Prompts

The installer will prompt you for:

1. **Target Disk**: Block device for installation (defaults to `/dev/nvme0n1`)
2. **LUKS Passphrase**: Encryption passphrase for root filesystem
3. **Swap Configuration**: Size in GB for swap file, or empty for zram
4. **User Credentials**: Username and password for regular user account
5. **Root Password**: Administrative password

### 3. Post-Installation Setup

After reboot into the new Gentoo system:

```bash
# Install DankMaterialShell as regular user
cd ~
git clone https://github.com/dankmal/dank-shell.git
cd dank-shell
./install.sh

# Start Hyprland session
Hyprland
```

## Installation Structure

```
gentoo-installer/
├── main.sh                 # Main orchestration script
├── lib/
│   ├── arch-deps.sh       # Arch Linux dependency installation
│   ├── disk-partitioner.sh # Disk partitioning logic
│   ├── luks-setup.sh      # LUKS encryption configuration
│   ├── btrfs-setup.sh     # btrfs filesystem and subvolumes
│   ├── chroot-base.sh     # Stage3 extraction
│   ├── portage-config.sh  # Portage configuration and optimization
│   ├── kernel-build.sh    # Kernel building with genkernel
│   ├── bootloader-setup.sh # systemd-boot configuration
│   ├── swap-setup.sh      # Swap configuration (zram/swapfile)
│   ├── user-setup.sh      # User account creation
│   └── hyprland-setup.sh  # Hyprland and desktop environment setup
├── README.md              # This file
└── LICENSE                # MIT License
```

## Configuration Details

### make.conf Settings

- **ACCEPT_LICENSE**: `*` (accept all licenses)
- **ACCEPT_KEYWORDS**: `~amd64` (unstable channel for latest packages)
- **MAKEOPTS**: Automatically set to `-j(nproc+1) -l(nproc)` for optimal compilation
- **EMERGE_DEFAULT_OPTS**: Parallel emerge with load balancing
- **USE Flags**: Optimized for desktop with pipewire, wayland, and Hyprland support
- **Binary Packages**: Enabled for faster compilation

### Kernel Configuration

- **genkernel** used for automatic kernel building
- Automatic LUKS support enabled
- Automatic btrfs support enabled
- Dracut integration for initramfs generation

### Hyprland Setup

The installer includes all necessary dependencies:
- Wayland protocols and libraries
- PipeWire audio server and WirePlumber session manager
- Waybar for taskbar functionality
- Required display managers (SDDM)
- Development tools and utilities

## Customization

### Modifying Subvolume Layout

Edit `lib/btrfs-setup.sh` to add or modify btrfs subvolumes. Each subvolume is created and mounted with optimal flags for its purpose.

### Adjusting Compilation Flags

Modify the CFLAGS in `lib/portage-config.sh` if you need different optimization levels:

```bash
# Example for performance-focused build
CFLAGS="-O3 -march=native -pipe -fomit-frame-pointer"
```

### Changing Desktop Environment

Edit `lib/hyprland-setup.sh` to install different packages:

```bash
# For KDE Plasma instead of Hyprland
chroot /mnt/gentoo emerge -q kde-plasma/plasma-desktop
```

## Troubleshooting

### Boot Issues

If the system doesn't boot after installation:

1. Boot from Arch live environment again
2. Mount the encrypted partition:
   ```bash
   cryptsetup luksOpen /dev/nvme0n1p3 gentoo_crypt
   mount -o subvol=@ /dev/mapper/gentoo_crypt /mnt/gentoo
   ```
3. Check bootloader configuration:
   ```bash
   cat /mnt/gentoo/boot/loader/entries/gentoo.conf
   ```
4. Verify kernel and initramfs exist:
   ```bash
   ls -la /mnt/gentoo/boot/
   ```

### LUKS Unlock

If the LUKS passphrase prompt doesn't appear:

1. Verify dracut is configured in genkernel.conf
2. Rebuild initramfs:
   ```bash
   chroot /mnt/gentoo genkernel initramfs --luks --btrfs
   ```

### Hyprland Installation

If Hyprland fails to build:

1. Check portage logs: `/var/tmp/portage/*/build.log`
2. Enable problematic keywords if needed in make.conf
3. Try binary packages first: `emerge -q --getbinpkg gui-wm/hyprland`

## Performance Tips

### btrfs Optimization

- Compression: `zstd` provides good balance of speed and ratio
- Space cache v2: Enabled for improved performance
- `discard=async`: Better for SSD performance

### Compilation Optimization

- MAKEOPTS automatically set to `(nproc+1)` for best results
- EMERGE_DEFAULT_OPTS uses `(nproc/2)` parallel jobs
- Binary packages enabled by default to reduce build times

### Runtime Performance

- Use zram for lightweight swap (default if no size specified)
- Consider swapfile for systems with heavy workloads
- zram is ephemeral and faster, swapfile persists across reboots

## Security Considerations

- LUKS encryption uses AES-XTS-512 (serpent algorithm available as option)
- Root filesystem is encrypted
- Secure boot ready (can be configured separately)
- CPU flags automatically detected for hardware-optimized packages

## Future Enhancements

- [ ] Secure Boot integration
- [ ] ZFS filesystem option
- [ ] Multiple desktop environment support
- [ ] Automated kernel module handling
- [ ] Integration testing in containers
- [ ] Support for older BIOS systems

## Support and Issues

For issues, questions, or suggestions:

1. Check the troubleshooting section
2. Review Gentoo Wiki: https://wiki.gentoo.org/
3. Open an issue on GitHub with detailed logs

## License

MIT License - See LICENSE file for details

## References

- [Gentoo Linux Handbook](https://wiki.gentoo.org/wiki/Handbook)
- [Hyprland Documentation](https://hyprland.org/)
- [DankMaterialShell](https://github.com/dankmal/dank-shell)
- [systemd-boot Documentation](https://wiki.archlinux.org/title/systemd-boot)
- [btrfs Wiki](https://btrfs.wiki.kernel.org/)
