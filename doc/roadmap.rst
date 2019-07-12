.. Copyright © 2018 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

.. _roadmap:

Roadmap
=======

This roadmap lists CLIP OS features planned for integration into each release.

.. admonition:: Work in progress
   :class: warning

   **This roadmap is still a work in progress and will evolve with the project
   as features are added.**

5.0 Alpha: Initial open source preview release
----------------------------------------------

.. admonition:: Status
   :class: tip

   Released on **2018-09-20**.

Features
~~~~~~~~

Security aware system architecture and partition layout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Root partition mounted read-only
* Restricted set of state partitions bind-mounted at pre-determined
  emplacements (listed in the read only root partition)

Initial boot chain integrity with UEFI Secure Boot support and DM-Verity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Signed EFI bootloader
* Signed EFI binaries (includes Linux kernel, initramfs and kernel command
  line)
* Root partition integrity enforced by DM-Verity

Development model and secure by default software compilation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Everything is rebuilt from source (excepted proprietary firmware required for
  hardware support).
* Gentoo Hardened based binary executable compilation
* Most of the Portage compilation security features are enabled.

Linux kernel
^^^^^^^^^^^^

* Latest stable kernel:

  * is properly configured,
  * and includes additional security features imported from public patches.

Hardware support
^^^^^^^^^^^^^^^^

* QEMU/KVM with virtio devices on Linux
* Boot with Secure Boot enabled UEFI firmware


5.0 Beta: Main security & service enabling release
--------------------------------------------------

.. admonition:: Status
   :class: notice

   In progress. See the `5.0 Beta milestone
   <https://github.com/clipos/bugs/milestone/1>`_.

Features
~~~~~~~~

Robust update system
^^^^^^^^^^^^^^^^^^^^

* Atomic system update using A/B partitions (similar to Android or ChromeOS)
* Fallback system version available in case of unexpected failure or bug
* Supports updating both the system and other environments

System partition integrity and confidentiality
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* LUKS2/DM-Crypt/DM-Integrity support
* Optional system read only partition encryption
* Mandatory system read/write partition encryption (journal logs,
  configuration, etc.)
* TPM backed secret sealing and unsealing for unattended system partition
  decryption
* Support for install time escrow keys setup for administrator enabled recovery

Confined system services
^^^^^^^^^^^^^^^^^^^^^^^^

* Confinement using Linux security features supported in systemd:

  * namespaces
  * cgroups
  * seccomp-bpf
  * capability bounding set
  * etc.

Services available
^^^^^^^^^^^^^^^^^^

* IPsec client
* Update daemon
* SSH daemon

Firewall rules
^^^^^^^^^^^^^^

* Static firewall rules for system services

Confined (non-root) administration roles
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Admin role: can edit files in the state configuration folder
* Audit role: can read all system logs
* Administration roles are accessible:

  * through the IPsec tunnel, over SSH with key based authentication;
  * locally on a console, using a password.

* Split credential management for password based authentication (``pam-tcb``)

Linux kernel
^^^^^^^^^^^^

* Latest stable kernel:

  * Inclusion of additional security features, some expected to be merged
    upstream

Hardware support
^^^^^^^^^^^^^^^^

* Initial laptop, desktop and server platforms support


5.0: First stable release with multi-level support
--------------------------------------------------

.. admonition:: Status
   :class: warning

   Not started yet.

Features
~~~~~~~~

User data integrity and confidentiality
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Fixed size LUKS2/DM-Crypt/DM-Integrity based user partition support
* Encryption based on user-only known secret
* User credentials managed independently from system roles credentials
* User credentials supported:

  * Password
  * Smartcard

* Smartcard daemon isolation using Caml Crush.

Multi-level environment support
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Multiple isolated environment available with different security settings:

  * Environments confined using a kernel LSM inspired from Vserver
  * Controlled communication between environments (UNIX sockets or encrypted
    connections)

* Host and inter-levels interaction enabled through trusted services on the
  host:

  * File transfer, encryption and decryption using diodes

* Intra-level application isolation using Flatpak

Multi-level aware device assignment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Printers, scanners
* USB flash drives
* Smartcards
* Webcam
* Sound cards
* Microphone

Virtualized environments support
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Linux only
* virtio based peripherals only
* UEFI Secure Boot optional

Firewall rules
^^^^^^^^^^^^^^

* Dynamic firewall rules for user environments

Trusted graphical environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Wayland based system compositor and lock screen
* Permanently displayed and trusted panel for interaction with system
  services and configuration

Arbitrary code execution restrictions in user environments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Applied to interpreters (e.g. Bash, Python, Perl): ``O_MAYEXEC``

Linux kernel
^^^^^^^^^^^^

* Additional kernel version supported: latest LTS kernel:

  * Supported until the next upstream LTS kernel release

Hardware support
^^^^^^^^^^^^^^^^

  * List of validated laptop, desktop and server platforms supported
  * Generic laptop, desktop and server platforms support


Milestone features whose integration planning are yet to be determined
----------------------------------------------------------------------

* Remote integrity and version attestation using TPM backed signatures.

* Port remaining security features from CLIP OS version 4:

  * Ignored SUID binaries
  * System entropy and RNG improvements: timer_entropyd, kernel patch
  * Remaining kernel features from CLIP LSM patches:

    * Veriexec: additional integrity measurements and capability granting tool

* Mandatory Access Control support:

  * SELinux

* Reproducible builds

* Additional user credential support:

  * U2F based user session unlocking

* Append-only log storage and automatic log rotation support

.. vim: set tw=79 ts=2 sts=2 sw=2 et:
