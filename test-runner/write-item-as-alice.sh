TOKEN=$(curl -X POST http://localhost:8080/realms/barrehackathlon/protocol/openid-connect/token -d "grant_type=password" -d "client_id=postgrest" -d "client_secret=this_is_a_very_long_and_secure_jwt_secret_123\!" -d "username=alice&password=alicepass" | jq -r .access_token)

echo "TOKEN: $TOKEN"

curl -X POST http://localhost:3000/items -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"owner_username":"alice","content":"Hello from Alice"}'