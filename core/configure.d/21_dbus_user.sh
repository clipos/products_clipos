#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Install sysuser config for dbus user"
echo "u messagebus 81 \"System Message Bus\"" | tee > /dev/null \
    "/usr/lib/sysusers.d/dbus.conf" \
    "${CURRENT_OUT_ROOT}/usr/lib/sysusers.d/dbus.conf"

einfo "Setup dbus user for the SDK."
systemd-sysusers dbus.conf

einfo "Setup dbus user for the final root."
systemd-sysusers --root="${CURRENT_OUT_ROOT}" dbus.conf

# vim: set ts=4 sts=4 sw=4 et ft=sh:
