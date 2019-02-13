#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

# Set empty root password only for instrumented builds:
if [[ "${CURRENT_RECIPE_INSTRUMENTATION_LEVEL}" -ge 1 ]]; then
    einfo "INSTRUMENTED BUILD: Setting empty root password."
    sed -i 's|root:x:0:0:Super User:/root:/bin/sh|root:x:0:0:Super User:/:/bin/bash|' \
        "${CURRENT_OUT_ROOT}/etc/passwd"
    sed -i 's|root:!!:|root::|' \
        "${CURRENT_OUT_ROOT}/etc/shadow"
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
