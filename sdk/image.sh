#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Meta-script for the targets "image" step:

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

# Setup Portage profile and overlays
${CURRENT_SDK}/setup-portage.sh

if [[ -z "${COSMK_RECIPE_ENV_META_ATOM:+x}" ]]; then
    sdk_error "No meta packages selected to emerge (\$COSMK_RECIPE_ENV_META_ATOM)."
    exit 1
fi

# Needed to get EMERGE_IMAGEROOTONLYRDEPS_OPTS:
source "${CURRENT_SDK}/emergeopts.sh"

# This current meta-script works only on a detached root tree.
# Emerge, qlist and other Portage script will read this environment variable
# and will work in this ROOT tree.
export ROOT="${CURRENT_OUT_ROOT}"

# All imaging process must begin with a clean empty root tree:
rm -rf "${ROOT}"

# Setup EXIT trap to restore log ownership to root on successful and
# unsuccessful script exits.
restore_log_ownership() {
    chown -R "$(stat -c '%u' /mnt/assets):$(stat -c '%g' /mnt/assets)" \
        "${CURRENT_CACHE}/log"
}
trap restore_log_ownership EXIT

sdk_info "Emerging (using binpkgs only) baselayout in ROOT:"
emerge ${EMERGE_IMAGEROOTONLYRDEPS_OPTS} sys-apps/baselayout

sdk_info "Emerging (using binpkgs only) all the required packages in ROOT:"
emerge ${EMERGE_IMAGEROOTONLYRDEPS_OPTS} ${COSMK_RECIPE_ENV_META_ATOM}

# Extract the detailed list of installed packages in ROOT
qlist -IvSSRUC > "${CURRENT_CACHE}/root.packages"

# Save expanded profile config
emerge --info > "${CURRENT_CACHE}/emerge.info"

# vim: set ts=4 sts=4 sw=4 et ft=sh:
