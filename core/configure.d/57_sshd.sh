#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

sdk_info "Enable sshd by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable sshd

# Setup symlinks for RW host key dir in state partition
ln -sf "/mnt/state/core/etc/ssh/host_keys" "${CURRENT_OUT_ROOT}/etc/ssh/host_keys"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
