#!/bin/sh

set -xe

OUTDIR=${OUTDIR:-/etc/ssl-secure}
CN=$(hostname -f)

cakey="${OUTDIR}/ca.key"
cacert="${OUTDIR}/ca.crt"
csr="${OUTDIR}/test.csr"
csr_ext="${OUTDIR}/test.v3.ext"
key="${OUTDIR}/test.key"
cert="${OUTDIR}/test.crt"

mkdir "$OUTDIR"

# Based on https://arminreiter.com/2022/01/create-your-own-certificate-authority-ca-using-openssl/

# Create a CA
openssl genrsa -aes256 -out "$cakey" -passout pass:ca-password 2048
openssl req -x509 -new -passin pass:ca-password -passout pass:ca-password -key "$cakey" -sha256 -days 1826 -out "$cacert" -subj '/CN=Trusted CA acceptance tests Root CA'

# Create the certificate signing request
openssl req -new -passin pass:password -nodes -out "$csr" -newkey rsa:2048 -keyout "$key" -subj "/CN=${CN}"

# create a v3 ext file for SAN properties
cat > "$csr_ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${CN}
EOF

# Inspect CSR
openssl req -text -noout -in "$csr"

# Create the Certificate
openssl x509 -req -passin pass:ca-password -in "$csr" -CA "$cacert" -CAkey "$cakey" -CAcreateserial -out "$cert" -days 730 -sha256 -extfile "$csr_ext"
