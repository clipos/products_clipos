#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

LOCALE="${CURRENT_PRODUCT_PROPERTY['system.locale']}"
TIMEZONE="${CURRENT_PRODUCT_PROPERTY['system.timezone']}"
KEYMAP="${CURRENT_PRODUCT_PROPERTY['system.keymap']}"

sdk_info "Create default required files in /etc"
systemd-tmpfiles \
    --root="${CURRENT_OUT_ROOT}" \
    --create \
    --prefix="/etc" \

install -dm 0755 -o 0 -g 0 "${CURRENT_OUT_ROOT}/etc/tmpfiles.d"

sdk_info "Set locale, keymap and timezone"
systemd-firstboot \
    --root="${CURRENT_OUT_ROOT}" \
    --locale="${LOCALE}" \
    --keymap="${KEYMAP}" \
    --timezone="${TIMEZONE}"

# Add some basic devices to the root tree for the chroot call
rm -rf "${CURRENT_OUT_ROOT}/dev"
install -m 755 -o 0 -g 0 -d "${CURRENT_OUT_ROOT}/dev"
mknod -m 666 "${CURRENT_OUT_ROOT}/dev/null" c 1 3

sdk_info "Setup locale"
echo "${LOCALE} UTF-8" > "${CURRENT_OUT_ROOT}/etc/locale.gen"
chroot "${CURRENT_OUT_ROOT}" /usr/sbin/locale-gen

# Cleanup
rm -rf "${CURRENT_OUT_ROOT}/dev"
install -m 755 -o 0 -g 0 -d "${CURRENT_OUT_ROOT}/dev"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
