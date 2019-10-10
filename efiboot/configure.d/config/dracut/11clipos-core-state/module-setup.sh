#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

TPM2_TOOLS_DLOPEN="libtss2-tcti-device.so*"
TPM2_TOOLS_BINARIES="tpm2_startup tpm2_clear tpm2_createpolicy tpm2_createprimary"
TPM2_TOOLS_BINARIES+=" tpm2_create tpm2_load tpm2_unseal tpm2_pcrread"

# called by dracut
check() {
    require_binaries cryptsetup $TPM2_TOOLS_BINARIES || return 1
}

# called by dracut
depends() {
    # We depend on device-mapper:
    echo dm
}

# called by dracut
install() {
    inst_multiple cryptsetup rmdir readlink umount dd $TPM2_TOOLS_BINARIES
    inst_simple "${tmpfilesdir}/cryptsetup.conf"
    inst_hook pre-pivot 90 "$moddir/mount-core-state.sh"

    # dracut cannot resolve "dlopen deps" automatically
    inst_libdir_file ${TPM2_TOOLS_DLOPEN}
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
