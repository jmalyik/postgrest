#!/bin/bash
PRIVATE_KEY_PASS=privatekeypass
KEYSTORE_PASS=changeit
ALIAS=keycloak

# Generate a self-signed certificate from the private key
openssl req -new -x509 -key ./private.pem -out ./certificate.pem -days 365 -subj "/CN=keycloak" -passin pass:$PRIVATE_KEY_PASS

# Create the PKCS#12 keystore using the private key and certificate
openssl pkcs12 -export \
  -inkey ./private.pem -in ./certificate.pem \
  -name $ALIAS \
  -out ./keycloak-keystore.p12 \
  -passin pass:$PRIVATE_KEY_PASS \
  -passout pass:$KEYSTORE_PASS

echo "PKCS#12 keystore created. Alias for private key: $ALIAS"
echo "Keystore password: $KEYSTORE_PASS"