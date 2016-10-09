#!/usr/bin/env bash
set -e
: ${CF_UAA_NEW_CLIENT_ID:?"Need to set CF_UAA_NEW_CLIENT_ID non-empty"}
: ${CF_UAA_NEW_CLIENT_SECRET:?"Need to set CF_UAA_NEW_CLIENT_SECRET non-empty"}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/export-uaa-pre-requisites.sh"
: ${CF_UAA_HOST:?"Need to set CF_UAA_HOST non-empty"}
: ${CF_UAA_ACCESS_TOKEN:?"Need to set CF_UAA_ACCESS_TOKEN non-empty"}
: ${CF_UAA_NEW_CLIENT_AUTHORITIES:?"Need to set CF_UAA_NEW_CLIENT_AUTHORITIES non-empty"}

body='{"client_id":"'"$CF_UAA_NEW_CLIENT_ID"'","client_secret":"'"$CF_UAA_NEW_CLIENT_SECRET"'","name":"'"$CF_UAA_NEW_CLIENT_ID"'","authorized_grant_types":["client_credentials"],"authorities":['$CF_UAA_NEW_CLIENT_AUTHORITIES']}'

# Equivalent to uaac client add test-client --trace -s thisisourlittlesecret --authorized_grant_types client_credentials --authorities "uaa.admin","clients.read","clients.write","clients.secret","scim.read","scim.write","clients.admin"
curl -sk -H "Content-Type: application/json" -H "Authorization: bearer $CF_UAA_ACCESS_TOKEN" --data $body https://$CF_UAA_HOST/oauth/clients