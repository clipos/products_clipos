#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

# Development & debug script for iterative single package rebuild

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

if [[ "$#" -eq 0 ]]; then
    sdk_error "No packages to emerge (no arguments given)."
    exit 1
fi

# We can not use the options from emergeopts.sh as they do not apply here.
emerge_devel_optarray=(
    --buildpkg=y
    --usepkg=y
    --binpkg-changed-deps=y
    --binpkg-respect-use=y
    --rebuilt-binaries
)

# This current meta-script works only on a detached root tree.
# Emerge, qlist and other Portage script will read this environment variable
# and will work in this ROOT tree.
export ROOT="${CURRENT_OUT_ROOT}"

# Minimal check to ensure that sys-apps/baselayout has been merged.
if [[ ! -d "${ROOT?}/usr" ]]; then
    sdk_info "Building baselayout in ROOT:"
    emerge "${emerge_devel_optarray[@]}" sys-apps/baselayout
fi

# Mark current root as unclean to avoid mistakes.
touch "${ROOT}/.unclean"

# Systematically remove previously built binary packages for atoms given as
# arguments
for pkg in "$@"; do
    # Is this a full atom name or just the package name?
    if [[ "${pkg}" =~ ^[^/]+/[^/]+$ ]]; then
        rm -fv "${CURRENT_CACHE_PKG}/${pkg}"*
    else
        find "${CURRENT_CACHE_PKG}" -type f -name "*${pkg}*.tbz2" -exec rm -fv {} \;
    fi
done

sdk_info "Building the packages to emerge in ROOT:"
emerge "${emerge_devel_optarray[@]}" "$@"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
