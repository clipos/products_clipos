#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Refuse to boot if state partition is not properly initialized

main() {
    readonly state_mountpoint="/sysroot/mnt/state"

    readonly checked_dirs=(
        "core"
        "core/etc"
        "core/etc/modules-load.d"
        "core/var"
        "core/var/log"
        "core/var/log/journal"
    )

    readonly checked_files=(
        ".setup-done"
        "core/etc/hostname"
        "core/etc/machine-id"
    )

    readonly checked_symlink=(
        "core/etc/firmware"
        "core/etc/modules-load.d/hardware.conf"
    )

    info "Verifying Core state partition content..."

    for item in "${checked_dirs[@]}"; do
        curr="${state_mountpoint}/${item}"
        info "Looking for directory: ${curr}"
        if [[ ! -d "${curr}" ]]; then
            warn "Could not find directory: ${curr}"
            fail_boot
        fi
    done

    for item in "${checked_files[@]}"; do
        curr="${state_mountpoint}/${item}"
        info "Looking for file: ${curr}"
        if [[ ! -f "${curr}" ]]; then
            warn "Could not find file: ${curr}"
            fail_boot
        fi
    done

    for item in "${checked_symlink[@]}"; do
        curr="${state_mountpoint}/${item}"
        info "Looking for symlink: ${curr}"
        if [[ ! -L "${curr}" ]]; then
            warn "Could not find symlink: ${curr}"
            fail_boot
        fi
    done

    info "Verifying Core state partition content: OK"
}

info() {
    echo "$@" >&1
}

warn() {
    echo "$@" >&2
}

fail_boot() {
    warn "Denying further system bootup"

    systemctl --no-block isolate boot-failed.target
    exit 1
}

main
