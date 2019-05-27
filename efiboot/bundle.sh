#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Prepare the EFI partition layout
sdk_info "Prepare the EFI partition layout..."

mkdir -p "${CURRENT_OUT_ROOT}/EFI/BOOT"
mkdir -p "${CURRENT_OUT_ROOT}/EFI/Linux"
mkdir -p "${CURRENT_OUT_ROOT}/loader"

sdk_info "Install systemd-boot as primary EFI bootloader..."
cp "${CURRENT_OUT}/../configure/systemd-bootx64.efi" \
    "${CURRENT_OUT_ROOT}/EFI/BOOT/BOOTX64.EFI"

if is_instrumentation_feature_enabled "dev-friendly-bootloader"; then
    # Reduce bootloader timeout not to annoy developers who do several reboots
    # when experimenting boot up features:
    BOOTLOADER_TIMEOUT=2
    AUTO_FIRMWARE=1
else
    BOOTLOADER_TIMEOUT=6
    AUTO_FIRMWARE=0
fi

sdk_info "Install systemd-boot main configuration..."
cat <<EOF > "${CURRENT_OUT_ROOT}/loader/loader.conf"
editor 0
auto-firmware $AUTO_FIRMWARE
timeout ${BOOTLOADER_TIMEOUT}
EOF

sdk_info "Install EFI bundle..."
cp "${CURRENT_OUT}/../configure/linux.efi" \
    "${CURRENT_OUT_ROOT}/EFI/Linux/clipos-${CURRENT_PRODUCT_VERSION}.efi"

sdk_info "Bundle the EFI binaries into an EFI partition archive..."
# Produce the EFI partition image as a tar archive.
# Note: we deliberately do not preserve permissions and other advanced
# filesystem features (such as extended attributes or sparse block information)
# since the EFI partition type is FAT32 and does not handle any of this.
tar --create \
    --file "${CURRENT_OUT}/efipartition.tar" \
    --directory "${CURRENT_OUT_ROOT}" \
    .

# vim: set ts=4 sts=4 sw=4 et ft=sh:
