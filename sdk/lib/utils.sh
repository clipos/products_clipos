# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

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
    contains "${1:?missing or empty feature requested}" ${COSMK_INSTRUMENTATION_FEATURES:-}
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
