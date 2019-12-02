#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

shopt -s extglob nullglob

declare -a REMOVE_LIST

# Important note: this cleanup file is intended to work on the root tree
# resulting of the current recipe action AND NOT ON THE ROOT OF THE SDK
# ENVIRONMENT!
# This is the reason why, all the items of the REMOVE_LIST array are prefixed
# with the same variable "root" defined here:
readonly root="${CURRENT_OUT_ROOT}"

# Make sure some folders are empty
REMOVE_LIST+=(
    # extglob option required for those patterns:
    "$root"/tmp/!(.|..)
    "$root"/var/!(.|..)
)

# Exclude documentation, bash-completion files, etc.
REMOVE_LIST+=(
    "$root"/usr/share/bash-completion
    "$root"/usr/share/gdb
    "$root"/usr/share/gtk-doc
    "$root"/usr/share/udhcpc
    "$root"/usr/share/zsh
)

# Remove all portage related files
REMOVE_LIST+=(
    "$root"/usr/share/eselect
)

# FIXME: find which packages install those
# Remove various unneeded binaries
REMOVE_LIST+=(
    "$root"/bin/passwd
    "$root"/bin/su
    "$root"/sbin/mkfs
    "$root"/sbin/mkfs.bfs
    "$root"/sbin/mkfs.minix
    "$root"/usr/bin/chage
    "$root"/usr/bin/chfn
    "$root"/usr/bin/chsh
    "$root"/usr/bin/expiry
    "$root"/usr/bin/gpasswd
)

# FIXME: find which packages install those
# Remove headers & include files
REMOVE_LIST+=(
    "$root"/usr/include

    # nullglob required for those two glob patterns:
    "$root"/usr/lib64/binutils/x86_64-pc-linux-gnu/*/include
    "$root"/usr/lib64/dbus-*/include
)

# FIXME: Remove those from baselayout/systemd
# baselayout: /etc/modules-load.d/{aliases,i386}.conf
REMOVE_LIST+=(
    "$root"/etc/modprobe.d
    "$root"/etc/modules-load.d
    "$root"/lib/modprobe.d
    "$root"/usr/lib/modules-load.d
)

# Remove invalid or unneeded configuration
REMOVE_LIST+=(
    "$root"/etc/conf.d
    "$root"/etc/csh.env
    "$root"/etc/dmtab
    "$root"/etc/filesystems
    "$root"/etc/gai.conf
    "$root"/etc/gentoo-release
    "$root"/etc/init.d
    "$root"/etc/locale.gen
    "$root"/etc/localtime
    "$root"/etc/login.defs
    "$root"/etc/machine-id
    "$root"/etc/networks
    "$root"/etc/os-release
    "$root"/etc/portage
    "$root"/etc/runlevels
    "$root"/etc/sandbox.d
    "$root"/etc/sysctl.conf
    "$root"/usr/lib/os-release
)

# Remove existing user & group configuration
REMOVE_LIST+=(
    "$root"/etc/group
    "$root"/etc/group-
    "$root"/etc/gshadow
    "$root"/etc/gshadow-
    "$root"/etc/passwd
    "$root"/etc/passwd-
    "$root"/etc/shadow
    "$root"/etc/shadow-
)

msg="Remove various unwanted items from ROOT (first pass):"
for item in "${REMOVE_LIST[@]}"; do
    if [[ ! -e "${item}" ]]; then
        # Do not list the items to be removed if they cannot be found in ROOT
        continue
    fi
    msg+=$'\n'"  $(stat -c '%A  %u:%g' "${item}")  ${item#${root}}"
done
sdk_info "$msg"
unset msg

# Use a for loop to avoid constructing a too long "rm -rf" command line.
# It is a bit less efficient but easier to debug in case one "rm -rf" command
# fails.
for item in "${REMOVE_LIST[@]}"; do
    rm -rf "${item}" \
        || sdk_die "Could not succeed in removing forcibly the following item: ${item#${root}}"
done

# vim: set ts=4 sts=4 sw=4 et ft=sh:
