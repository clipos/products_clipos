#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# called by dracut
install() {
    inst_hook pre-pivot 99 "$moddir/clipos-check-state.sh"
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
