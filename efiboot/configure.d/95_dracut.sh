#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Copy kernel compiled in core recipe
CORE_CONFIGURE="${CURRENT_OUT_ROOT}/../../../core/configure"
cp -aT "${CORE_CONFIGURE}/boot" "${CURRENT_OUT_ROOT}/boot"

# Identify the kernel version string installed in this root tree to (otherwise
# dracut will try to find out the kernel version by using uname(1) and may use
# the kernel version string of the SDK host):
kernel_version=
# clipos-kernel ebuild makes a link to the vmlinuz binary suffixed with the
# kernel version string:
vmlinuz_link="$(readlink -f "${CURRENT_OUT_ROOT}/boot/vmlinuz")"
vmlinuz_link="${vmlinuz_link##*/}"
kernel_version="${vmlinuz_link#vmlinuz-}"
if [[ -z "${kernel_version}" ]]; then
    sdk_error "Could not identify the kernel version string."
    exit 1
fi

# Retrieve core root-hash and the hash offset in the partition image bundling
# both squashfs and dm-verity metadata:
core_bundle_dir="${CURRENT_OUT}/../../core/bundle"
core_verity_roothash="$(< "${core_bundle_dir}/core.squashfs.verity.roothash")"
core_verity_hashoffset="$(< "${core_bundle_dir}/core.squashfs.verity.bundled.hashoffset")"
core_verity_fecoffset="$(< "${core_bundle_dir}/core.squashfs.verity.bundled.fecoffset")"

readonly vg_name="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"
readonly core_lv_name="core_${CURRENT_PRODUCT_VERSION}"
# The kernel command line to be embedded into the EFI-stubbed kernel
kernel_cmdline="root=/dev/mapper/verity_${core_lv_name} rootfstype=squashfs rootflags=ro"
kernel_cmdline+=" rd.lvm.vg=${vg_name}"
# DM-Verity options
kernel_cmdline+=" rd.verity.device=/dev/${vg_name}/${core_lv_name}"
kernel_cmdline+=" rd.verity.name=verity_${core_lv_name}"
kernel_cmdline+=" rd.verity.roothash=${core_verity_roothash}"
kernel_cmdline+=" rd.verity.hashoffset=${core_verity_hashoffset}"
kernel_cmdline+=" rd.verity.fecoffset=${core_verity_fecoffset}"
# Security-related parameters
kernel_cmdline+=" slub_debug=F extra_latent_entropy iommu=force"
kernel_cmdline+=" pti=on mds=full,nosmt"
kernel_cmdline+=" spectre_v2=on spec_store_bypass_disable=seccomp"
# Consider uncommenting below line if CLIP OS happens to be used as an
# hypervisor with untrusted guest VMs someday
#kernel_cmdline+=" l1tf=full,force"

# Development and debug options are disabled by default
if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 2 ]]; then
    kernel_cmdline+=" rd.retry=10 rd.timeout=15 "  # Smaller timeout in VMs
    # Debug shells at various dracut hook stages
    kernel_cmdline+=" rd.shell rd.break=pre-mount"
    kernel_cmdline+=" rd.shell rd.break=mount"
    kernel_cmdline+=" rd.shell rd.break=pre-pivot"
    kernel_cmdline+=" rd.shell rd.break=cleanup"
    # Persistent runtime debug shell
    kernel_cmdline+=" systemd.debug-shell=1"
    kernel_cmdline+=" console=ttyS0,115200"
fi
if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
    # Do not ratelimit the logging
    kernel_cmdline+=" printk.devkmsg=on"
fi

# Heavy debug options disabled by default
# kernel_cmdline="${kernel_cmdline} systemd.log_level=debug systemd.log_target=console systemd.journald.forward_to_console=1 console=ttyS0,38400 console=tty1"

# dracut appends the machine-id to the resulting EFI-stubbed kernel image and
# we do not want this
rm -f "${CURRENT_OUT_ROOT:?}/etc/machine-id"

# Sadly enough, dracut does not provide an option to be able to work with
# objects (kernel, binaries, environment) from a detached root tree.
# For this reason, we are going to rely on a chroot(1) call into
# CURRENT_OUT_ROOT. :(
sdk_info "Launch dracut to produce an initramfs+EFI-stubbed kernel..."
env -i chroot "${CURRENT_OUT_ROOT}" \
    /bin/bash -l -c 'exec "$0" "$@"' \
        dracut --kver "${kernel_version}" \
        --reproducible --force \
        --uefi --uefi-stub /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
        --kernel-cmdline "${kernel_cmdline}" --no-kernel
# Note for the "bash -lc 'exec ...'" quirk above:
# This trick is to ensure that we won't inherit anything from the environment
# of the SDK but only from the CURRENT_OUT_ROOT (the bash -l option will source
# /etc/profile for that root tree).

# Extract the EFI binary produced above from the root tree and drop it in a
# predictive path for the next step:
cp "${CURRENT_OUT_ROOT}/boot/EFI/Linux/linux-${kernel_version}.efi" \
    "${CURRENT_OUT}/linux.efi"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
