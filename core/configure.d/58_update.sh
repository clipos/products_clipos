#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

sdk_info "Enable updater timer by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable updater.timer

# Remote configuration is stored in the state partition to allow changes by
# admin users
ln -snf "/mnt/state/core/etc/updater" "${CURRENT_OUT_ROOT}/etc/updater"

# System configuration is stored in the RO / partition
sdk_info "Install static system configuration"

cat <<EOF > "${CURRENT_OUT_ROOT}/usr/lib/updater/config.toml"
os_name = "clipos"

[core]
destination = "mainvg"
size = "4G"

[efiboot]
destination = "/mnt/efiboot/EFI/Linux"
EOF

# Install host entry & test publickey only when testing updates
if is_instrumentation_feature_enabled "test-update"; then

    cat <<EOF > "${CURRENT_OUT_ROOT}/usr/lib/updater/pubkey"
untrusted comment: minisign public key: 70D830FF14CDFCC9
RWTJ/M0U/zDYcGXzF2FC3fsz/PgZUs3PFI4Co3Ul/2udRk6PCde+B++S
EOF

    cat <<EOF >> "${CURRENT_OUT_ROOT}/etc/hosts"
172.27.1.10  update.clip-os.org
EOF
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
