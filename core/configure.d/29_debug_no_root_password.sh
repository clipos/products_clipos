#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}/prelude.sh

# Set empty root password only for instrumented builds:
if is_instrumentation_feature_enabled "passwordless-root-login"; then
    sdk_info "INSTRUMENTED BUILD: Setting empty root password."

    # Note: This requires GNU Awk >= 4.1.0 for the inplace extension.
    gawk -i inplace 'BEGIN { FS = OFS = ":"; processed=0; }
    {
        if ($1 == "root" && $3 == 0 && $4 == 0) {   # 1=username 3=UID 4=GID
            $7 = "/bin/bash";   # 7=login-shell
            processed=1;
        }
        print;
    }
    END { exit(!processed); }' "${CURRENT_OUT_ROOT}/etc/passwd" \
        || sdk_die "INSTRUMENTED BUILD: Error while trying to set /bin/bash as the login shell for root in /etc/passwd."

    # Note: This requires GNU Awk >= 4.1.0 for the inplace extension.
    gawk -i inplace 'BEGIN { FS = OFS = ":"; processed=0; }
    {
        if ($1 == "root") {   # 1=username
            $2 = "";   # 2=password
            processed=1;
        }
        print;
    }
    END { exit(!processed); }' "${CURRENT_OUT_ROOT}/etc/shadow" \
        || sdk_die "INSTRUMENTED BUILD: Error while trying to set an empty password for root in /etc/shadow."
fi

# vim: set ts=4 sts=4 sw=4 et ft=sh:
