#!/bin/bash
set -e

# Várjuk, hogy a Keycloak és PostgREST elinduljon
until curl -s http://keycloak:8080/realms/barrehackathlon/.well-known/openid-configuration > /dev/null; do
  echo "🔄 Waiting for Keycloak..."
  sleep 2
done

until curl -s http://postgrest:3000/ > /dev/null; do
  echo "🔄 Waiting for PostgREST..."
  sleep 2
done

# Token kérés Alice-nak
echo "🔐 Getting token for alice..."
TOKEN=$(curl -v http://keycloak:8080/realms/barrehackathlon/protocol/openid-connect/token \
  -d "grant_type=password" \
  -d "client_id=postgrest" \
  -d "username=alice" \
  -d "password=alicepass" | jq -r .access_token)

  

echo "✅ Got token: ${TOKEN}"

# POST kérés az API-ra
echo "📤 Creating item via PostgREST..."

echo "curl -v -X POST http://postgrest:3000/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "test item from alice"}'"

curl -v -X POST http://postgrest:3000/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "test item from alice"}'

echo "✅ Test completed"

curl -v -X GET http://postgrest:3000/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
