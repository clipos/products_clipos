#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Setup Core users"

# DBus user
# WARNING: This overrides the package installed configuration in order to set
# a fixed UID for the messagebus user.
cat <<EOF > "${CURRENT_OUT_ROOT}/usr/lib/sysusers.d/dbus.conf"
u messagebus 81              "System Message Bus"
EOF

# admin & audit users
cat <<EOF >> "${CURRENT_OUT_ROOT}/usr/lib/sysusers.d/clipos-core.conf"
u admin      800             "Admin user"                        /home/admin /bin/bash
u audit      801             "Audit user"                        /home/audit /bin/bash
m audit      systemd-journal
EOF

# List of sysusers configuration files that will be taken into account to
# create users in this recipe.
sysusers_config=(
    "clipos-core"
    "dbus"
    "openssh"
    "strongswan"
)

for c in "${sysusers_config[@]}"; do
    # Copy the config from the rootfs to the SDK
    cp {"${CURRENT_OUT_ROOT}",}"/usr/lib/sysusers.d/${c}.conf"

    # Setup users for the SDK & the final root
    systemd-sysusers "${c}.conf"
    systemd-sysusers --root="${CURRENT_OUT_ROOT}" "${c}.conf"
done

# Setup symlinks for home dirs (admin & audit)
ln -snf "/mnt/state/core/home" "${CURRENT_OUT_ROOT}/home"

# Setup /root symlink for development & debug
if is_instrumentation_feature_enabled "passwordless-root-login"; then
    ln -s "/mnt/state/core/home/root" "${CURRENT_OUT_ROOT}/root"
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
