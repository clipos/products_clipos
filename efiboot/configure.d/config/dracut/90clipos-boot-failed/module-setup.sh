#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# called by dracut
install() {
    inst "$moddir/boot-failed.service" "/etc/systemd/system/boot-failed.service"
    inst "$moddir/boot-failed.target" "/etc/systemd/system/boot-failed.target"
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
