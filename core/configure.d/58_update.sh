#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

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

# Require IPsec for updates
install -o 0 -g 0 -m 755 -d "${CURRENT_OUT_ROOT}/etc/systemd/system/updater.service.d"
install -o 0 -g 0 -m 0644 \
    "${CURRENT_RECIPE}/configure.d/config/ipsec0.conf" \
    "${CURRENT_OUT_ROOT}/etc/systemd/system/updater.service.d/ipsec0.conf"

# Install host entry & test publickey only when testing updates
if is_instrumentation_feature_enabled "test-update"; then
    cat <<EOF > "${CURRENT_OUT_ROOT}/usr/lib/updater/pubkey"
untrusted comment: minisign public key: 70D830FF14CDFCC9
RWTJ/M0U/zDYcGXzF2FC3fsz/PgZUs3PFI4Co3Ul/2udRk6PCde+B++S
EOF
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
