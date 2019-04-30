#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

sdk_info "Setup Core users"

# DBus user
cat <<EOF >> /usr/lib/sysusers.d/clipos-core.conf
u messagebus 81              "System Message Bus"
EOF

# admin & audit users
cat <<EOF >> /usr/lib/sysusers.d/clipos-core.conf
u admin      800             "Admin user"                        /home/admin /bin/bash
u audit      801             "Audit user"                        /home/audit /bin/bash
m audit      systemd-journal
EOF

# OpenSSH privilege separation user
cat <<EOF >> /usr/lib/sysusers.d/clipos-core.conf
u sshd       22              "OpenSSH privilege separation user" /usr/lib/openssh/empty
EOF

# Install sysuser config for the SDK & the final root
cp {,"${CURRENT_OUT_ROOT}"}/usr/lib/sysusers.d/clipos-core.conf

# Setup for the SDK & the final root
systemd-sysusers clipos-core.conf
systemd-sysusers --root="${CURRENT_OUT_ROOT}" clipos-core.conf

# Setup symlinks for home dirs (admin & audit)
ln -snf "/mnt/state/core/home" "${CURRENT_OUT_ROOT}/home"

# Setup /root symlink for development & debug
if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
    ln -s "/mnt/state/core/home/root" "${CURRENT_OUT_ROOT}/root"
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
