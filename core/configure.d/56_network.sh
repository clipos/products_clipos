#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

einfo "Setup RW state folder for systemd-networkd config"
rm -rfv "${CURRENT_OUT_ROOT}/etc/systemd/network"
ln -s "/mnt/state/core/etc/systemd/network" "${CURRENT_OUT_ROOT}/etc/systemd/network"

einfo "Enable systemd-networkd by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable systemd-networkd

# vim: set ts=4 sts=4 sw=4 et ft=sh:
