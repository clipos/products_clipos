Dummy IPsec PKI for CLIP OS developement purposes
=================================================

**THIS PUBLIC KEY INFRASTRUCTURE (PKI) IS ONLY FOR DEVELOPMENT AND DEBUGGING
PURPOSES. DO NOT DEPLOY THIS PKI IN PRODUCTION!!!**

This source is a dummy PKI for IPsec connectivity with CLIP OS instances
debugging purposes.

Making of
---------

With an ephemeral SDK instanciated with CLIP OS Core Portage profile, this PKI
has been produced with the following commands:

```bash
#
# Root CA generation
# (Certificate with a 10 years lifetime)
#
ipsec pki --gen \
	--type ecdsa --size 384 \
	--outform pem > root-ca.key.pem

ipsec pki --self --ca \
	--lifetime 3650 \
	--in root-ca.key.pem \
	--type ecdsa \
	--dn "C=FR, O=CLIP OS Development Team, OU=DUMMY CERTIFICATE/NOT FOR PRODUCTION, CN=Root CA for CLIP OS/IPsec stack development purposes" \
	--outform pem > root-ca.cert.pem

#
# IPsec server CA generation
# (Certificate with a 2 years lifetime)
#
ipsec pki --gen \
	--type ecdsa --size 384 \
	--outform pem > server.key.pem

ipsec pki --pub \
	--type ecdsa \
	--in server.key.pem \
	--outform pem > server.pubkey.pem

ipsec pki --issue \
	--lifetime 730 \
	--in server.pubkey.pem \
	--cacert root-ca.cert.pem --cakey root-ca.key.pem \
	--dn "C=FR, O=CLIP OS Development Team, OU=DUMMY CERTIFICATE/NOT FOR PRODUCTION, CN=ipsec-server.dummy.clip-os.org" \
	--san "ipsec-server.dummy.clip-os.org" --flag serverAuth --flag ikeIntermediate \
	--outform pem > server.cert.pem


#
# IPsec client CA generaton
# (Ceritificate with a 2 years lifetime)
#
ipsec pki --gen \
        --type ecdsa --size 384 \
        --outform pem > client.key.pem

ipsec pki --pub \
        --type ecdsa \
        --in client.key.pem \
        --outform pem > client.pubkey.pem

ipsec pki --issue \
        --lifetime 730 \
        --in client.pubkey.pem \
        --cacert root-ca.cert.pem --cakey root-ca.key.pem \
        --dn "C=FR, O=CLIP OS Development Team, OU=DUMMY CERTIFICATE/NOT FOR PRODUCTION, CN=ipsec-client@dummy.clip-os.org" \
        --san "ipsec-client@dummy.clip-os.org" \
        --outform pem > client.cert.pem
```
