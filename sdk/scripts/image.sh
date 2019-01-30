#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Meta-script for the targets "image" step:

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

if [[ "${#@}" -eq 0 ]]; then
    eerror "No packages to emerge (no arguments given)."
    exit 1
fi

# Needed to get EMERGE_IMAGEROOTONLYRDEPS_OPTS:
source "${CURRENT_SDK}/scripts/emergeopts.sh"

# This current meta-script works only on a detached root tree.
# Emerge, qlist and other Portage script will read this environment variable
# and will work in this ROOT tree.
export ROOT="${CURRENT_OUT_ROOT}"

# All imaging process must begin with a clean empty root tree:
rm -rf "${ROOT}"

einfo "Extracting from binpkgs the baselayout in ROOT:"
emerge ${EMERGE_IMAGEROOTONLYRDEPS_OPTS} sys-apps/baselayout

einfo "Extracting from binpkgs all the package to emerge in ROOT:"
emerge ${EMERGE_IMAGEROOTONLYRDEPS_OPTS} "$@"

# Extract the detailed list of installed packages in ROOT
qlist -IvSSRUC > "${CURRENT_CACHE}/root.packages"

# Save expanded profile config
emerge --info > "${CURRENT_CACHE}/emerge.info"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
