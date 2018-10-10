#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# called by dracut
depends() {
    # We depend on device-mapper:
    echo dm
}

# called by dracut
install() {
    inst_hook pre-pivot 90 "$moddir/mount-core-state.sh"
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
