#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

sdk_info "Setup RW state folder for systemd-networkd config"
rm -rfv "${CURRENT_OUT_ROOT}/etc/systemd/network"
ln -s "/mnt/state/core/etc/systemd/network" "${CURRENT_OUT_ROOT}/etc/systemd/network"

# Create a symlink to stateful partition for resolv.conf, otherwise the DHCP
# client won't be able to create such a file in /etc (which is read-only).
ln -s "/mnt/state/core/etc/resolv.conf" "${CURRENT_OUT_ROOT}/etc/resolv.conf"

sdk_info "Enable systemd-networkd by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable systemd-networkd

# Install our own nftables.service
install -o 0 -g 0 -m 0644 \
    "${CURRENT_RECIPE}/configure.d/config/nftables.service" \
    "${CURRENT_OUT_ROOT}/lib/systemd/system/nftables.service"

sdk_info "Enable nftables-based firewall by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable nftables

# vim: set ts=4 sts=4 sw=4 et ft=sh:
