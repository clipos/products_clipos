#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

# Remove all the SETUID bit to the concerned nodes:
setuid_enabled_nodes=() i=0
while IFS= read -r -d $'\0' item; do
    setuid_enabled_nodes[i++]="${item}"
done < <(find "${CURRENT_OUT_ROOT}" -perm -4000 -print0)
unset i

if [[ "${#setuid_enabled_nodes[@]}" -eq 0 ]]; then
    sdk_info "No node in ROOT has a SETUID bit. No SETUID bit to remove then. :)"
else
    msg="Removing the SETUID bit in ROOT for the following nodes:"
    for item in "${setuid_enabled_nodes[@]}"; do
        msg+=$'\n'"  $(stat -c '%A  %u:%g' "${item}")  ${item#${CURRENT_OUT_ROOT}}"
    done
    sdk_warn "$msg"
    unset msg
    for item in "${setuid_enabled_nodes[@]}"; do
        chmod u-s "${item}" \
            || sdk_die "Could not succeed in removing SETUID bit on item: ${item#${CURRENT_OUT_ROOT}}"
    done
    sdk_success "SETUID bit successfully removed for all the nodes listed above."
fi


# Make a listing of all the Sticky-bit enabled node in ROOT:
stickybit_enabled_nodes=() i=0
while IFS= read -r -d $'\0' item; do
    stickybit_enabled_nodes[i++]="${item}"
done < <(find "${CURRENT_OUT_ROOT}" -perm -1000 -print0)
unset i

if [[ "${#stickybit_enabled_nodes[@]}" -eq 0 ]]; then
    sdk_info "No node in ROOT has a sticky bit."
else
    msg="Here is the list of the nodes in ROOT with a sticky bit:"
    for item in "${stickybit_enabled_nodes[@]}"; do
        msg+=$'\n'"  $(stat -c '%A  %u:%g' "${item}")  ${item#${CURRENT_OUT_ROOT}}"
    done
    sdk_warn "$msg"
    unset msg
fi


# Make a listing of all the Sticky-bit enabled node in ROOT:
setgid_enabled_nodes=() i=0
while IFS= read -r -d $'\0' item; do
    setgid_enabled_nodes[i++]="${item}"
done < <(find "${CURRENT_OUT_ROOT}" -perm -2000 -print0)
unset i

if [[ "${#setgid_enabled_nodes[@]}" -eq 0 ]]; then
    sdk_info "No node is ROOT has a SETGID bit."
else
    msg="Here is the list of the nodes in ROOT with a SETGID bit:"
    for item in "${setgid_enabled_nodes[@]}"; do
        msg+=$'\n'"  $(stat -c '%A  %u:%g' "${item}")  ${item#${CURRENT_OUT_ROOT}}"
    done
    sdk_warn "$msg"
    unset msg
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
