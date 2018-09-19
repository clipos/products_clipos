.. Copyright © 2018 ANSSI.
   CLIP OS is a trademark of the French Republic.
   Content licensed under the Open License version 2.0 as published by Etalab
   (French task force for Open Data).

Secure Boot support
===================

Security properties
-------------------

All EFI binaries installed in the CLIP OS EFI System Partition (ESP) are
signed in order to protect their integrity *via* Secure Boot. Their
confidentiality however is not affected. Currently, two EFI binaries are
necessary:

* The **main CLIP OS EFI binary** containing the initial kernel image, the
  initramfs and the kernel command line. Signing this binary guarantees the
  integrity of its three components. Note that the kernel command line also
  includes the DM-Verity root hash for the CLIP OS Core partition.
* The **systemd-boot EFI stub binary**, which is responsible for verifying and
  executing the main CLIP OS EFI binary.

Setup for testing under QEMU
----------------------------

The optimal way of setting up Secure Boot for a virtual machine will be to
develop and use an EFI binary to automatically enroll PK, KEK and db keys,
similarly to `what Fedora is performing
<https://github.com/puiterwijk/qemu-ovmf-secureboot>`_.  Such keys would be
generated at build time for a given deployment using the relevant PKI.

As a short term solution, however, we use hard-coded dummy keys to sign the
EFI binaries with **sbsigntools** and ship an OVMF VARS template file in which
these keys have been manually enrolled.

Setup for testing with real hardware
------------------------------------

This is not supported at the moment. The main difference is that Secure Boot
keys will need to be enrolled through the manufacturer's UEFI firmware.
However, we expect the EFI binary mentioned above to make this step as
automated as possible.

.. vim: set tw=79 ts=2 sts=2 sw=2 et:
