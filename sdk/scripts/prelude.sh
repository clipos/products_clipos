# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# The prelude to be called at the beginning of every Bash script of this SDK.
# This prelude ensure to be run in a SDK container (thanks to the function
# die_if_not_in_a_sdk) and imports all the commons variables and functions
# usable everywhere in the scripts of this SDK.

# Safety check with explicit error messages:
if [ -z "${BASH:-}" ]; then
    echo >&2 "This file is intended to be used by Bash scripts only."
    exit 1
elif ! [[ "${BASH_VERSINFO[0]}" -ge 4 && "${BASH_VERSINFO[1]}" -ge 2 ]]; then
    echo >&2 "This file is intended to be used with Bash 4.2 at least."
    exit 1
fi

# Important: /etc/profile MUST be sourced manually because all the really
# sensitive environment variables are set in it. Their absence can lead to
# strange issues during Portage builds.
source /etc/profile

# Tip: ${BASH_SOURCE[0]} is a Bash special variable (an array to be exact)
# returning the path of the current script.
source "$(dirname ${BASH_SOURCE[0]})/lib/logging.sh"
source "$(dirname ${BASH_SOURCE[0]})/lib/utils.sh"

# Ensure we are in a CLIP core SDK container (to avoid potential disaster if
# ever run in the host):
die_if_not_in_a_sdk

# Compute useful global variables to be used across various scripts used within
# this SDK:

# Output directory for the current recipe/action. Always available read-write.
readonly CURRENT_OUT="/mnt/out/${CURRENT_PRODUCT}/${CURRENT_PRODUCT_VERSION}/${CURRENT_RECIPE}/${CURRENT_ACTION}"
export CURRENT_OUT

# Shortcut for frequently used root subdirectory
readonly CURRENT_OUT_ROOT="${CURRENT_OUT}/root"
export CURRENT_OUT_ROOT

# Cache directory for the current recipe/action. Always available read-write.
readonly CURRENT_CACHE="/mnt/cache/${CURRENT_PRODUCT}/${CURRENT_PRODUCT_VERSION}/${CURRENT_RECIPE}/${CURRENT_ACTION}"
export CURRENT_CACHE

# Cache directory for packages for the current recipe. Available read-write
# only during the build action.
readonly CURRENT_CACHE_PKG="/mnt/cache/${CURRENT_PRODUCT}/${CURRENT_PRODUCT_VERSION}/${CURRENT_RECIPE}/binpkgs"
export CURRENT_CACHE_PKG

# This requires Bash 4 at least and defines the associative array
# CURRENT_PRODUCT_PROPERTY which holds all the current product properties
# associating keys and their values:
_define_current_product_property_associative_array

# vim: set ts=4 sts=4 sw=4 et ft=sh:
