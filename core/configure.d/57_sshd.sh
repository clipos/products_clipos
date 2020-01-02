#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Enable sshd by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable sshd

# Setup symlinks for RW host key dir in state partition
ln -sf "/mnt/state/core/etc/ssh/host_keys" "${CURRENT_OUT_ROOT}/etc/ssh/host_keys"

# Require IPsec for SSH access
install -o 0 -g 0 -m 755 -d "${CURRENT_OUT_ROOT}/etc/systemd/system/sshd.service.d"
install -o 0 -g 0 -m 0644 \
    "${CURRENT_RECIPE}/configure.d/config/ipsec0.conf" \
    "${CURRENT_OUT_ROOT}/etc/systemd/system/sshd.service.d/ipsec0.conf"

# Disable SSH access over IPsec only restriction for development
if is_instrumentation_feature_enabled "allow-ssh-root-login"; then
    rm -fv "${CURRENT_OUT_ROOT}/etc/systemd/system/sshd.service.d/ipsec0.conf"
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
