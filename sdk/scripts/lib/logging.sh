# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

# Do not overwrite INDENTLEVEL if it already exists. We may inherit a value
# from the environment.
: "${INDENTLEVEL:=0}"

sdk_indent() {
    let INDENTLEVEL++ || true
}

sdk_outdent() {
    let INDENTLEVEL-- || true
}

_sdk_print_indentation() {
    printf "%$((INDENTLEVEL*4))s" ""
}


# Strips all the ANSI special "escape codes"
__sdk_strip_ansi_escape_codes() {
    # Source: http://www.commandlinefu.com/commands/view/3584
    sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

_sdk_prettify_output() {
    # Fancy colors for the terminal
    _INFO_PREFIX=$' \e[34;1m[*]\e[0m \e[1m'
    _WARN_PREFIX=$' \e[33;1m[!]\e[0m \e[1m'
    _ERROR_PREFIX=$' \e[31;1m[X]\e[0m \e[1m'
    _BEGIN_PREFIX=$' \e[36;1m[+]\e[0m \e[1m'
    _END_PREFIX=$' \e[32;1m[-]\e[0m \e[1m'
    _POSTFIX=$'\e[0m'

    # strip ANSI escape codes if the standard output is not a TTY
    if [[ ! -t 2 ]]; then
        _INFO_PREFIX="$(__sdk_strip_ansi_escape_codes <<< "$_INFO_PREFIX")"
        _WARN_PREFIX="$(__sdk_strip_ansi_escape_codes <<< "$_WARN_PREFIX")"
        _ERROR_PREFIX="$(__sdk_strip_ansi_escape_codes <<< "$_ERROR_PREFIX")"
        _BEGIN_PREFIX="$(__sdk_strip_ansi_escape_codes <<< "$_BEGIN_PREFIX")"
        _END_PREFIX="$(__sdk_strip_ansi_escape_codes <<< "$_END_PREFIX")"
        _POSTFIX="$(__sdk_strip_ansi_escape_codes <<< "$_POSTFIX")"
    fi
}

# Compute the prefixes and postfix to use for the functions below.
_sdk_prettify_output


__sdk_align_lines_with_prefix() {
    local nb_spaces_to_align=0
    local strippedprefix
    strippedprefix="$(__sdk_strip_ansi_escape_codes <<< "${1:-}")"
    nb_spaces_to_align="${#strippedprefix}"
    sed -e "2,\$s|^|$(printf "%${nb_spaces_to_align}s" '')|g"
}


sdk_info() {
    local prefix text postfix
    prefix="$(_sdk_print_indentation)${_INFO_PREFIX:- [*] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(__sdk_align_lines_with_prefix "${prefix}" <<< "$text")"
    echo >&2 "${prefix}${text}${postfix}"
}

sdk_warn() {
    local prefix text postfix
    prefix="$(_sdk_print_indentation)${_WARN_PREFIX:- [!] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(__sdk_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}

sdk_error() {
    local prefix text postfix
    prefix="$(_sdk_print_indentation)${_ERROR_PREFIX:- [X] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(__sdk_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}


sdk_begin() {
    local prefix text postfix
    prefix="$(_sdk_print_indentation)${_BEGIN_PREFIX:- [+] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(__sdk_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}

sdk_end() {
    local prefix text postfix
    prefix="$(_sdk_print_indentation)${_END_PREFIX:- [-] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(__sdk_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}


sdk_die() {
    local prefix text postfix
    prefix="$(_sdk_print_indentation)${_ERROR_PREFIX:- [X] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(__sdk_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
    exit 255
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
