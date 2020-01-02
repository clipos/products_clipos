# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# The prelude to be called at the beginning of every Bash script of this SDK.
# This prelude ensure to be run in a SDK container (thanks to the function
# die_if_not_in_a_sdk) and imports all the commons variables and functions
# usable everywhere in the scripts of this SDK.

# Safety check with explicit error messages:
if [ -z "${BASH:-}" ]; then
    echo >&2 "This file is intended to be used by Bash scripts only."
    exit 1
elif [[ "${BASH_VERSINFO[0]}" -lt 5 ]]; then
    if ! [[ "${BASH_VERSINFO[0]}" -ge 4 && "${BASH_VERSINFO[1]}" -ge 2 ]]; then
        echo "${BASH_VERSINFO[0]} ${BASH_VERSINFO[1]}"
        echo >&2 "This file is intended to be used with Bash 4.2 at least."
        exit 1
    fi
fi

# Important: /etc/profile MUST be sourced manually because all the really
# sensitive environment variables are set in it. Their absence can lead to
# strange issues during Portage builds.
source /etc/profile

# Tip: ${BASH_SOURCE[0]} is a Bash special variable (an array to be exact)
# returning the path of the current script.
source "$(dirname ${BASH_SOURCE[0]})/lib/logging.sh"
source "$(dirname ${BASH_SOURCE[0]})/lib/utils.sh"

# Ensure we are in a CLIP OS Core SDK container (to avoid potential disaster if
# ever run in the host):
die_if_not_in_a_sdk

# Ensure that the following variables were properly set by cosmk in the SDK
# environment so that we don't have to check them anywhere is our scripts.
# We do not check if 'COSMK_INSTRUMENTATION_FEATURES' exists has it will not
# for production builds.
cosmk_env=(
    'COSMK_ACTION'
    'COSMK_PRODUCT'
    'COSMK_PRODUCT_TAINTED_VERSION'
    'COSMK_PRODUCT_VERSION'
    'COSMK_RECIPE'
    'COSMK_SDK_PRODUCT'
    'COSMK_SDK_RECIPE'
)
for v in "${cosmk_env[@]}"; do
    if [[ -z ${!v+x} ]]; then
        sdk_die "Environment variable '${v}' is not set!"
    fi
done
unset v cosmk_env

# Compute useful global variables to be used across various scripts used within
# this SDK:

# Output directory for the current recipe/action. Always available read-write.
readonly CURRENT_OUT="/mnt/out/${COSMK_PRODUCT}/${COSMK_PRODUCT_VERSION}/${COSMK_RECIPE}/${COSMK_ACTION}"
export CURRENT_OUT

# Shortcut for frequently used root subdirectory
readonly CURRENT_OUT_ROOT="${CURRENT_OUT}/root"
export CURRENT_OUT_ROOT

# Cache directory for the current recipe/action. Always available read-write.
readonly CURRENT_CACHE="/mnt/cache/${COSMK_PRODUCT}/${COSMK_PRODUCT_VERSION}/${COSMK_RECIPE}/${COSMK_ACTION}"
export CURRENT_CACHE

# Cache directory for packages for the current recipe. Available read-write
# only during the build action.
readonly CURRENT_CACHE_PKG="/mnt/cache/${COSMK_PRODUCT}/${COSMK_PRODUCT_VERSION}/${COSMK_RECIPE}/binpkgs"
export CURRENT_CACHE_PKG

# SDK directory for easy access to SDK scripts. Always available read-only.
readonly CURRENT_SDK="/mnt/products/${COSMK_SDK_PRODUCT}/${COSMK_SDK_RECIPE}"
export CURRENT_SDK

# Recipe directory for easy access to recipe scripts. Always available read-only.
readonly CURRENT_RECIPE="/mnt/products/${COSMK_PRODUCT}/${COSMK_RECIPE}"
export CURRENT_RECIPE

# vim: set ts=4 sts=4 sw=4 et ft=sh:
