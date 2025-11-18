#!/bin/bash
# User account creation

create_user_account_chroot() {
    read -p "Enter username for new user account: " username
    read -sp "Enter password for $username: " user_password
    echo
    read -sp "Enter root password: " root_password
    echo
    
    # Set root password
    echo "root:$root_password" | chroot /mnt/gentoo chpasswd
    
    # Create user account
    chroot /mnt/gentoo useradd -m -G wheel,audio,video,render,kvm -s /bin/bash "$username"
    echo "$username:$user_password" | chroot /mnt/gentoo chpasswd
    
    # Configure sudo for wheel group
    cat >> /mnt/gentoo/etc/sudoers <<EOF
%wheel ALL=(ALL) ALL
EOF
    
    log_success "User account created: $username"
}
