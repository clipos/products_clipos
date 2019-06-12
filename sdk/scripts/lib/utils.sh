# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Check the presence of the dependency programs in PATH.
# Returns the number of missing dependencies.
check_deps() {
    local deps=("${@?check_deps <dependency>...}")

    local dep depfailed=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            depfailed+=("$dep")
        fi
    done

    local nbdepfailed="${#depfailed[@]}"
    if [[ "$nbdepfailed" -gt 0 ]]; then
        echo "$nbdepfailed dependencies missing in PATH: ${depfailed[@]}" >&2
    fi
    return "$nbdepfailed"
}

# Deserialize the environment variables CURRENT_PRODUCT_PROPERTIES and
# CURRENT_PRODUCT_PROPERTY_<INDEX> into a product properties associative array
# in order to access product properties seamlessly with Bash (this requires
# Bash 4.2 at least, which shall be the case on the CLIP OS SDKs):
_define_current_product_property_associative_array() {
    declare -gA CURRENT_PRODUCT_PROPERTY  # -g = global scope (Bash 4.2+)
    local key val_varname i=0
    for key in ${CURRENT_PRODUCT_PROPERTIES:-}; do
        val_varname="CURRENT_PRODUCT_PROPERTY_${i}"
        CURRENT_PRODUCT_PROPERTY["${key}"]="${!val_varname:?missing product property}"
        let i++ || true
    done
    readonly CURRENT_PRODUCT_PROPERTY  # both array, keys and values as RO
}


# Replace placeholders (in the form "@VARIABLE_NAME@" where "VARIABLE_NAME" is
# the name of an exported environment variable) in a given file. This
# replacement is "virtually" made in-place.
# NB: variables names must verify this regexp '^[a-zA-Z\_][a-zA-Z0-9\_]*$'
# (POSIX environment variable names format).
replace_placeholders() {
    local file="${1:?replace_placeholders <file>}"
    [[ -r "$file" && -w "$file" ]] || return 1

    local tempfile
    tempfile="$(mktemp --tmpdir 'replace_placeholders.XXXXX')" || return 2

    gawk '
        {
            delete res
            while(match($0, /@([a-zA-Z\_][a-zA-Z0-9\_]*)@/, res)) {
                placeholder = res[0]
                varname = res[1]
                if (! (varname in ENVIRON)) {
                    print "\""varname"\" has not been found in the environment variables." > "/dev/stderr"
                    exit 1
                }
                value = ENVIRON[varname]
                gsub(placeholder, value)
            }
            print
        }' "$file" >| "$tempfile" \
            || { rm -f "$tempfile"; return 3; }

    cat "$tempfile" >| "$file" || { rm -f "$tempfile"; return 4; }
    rm -f "$tempfile"
}

am_i_running_in_a_sdk() {
    [[ -f /.sdk ]]
}

die_if_not_in_a_sdk() {
    if ! am_i_running_in_a_sdk; then
        echo >&2 "I am not running inside a SDK container."
        exit 1
    fi
}

contains() {
    local elt="${1:?contains() requires an element to search as first arg}"
    shift
    local x
    for x in "$@"; do
        if [[ "$x" = "$elt" ]]; then
            return 0
        fi
    done
    return 1
}

is_instrumentation_feature_enabled() {
    contains "${1:?missing or empty feature requested}" ${CURRENT_INSTRUMENTATION_FEATURES:-}
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
