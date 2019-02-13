# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2017 ANSSI. All rights reserved.

product = "clipos"
recipe = "sdk"

# Pipeline all the actions to produce the final result of this recipe
all: bootstrap

# Bootstrap from scratch (i.e. by rebuilding all the packages composing this
# SDK) this SDK recipe
bootstrap-from-scratch: clear-cache bootstrap

# bootstrap the binary packages necessary to build the rootfs of this recipe
bootstrap:
    #!/usr/bin/env bash
    repo_root="$(cosmk repo-root-path)"
    version="$(cosmk product-version {{product}})"
    if [[ ! -f "${repo_root}/cache/{{product}}/${version}/{{recipe}}/rootfs.squashfs" ]]; then
        cosmk bootstrap "{{product}}/{{recipe}}"
    fi

# Clear the SDK squashfs. The next bootstrap run will then rebuild the SDK from
# cached binary packages.
clear:
    #!/usr/bin/env bash
    repo_root="$(cosmk repo-root-path)"
    version="$(cosmk product-version {{product}})"
    rm -f "${repo_root}/cache/{{product}}/${version}/{{recipe}}/rootfs.squashfs"

# Clear the binary package cache used during the "bootstrap" action step. This
# will force the bootstrap from scratch of all the packages on the next run of
# the "bootstrap" action step.
clear-cache:
    #!/usr/bin/env bash
    repo_root="$(cosmk repo-root-path)"
    version="$(cosmk product-version {{product}})"
    rm -rf "${repo_root}/cache/{{product}}/${version}/{{recipe}}"

# vim: set ts=4 sts=4 sw=4 et ft=make:
