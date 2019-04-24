.. Copyright © 2019 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

.. _development:

Development and debug
=====================

This section describes all changes and information specific to development and
debug that only applies to the CLIP OS product.

Effect of instrumentation levels
--------------------------------

This is a summary of all changes made to the project during build and
configuration steps for each instrumentation level available for development
only. This is organized as a list of recipes, each with their instrumentation
level. Instrumentation levels must be configured before project builds in
``instrumentation.toml`` which must be located in the project repo root
directory.

clipos/core
~~~~~~~~~~~

* *development*:

  * Enable local and remote (SSH) **root** login without password
  * Install additional development and debug tools (non exhaustive list, see
    ``clipos-meta/clipos-core``: vim, tmux, tree, strace, grep, ip, less, gdb,
    etc.)
  * ``sys-apps/systemd``:

    * Build *coredump* related tools
    * Enable debug shell support (still disabled by default, see *debug* for
      ``clipos/efiboot``)

* *debug*:

  * Tune the kernel ``sysctl``'s in order to lower security to ease binary
    debugging:

    * Enable signed kernel module loading
    * Disable ``PTRACE`` protections
    * Do not hide kernel pointers values from the kernel log

clipos/efiboot
~~~~~~~~~~~~~~

* *development*:

  * Increase bootloader timeout
  * Enable interactive serial console
  * Install additional development and debug tools (non exhaustive list, see
    ``clipos-meta/clipos-efiboot``: strace, ltrace, less, grep, gdb, etc.)

* *debug*:

  * Enable persistent debug shell in ``clipos/core``
  * Enable ``dracut`` breakpoints with interactive shell (requires multiple
    interactions on the serial console to resume boot)

clipos/qemu
~~~~~~~~~~~

* *development*:

  * Create *root* home directory and setup ``.ssh/authorized_keys`` for remote
    login

.. vim: set tw=79 ts=2 sts=2 sw=2 et:
