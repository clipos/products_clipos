#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2017-2018 ANSSI
# All rights reserved

# called by dracut
check() {
    # If our prerequisites are not met, fail anyways.
    require_binaries veritysetup || return 1
    return 0
}

# called by dracut
depends() {
    # We depend on device-mapper:
    echo dm
}

# called by dracut
installkernel() {
    instmods dm_verity dm_bufio dm_mod
}

# called by dracut
install() {
    inst veritysetup systemd-escape sed tr head bash

    inst_simple "$moddir/verity-generator.sh" \
        "$systemdutildir/system-generators/verity-generator"

    #inst_hook cmdline 90 "$moddir/parse-verity.sh"
    #inst_hook initqueue/settled 90 "$moddir/open-verity.sh"
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
