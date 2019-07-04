#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

sdk_info "Enable strongswan by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable strongswan

# Setup symlinks in core state partition
readonly items_to_symlink_into_core_state=(
    # The main swanctl configuration file (/etc/swanctl/swanctl.conf) does not
    # define anything but includes all the files in the "conf.d" directory.
    # Therefore it is up to the installer to install the connection definitions
    # in this directory symlinked in the core state partition.
    /etc/swanctl/conf.d

    # Storage paths to X.509 certificates and private keys
    /etc/swanctl/x509
    /etc/swanctl/x509ca
    /etc/swanctl/private
)
for item in "${items_to_symlink_into_core_state[@]}"; do
    if [[ ! -e "${CURRENT_OUT_ROOT}/${item}" ]]; then
        sdk_die "Could not find \"${item}\" in Core stateless partition."
    fi

    sdk_info "Symlinking to Core state partition: ${item}"
    # Warning: Before creating the symlink, make sure that the target node
    # (i.e. the second argument of the following "ln" command) does not
    # preexist. This precaution is explained by the fact that even with the use
    # of the "-f" option, "ln" command may have an unexpected behavior if the
    # preexisting item happens to be a directory (it will create the symlink
    # inside that directory rather than deleting it).
    rm -rf "${CURRENT_OUT_ROOT}/${item}"
    ln -sn "/mnt/state/core/${item#/}" "${CURRENT_OUT_ROOT}/${item}"
done
unset item

# vim: set ts=4 sts=4 sw=4 et ft=sh:
