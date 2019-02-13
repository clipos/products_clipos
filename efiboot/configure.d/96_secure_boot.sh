#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

sb_keys_path="/mnt/products/${CURRENT_PRODUCT}/${CURRENT_RECIPE}/configure.d/dummy_keys_secure_boot"

# Setup Secure Boot signing keys
mkdir -p "${CURRENT_OUT_ROOT}/secure_boot"
cp "${sb_keys_path}"/DB.{key,crt} "${CURRENT_OUT_ROOT}/secure_boot"

# Setup binaries to be signed
mv  "${CURRENT_OUT_ROOT}/usr/lib64/systemd/boot/efi/systemd-bootx64.efi" \
    "${CURRENT_OUT}/linux.efi" \
    "${CURRENT_OUT_ROOT}/secure_boot"

# See comments in "./95_dracut.sh" for below env and bash tricks
einfo "Sign dracut bundled EFI binary..."
env -i chroot "${CURRENT_OUT_ROOT}" \
    /bin/bash -l -c 'exec "$0" "$@"' \
        sbsign --key /secure_boot/DB.key \
               --cert /secure_boot/DB.crt \
               /secure_boot/linux.efi

einfo "Sign systemd-boot EFI binary..."
env -i chroot "${CURRENT_OUT_ROOT}" \
    /bin/bash -l -c 'exec "$0" "$@"' \
        sbsign --key /secure_boot/DB.key \
               --cert /secure_boot/DB.crt \
               /secure_boot/systemd-bootx64.efi

# Extract the signed EFI binaries produced above from the root tree and drop
# them in a predictive path for the next step (the bundle step):
mv  "${CURRENT_OUT_ROOT}/secure_boot/linux.efi.signed" \
    "${CURRENT_OUT}/linux.efi"
mv  "${CURRENT_OUT_ROOT}/secure_boot/systemd-bootx64.efi.signed" \
    "${CURRENT_OUT}/systemd-bootx64.efi"

# Same thing for the OVMF code compiled with Secure Boot and TPM 2.0 support
# and for OVMF vars with dummy keys enrolled
cp  "${CURRENT_OUT_ROOT}/usr/share/edk2-ovmf/OVMF_CODE.fd" \
    "${CURRENT_OUT}/OVMF_CODE_sb-tpm.fd"

cp  "${sb_keys_path}"/OVMF_VARS.fd \
    "${CURRENT_OUT}/OVMF_VARS-secure-boot.fd"
