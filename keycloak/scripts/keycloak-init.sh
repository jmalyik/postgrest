#!/bin/sh

SERVER_URL="http://keycloak:8080"
REALM="barrehackathlon"
ADMIN_USER="$KEYCLOAK_ADMIN"
ADMIN_PASS="$KEYCLOAK_ADMIN_PASSWORD"
ALIAS="keycloak"

echo "Logging in to Keycloak as $ADMIN_USER"
/opt/keycloak/bin/kcadm.sh config credentials --server $SERVER_URL --realm master --user $ADMIN_USER --password $ADMIN_PASS

# Import custom key to the realm
#echo "Importing custom key to realm $REALM..."
#/opt/keycloak/bin/kcadm.sh create keys -r $REALM -s "active=true" -s "enabled=true" -s "algorithm=RS256" -s "providerId=rsa" -s "privateKey=@/opt/keycloak/keys/private.pem" -s "publicKey=@/opt/keycloak/keys/public.pem" -s "name=$ALIAS" -s "priority=100"

#echo "Key import completed."

# (Optional) List keys for verification
/opt/keycloak/bin/kcadm.sh get keys -r $REALM

# Disable default required actions (optional customization)
echo "Disabling default required actions in realm $REALM..."
for action in UPDATE_PASSWORD UPDATE_PROFILE VERIFY_PROFILE CONFIGURE_TOTP VERIFY_EMAIL TERMS_AND_CONDITIONS webauthn-register webauthn-register-passwordless; do
  /opt/keycloak/bin/kcadm.sh update authentication/required-actions/$action -r $REALM -s "enabled=false"
done

echo "Keycloak realm initialization completed."
