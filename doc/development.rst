.. Copyright © 2019 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

.. _development:

Development and debug
=====================

This section describes all changes and information specific to development and
debug that only applies to the CLIP OS product.

Effect of instrumentation features
----------------------------------

This is a summary of all changes made to the project during build and
configuration steps for each instrumentation feature available for development
only. Instrumentation features must be configured before project builds in
``instrumentation.toml`` which must be located in the project repo root
directory. See ``toolkit/instrumentation.toml.example`` to get good default
values for development.

* **instrumented-core:** Install additional software development tools in the
  Core, such as Bash, Vim, tmux, tree, strace, grep, ip, less, gdb, tcpdump,
  etc. (This is a non-exhautive list, for the complete list please refer to
  the ``clipos-meta/clipos-core`` ebuild)

* **passwordless-root-login:** Enable local and remote (SSH) root login
  without password.

  .. admonition:: Dependency
     :class: warning

     To use this instrumentation feature, you must also enable
     **instrumented-core**.

* **allow-ssh-root-login:** Configure SSH in order to allow a developer to
  log in as root (account must be enabled with the appropriate
  instrumentation feature) via SSH and without any password thanks to an
  installed SSH key pair (an SSH key pair will be generated in the cache
  directory at first usage of this instrumentation feature).

  .. admonition:: Dependency
     :class: warning

     To use this instrumentation feature, you must also enable
     **passwordless-root-login** and **instrumented-core**.

* **dev-friendly-bootloader:** Configure the bootloader to provide handy
  features to developer (i.e.  "Reboot into firmware") and set a smaller
  timeout before loading the default boot entry.

* **instrumented-initramfs:** Install additional software development tools in
  the initramfs, such as strace, ltrace, less, grep, gdb, etc. (This is a
  non-exhautive list, for the complete list please refer to the
  ``clipos-meta/clipos-efiboot`` ebuild).

* **soften-kernel-configuration:** Lower Linux kernel security parameters at
  runtime.

* **initramfs-no-require-tpm:** Do not require a TPM 2.0 for the LUKS disk
  partition decryption.  Therefore, in case of missing TPM 2.0, LUKS passphrase
  will be prompted on the active console (either tty or serial console ttyS0).

* **initramfs-no-tpm-lockout:** Do not lockout TPM (brute-force attack
  protection) when interacting with the TPM 2.0 (check out the TPM
  documentation for the "noDA" attribute and for "dictionary attack
  protections").

* **debuggable-initramfs:** Activate alterations to initramfs/efiboot packages
  intended to ease their debugging (e.g. debugging symbols):

* **breakpointed-initramfs:** Enable dracut breakpoints with interactive shell
  drop-outs.

  .. admonition:: Important note
     :class: important

     This feature requires multiple interactions on the console (or serial
     console for the QEMU target) to make the boot sequence proceed to the
     final pivot_root(2).

  .. admonition:: Dependency
     :class: warning

     To use this instrumentation feature, you must also enable
     **instrumented-initramfs**.

* **early-root-shell:** Spawn a persistent root interactive shell on a serial
  console or an tty very early in the boot up sequence (right after the
  pivot_root(2) done by the initramfs) in order to ease systemd debugging
  tasks. See `systemd debugging
  <https://freedesktop.org/wiki/Software/systemd/Debugging>`_ for more
  information.

  .. admonition:: Dependency
     :class: warning

     To use this instrumentation feature, you must also enable
     **instrumented-core**.

* **debuggable-kernel:** Activates features for debugging purposes in the
  kernel (KALLSYMS, core dump production, etc.) with logging output sent on the
  serial port (ttyS0) early on boot up sequence.

* **verbose-systemd:** Sets parameters on the kernel command line to make
  systemd very verbose on the defined console output (ttyS0 serial port by
  default):

* **coredump-handler:** Configure systemd in order to install the
  systemd-coredump to allow kernel produce core dump files.

  .. admonition:: Dependency
     :class: warning

     To use this instrumentation feature, you must also enable
     **debuggable-kernel**.

.. vim: set tw=79 ts=2 sts=2 sw=2 et:
