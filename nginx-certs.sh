#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <env-file>"
  echo "Example: $0 env/myconf.env"
  exit 1
fi

ENV_FILE="$1"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: env file '$ENV_FILE' not found"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "$DOMAIN1" ] || [ -z "$SSL_CA_PASSPHRASE" ] || [ -z "$SSL_SUBJECT" ]; then
  echo "Error: DOMAIN1, SSL_CA_PASSPHRASE and SSL_SUBJECT must be set in the env file"
  exit 1
fi

CERTS_DIR="./data/nginx/certs"
mkdir -p "$CERTS_DIR"

echo "==> Generating root CA key and certificate..."
openssl genrsa -des3 -out "$CERTS_DIR/rootCA.key" -passout pass:"$SSL_CA_PASSPHRASE" 2048 && \
openssl req -x509 -new -nodes -key "$CERTS_DIR/rootCA.key" -passin pass:"$SSL_CA_PASSPHRASE" \
  -sha256 -days 730 -out "$CERTS_DIR/rootCA.pem" -subj "$SSL_SUBJECT"

if [ $? -ne 0 ]; then
  echo "Error: failed to generate root CA"
  exit 1
fi

echo "==> Generating TLS key and certificate request..."
openssl genrsa -out "$CERTS_DIR/tls.key" 2048 && \
openssl req -new -key "$CERTS_DIR/tls.key" -out "$CERTS_DIR/tls.csr" -subj "$SSL_SUBJECT"

if [ $? -ne 0 ]; then
  echo "Error: failed to generate certificate request"
  exit 1
fi

echo "==> Creating openssl.cnf with SAN entries..."
cat > "$CERTS_DIR/openssl.cnf" <<EOF
basicConstraints       = CA:FALSE
authorityKeyIdentifier = keyid:always, issuer:always
keyUsage               = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
subjectAltName         = @alt_names
[ alt_names ]
DNS.1 = ${DOMAIN1}
DNS.2 = *.${DOMAIN1}
EOF

if [ -n "$DOMAIN2" ]; then
  echo "DNS.3 = ${DOMAIN2}" >> "$CERTS_DIR/openssl.cnf"
fi

echo "==> Signing certificate with root CA..."
openssl x509 -req \
  -in "$CERTS_DIR/tls.csr" \
  -CA "$CERTS_DIR/rootCA.pem" \
  -CAkey "$CERTS_DIR/rootCA.key" \
  -passin pass:"$SSL_CA_PASSPHRASE" \
  -CAcreateserial \
  -out "$CERTS_DIR/tls.crt" \
  -days 730 \
  -sha256 \
  -extfile "$CERTS_DIR/openssl.cnf"

if [ $? -ne 0 ]; then
  echo "Error: failed to sign certificate"
  exit 1
fi

echo "==> Verifying certificate..."
openssl verify -CAfile "$CERTS_DIR/rootCA.pem" -verify_hostname "$DOMAIN1" "$CERTS_DIR/tls.crt"

echo "==> Done. Certificates created in $CERTS_DIR"
echo "    To trust in Chrome, import $CERTS_DIR/rootCA.pem as a CA authority."
