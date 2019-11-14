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

# First, build the generic portion of the kernel command line

# Security-related parameters
kernel_cmdline="slub_debug=F extra_latent_entropy iommu=force"
kernel_cmdline+=" page_alloc.shuffle=1"
kernel_cmdline+=" pti=on mds=full,nosmt"
kernel_cmdline+=" spectre_v2=on spec_store_bypass_disable=seccomp"
kernel_cmdline+=" rng_core.default_quality=512"
# Consider uncommenting below line if CLIP OS happens to be used as an
# hypervisor with untrusted guest VMs someday
#kernel_cmdline+=" l1tf=full,force kvm.nx_huge_pages=force"

# Set small timeout for threshold values (in seconds) for the initramfs
# (dracut) to retry and abandon device discovery before proceeding with the
# rest of the sequence. This is set to ease debugging in VMs.
# TODO: Put these parameters under an instrumentation feature flag
kernel_cmdline+=" rd.retry=10 rd.timeout=15 "

# Sets up breakpoints at interesting dracut stages:
if is_instrumentation_feature_enabled "breakpointed-initramfs"; then
    # Debug shells at various dracut hook stages
    kernel_cmdline+=" rd.shell rd.break=pre-mount"
    kernel_cmdline+=" rd.shell rd.break=mount"
    kernel_cmdline+=" rd.shell rd.break=pre-pivot"
    kernel_cmdline+=" rd.shell rd.break=cleanup"
fi

# Persistent runtime debug shell as root (mainly to ease systemd startup
# debugging):
if is_instrumentation_feature_enabled "early-root-shell"; then
    kernel_cmdline+=" systemd.debug-shell=1"
fi

# Shows kernel log on console (serial line):
if is_instrumentation_feature_enabled "debuggable-kernel"; then
    kernel_cmdline+=" console=ttyS0,115200 earlyprintk=serial,ttyS0,115200"
fi

# Do not ratelimit the logging when kernel has a more tolerant configuration:
if is_instrumentation_feature_enabled "soften-kernel-configuration"; then
    kernel_cmdline+=" printk.devkmsg=on"
fi

# Verbose systemd:
if is_instrumentation_feature_enabled "verbose-systemd"; then
    kernel_cmdline+=" systemd.log_level=debug"
    kernel_cmdline+=" systemd.log_target=console"
    kernel_cmdline+=" systemd.journald.forward_to_console=1"

    # Make sure there is a "console=" parameter already set in the kernel
    # commandline. Otherwise, the above options won't be of great effect:
    if ! [[ "${kernel_cmdline}" =~ (^| )console= ]]; then
        kernel_cmdline+=" console=ttyS0,115200"
    fi
fi

# dracut appends the machine-id to the resulting EFI-stubbed kernel image and
# we do not want this
rm -f "${CURRENT_OUT_ROOT}/etc/machine-id"

# dracut needs /var/tmp to be available
mkdir -p "${CURRENT_OUT_ROOT}/var/tmp"

dracut_bundle_efi() {
    # The Core bundle to use
    local core_name="${1}"
    # The product version to use
    local version="${2}"
    # The final name for the bundle
    local dst="${3}"

    # Retrieve core root-hash and the hash offset in the partition image
    # bundling both squashfs and dm-verity metadata:
    core_bundle="${CURRENT_OUT}/../../core/bundle/${core_name}.squashfs.verity"
    core_verity_roothash="$(< "${core_bundle}.roothash")"
    core_verity_hashoffset="$(< "${core_bundle}.bundled.hashoffset")"
    core_verity_fecoffset="$(< "${core_bundle}.bundled.fecoffset")"

    local vg_name="${CURRENT_PRODUCT_PROPERTY['system.disk_layout.vg_name']}"
    local core_lv_name="core_${version}"
    # The kernel command line to be embedded into the EFI-stubbed kernel
    rootfs_cmdline="root=/dev/mapper/verity_${core_lv_name} rootfstype=squashfs rootflags=ro"
    rootfs_cmdline+=" rd.lvm.vg=${vg_name}"
    # DM-Verity options
    rootfs_cmdline+=" rd.verity.device=/dev/${vg_name}/${core_lv_name}"
    rootfs_cmdline+=" rd.verity.name=verity_${core_lv_name}"
    rootfs_cmdline+=" rd.verity.roothash=${core_verity_roothash}"
    rootfs_cmdline+=" rd.verity.hashoffset=${core_verity_hashoffset}"
    rootfs_cmdline+=" rd.verity.fecoffset=${core_verity_fecoffset}"

    # Sadly enough, dracut does not provide an option to be able to work with
    # objects (kernel, binaries, environment) from a detached root tree.  For
    # this reason, we are going to rely on a chroot(1) call into
    # CURRENT_OUT_ROOT. :(
    sdk_info "Launch dracut to produce an initramfs+EFI-stubbed kernel..."
    env -i chroot "${CURRENT_OUT_ROOT}" \
        /bin/bash -l -c 'exec "$0" "$@"' \
            dracut --kver "${kernel_version}" \
            --reproducible --force \
            --uefi --uefi-stub /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
            --kernel-cmdline "${rootfs_cmdline} ${kernel_cmdline}" --no-kernel
    # Note for the "bash -lc 'exec ...'" quirk above:
    # This trick is to ensure that we won't inherit anything from the
    # environment of the SDK but only from the CURRENT_OUT_ROOT (the bash -l
    # option will source /etc/profile for that root tree).

    # Extract the EFI binary produced above from the root tree and drop it in a
    # predictable path for the next step:
    cp "${CURRENT_OUT_ROOT}/boot/EFI/Linux/linux-${kernel_version}.efi" \
        "${CURRENT_OUT}/${dst}"
}

# Create a EFI bundle
dracut_bundle_efi "core" "${CURRENT_PRODUCT_VERSION}" "linux.efi"

# Special case to create a second bundle to test updates
if is_instrumentation_feature_enabled "test-update"; then

    # Increase the version number
    version=${CURRENT_PRODUCT_VERSION##*.}
    next_version=$((version+1))
    next_version=${CURRENT_PRODUCT_VERSION/%${version}/${next_version}}
    sed -i "s|${CURRENT_PRODUCT_VERSION}|${next_version}|g" "${CURRENT_OUT_ROOT}/etc/os-release"

    dracut_bundle_efi "core.next" "${next_version}" "linux.next.efi"
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
