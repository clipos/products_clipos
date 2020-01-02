# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

sdk_info() {
    local text
    if [[ -t 1 ]]; then
        text="$(sed -e "s|^|"$'\e[1m'"|g" -e "s|$|"$'\e[0m'"|g" <<< "$*")"
        text=$'\e[30;1m(SDK)\e[0m \e[34;1m[*]\e[0m '"$text"
        echo "$(sed -e "2,\$s|^|"$'\e[30;1m(SDK)\e[0m     '"|g" <<< "$text")"
    else
        echo "$(sed -e "2,\$s|^|(SDK)     |g" <<< "(SDK) [*] $*")"
    fi
}

sdk_warn() {
    local text
    if [[ -t 1 ]]; then
        text="$(sed -e "s|^|"$'\e[1m'"|g" -e "s|$|"$'\e[0m'"|g" <<< "$*")"
        text=$'\e[30;1m(SDK)\e[0m \e[33;1m[!]\e[0m '"$text"
        echo "$(sed -e "2,\$s|^|"$'\e[30;1m(SDK)\e[0m     '"|g" <<< "$text")"
    else
        echo "$(sed -e "2,\$s|^|(SDK)     |g" <<< "(SDK) [!] $*")"
    fi
}

sdk_error() {
    local text
    if [[ -t 1 ]]; then
        text="$(sed -e "s|^|"$'\e[1m'"|g" -e "s|$|"$'\e[0m'"|g" <<< "$*")"
        text=$'\e[30;1m(SDK)\e[0m \e[31;1m[X]\e[0m '"$text"
        echo "$(sed -e "2,\$s|^|"$'\e[30;1m(SDK)\e[0m     '"|g" <<< "$text")"
    else
        echo "$(sed -e "2,\$s|^|(SDK)     |g" <<< "(SDK) [X] $*")"
    fi
}

sdk_success() {
    local text
    if [[ -t 1 ]]; then
        text="$(sed -e "s|^|"$'\e[1m'"|g" -e "s|$|"$'\e[0m'"|g" <<< "$*")"
        text=$'\e[30;1m(SDK)\e[0m \e[32;1m[+]\e[0m '"$text"
        echo "$(sed -e "2,\$s|^|"$'\e[30;1m(SDK)\e[0m     '"|g" <<< "$text")"
    else
        echo "$(sed -e "2,\$s|^|(SDK)     |g" <<< "(SDK) [+] $*")"
    fi
}

sdk_die() {
    if [[ "$#" -eq 0 ]]; then
        sdk_error "Failure exit without any reason provided  :("
    else
        sdk_error "$*"
    fi
    exit 255
}

# vim: set ts=4 sts=4 sw=4 et ft=sh:
