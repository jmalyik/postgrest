#!/bin/sh
echo "Logging in to Keycloak as $KEYCLOAK_ADMIN with password $KEYCLOAK_ADMIN_PASSWORD"
/opt/keycloak/bin/kcadm.sh config credentials --server http://keycloak:8080 --realm master --user $KEYCLOAK_ADMIN --password $KEYCLOAK_ADMIN_PASSWORD
# Disable required actions at realm level
for action in UPDATE_PASSWORD UPDATE_PROFILE VERIFY_PROFILE CONFIGURE_TOTP VERIFY_EMAIL TERMS_AND_CONDITIONS webauthn-register webauthn-register-passwordless; do
  /opt/keycloak/bin/kcadm.sh update authentication/required-actions/$action -r barrehackathlon -s "enabled=false"
done