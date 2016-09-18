#!/usr/bin/env bash
set -e
: ${CF_NEW_CLIENT_ID:?"Need to set CF_NEW_CLIENT_ID non-empty"}
: ${CF_NEW_CLIENT_SECRET:?"Need to set CF_NEW_CLIENT_SECRET non-empty"}
: ${CF_UAA_HOST:?"Need to set CF_UAA_HOST non-empty"}
: ${CF_ADMIN_CLIENT_PASS:?"Need to set CF_ADMIN_CLIENT_PASS non-empty"}

new_client_id=$CF_NEW_CLIENT_ID
new_client_secret=$CF_NEW_CLIENT_SECRET
user="admin"
admin_client_password=$CF_ADMIN_CLIENT_PASS
uaa_host=$CF_UAA_HOST
echo "Host: $uaa_host"
# Equivalent to uaac token client get admin -s $admin_client_password --trace
token_response=$(curl -sk -u admin:$admin_client_password -d grant_type=client_credentials  https://$uaa_host/oauth/token)
access_token=$(echo $token_response | jq -r .access_token)
echo $access_token

clients=$(curl -sk -H "Authorization: Bearer $access_token" https://$uaa_host/oauth/clients)
echo $clients | jq .
echo

body='{"client_id":"'"$new_client_id"'","client_secret":"'"$new_client_secret"'","name":"'"$new_client_id"'","authorized_grant_types":["client_credentials"],"authorities":["uaa.admin","clients.read","clients.write","clients.secret","scim.read","scim.write","clients.admin"]}'

# Equivalent to uaac client add test-client --trace -s thisisourlittlesecret --authorized_grant_types client_credentials --authorities "uaa.admin","clients.read","clients.write","clients.secret","scim.read","scim.write","clients.admin"
curl -sk -H "Content-Type: application/json" -H "Authorization: bearer $access_token" --data $body https://$uaa_host/oauth/clients