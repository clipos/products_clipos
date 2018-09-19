# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017-2018 ANSSI. All rights reserved.

# Do not overwrite INDENTLEVEL if it already exists. We may inherit a value
# from the environment.
: "${INDENTLEVEL:=0}"

eindent() {
    let INDENTLEVEL++ || true
}

eoutdent() {
    let INDENTLEVEL-- || true
}

_indent() {
    printf "%$((INDENTLEVEL*4))s" ""
}


# Strips all the ANSI special "escape codes"
_strip_ansi_escape_codes() {
    # Source: http://www.commandlinefu.com/commands/view/3584
    sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

prettify_output() {
    # Fancy colors for the terminal
    _INFO_PREFIX=$' \e[34;1m[*]\e[0m \e[1m'
    _WARN_PREFIX=$' \e[33;1m[!]\e[0m \e[1m'
    _ERROR_PREFIX=$' \e[31;1m[X]\e[0m \e[1m'
    _BEGIN_PREFIX=$' \e[36;1m[+]\e[0m \e[1m'
    _END_PREFIX=$' \e[32;1m[-]\e[0m \e[1m'
    _POSTFIX=$'\e[0m'

    # strip ANSI escape codes if the standard output is not a TTY
    if [[ ! -t 2 ]]; then
        _INFO_PREFIX="$(_strip_ansi_escape_codes <<< "$_INFO_PREFIX")"
        _WARN_PREFIX="$(_strip_ansi_escape_codes <<< "$_WARN_PREFIX")"
        _ERROR_PREFIX="$(_strip_ansi_escape_codes <<< "$_ERROR_PREFIX")"
        _BEGIN_PREFIX="$(_strip_ansi_escape_codes <<< "$_BEGIN_PREFIX")"
        _END_PREFIX="$(_strip_ansi_escape_codes <<< "$_END_PREFIX")"
        _POSTFIX="$(_strip_ansi_escape_codes <<< "$_POSTFIX")"
    fi
}

# Compute the prefixes and postfix to use for the functions below.
prettify_output


_align_lines_with_prefix() {
    local nb_spaces_to_align=0
    local strippedprefix
    strippedprefix="$(_strip_ansi_escape_codes <<< "${1:-}")"
    nb_spaces_to_align="${#strippedprefix}"
    sed -e "2,\$s|^|$(printf "%${nb_spaces_to_align}s" '')|g"
}


einfo() {
    local prefix text postfix
    prefix="$(_indent)${_INFO_PREFIX:- [*] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(_align_lines_with_prefix "${prefix}" <<< "$text")"
    echo >&2 "${prefix}${text}${postfix}"
}

ewarn() {
    local prefix text postfix
    prefix="$(_indent)${_WARN_PREFIX:- [!] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}

eerror() {
    local prefix text postfix
    prefix="$(_indent)${_ERROR_PREFIX:- [X] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}


ebegin() {
    local prefix text postfix
    prefix="$(_indent)${_BEGIN_PREFIX:- [+] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}

eend() {
    local prefix text postfix
    prefix="$(_indent)${_END_PREFIX:- [-] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
}


die() {
    local prefix text postfix
    prefix="$(_indent)${_ERROR_PREFIX:- [X] }"
    postfix="${_POSTFIX:-}"
    text="$*"
    text="$(_align_lines_with_prefix "${prefix}" <<< "${text}")"
    echo >&2 "${prefix}${text}${postfix}"
    exit 255
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
