#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Setup Core users"

# DBus user
cat <<EOF >> /usr/lib/sysusers.d/clipos-core.conf
u messagebus 81              "System Message Bus"
EOF

# Install sysuser config for the SDK & the final root
cp {,"${CURRENT_OUT_ROOT}"}/usr/lib/sysusers.d/clipos-core.conf

# Setup for the SDK & the final root
systemd-sysusers clipos-core.conf
systemd-sysusers --root="${CURRENT_OUT_ROOT}" clipos-core.conf

# vim: set ts=4 sts=4 sw=4 et ft=sh:
