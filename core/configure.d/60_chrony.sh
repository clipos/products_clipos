#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2020 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Enable chrony by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable chronyd

# Require IPsec for NTP traffic.
install -o 0 -g 0 -m 755 -d "${CURRENT_OUT_ROOT}/etc/systemd/system/chronyd.service.d"
install -o 0 -g 0 -m 0644 \
    "${CURRENT_RECIPE}/configure.d/config/ipsec0.conf" \
    "${CURRENT_OUT_ROOT}/etc/systemd/system/chronyd.service.d/ipsec0.conf"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
