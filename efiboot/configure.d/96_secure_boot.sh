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

sign_efi_binary() {
    # The binary to sign
    local src="${1}"
    local name="$(basename ${src})"

    # Move the binary to be signed to a predefined location
    mv "${src}" "${CURRENT_OUT_ROOT}/secure_boot"

    # See comments in "./95_dracut.sh" for below env and bash tricks
    sdk_info "Sign '${name}' EFI binary..."
    env -i chroot "${CURRENT_OUT_ROOT}" \
        /bin/bash -l -c 'exec "$0" "$@"' \
            sbsign --key /secure_boot/DB.key \
                   --cert /secure_boot/DB.crt \
                   /secure_boot/${name}

    # Move the signed binary to a predictable location for the next step
    mv "${CURRENT_OUT_ROOT}/secure_boot/${name}.signed" "${CURRENT_OUT}/${name}"
}

# Sign bootloader
sign_efi_binary "${CURRENT_OUT_ROOT}/usr/lib/systemd/boot/efi/systemd-bootx64.efi"

# Sign EFI bundle binary
sign_efi_binary "${CURRENT_OUT}/linux.efi"

# Special case to sign a second EFI binary to test updates
if is_instrumentation_feature_enabled "test-update"; then
    sign_efi_binary "${CURRENT_OUT}/linux.next.efi"
fi

# Copy:
#   * the OVMF code compiled with Secure Boot and TPM 2.0 support
#   * the OVMF vars with dummy keys enrolled
# to a predictable path for the next step
cp  "${CURRENT_OUT_ROOT}/usr/share/edk2-ovmf/OVMF_CODE.fd" \
    "${CURRENT_OUT}/OVMF_CODE_sb-tpm.fd"

cp  "${sb_keys_path}"/OVMF_VARS.fd \
    "${CURRENT_OUT}/OVMF_VARS-secure-boot.fd"
