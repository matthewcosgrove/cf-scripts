#!/usr/bin/env bash
set -e

: ${CF_UAA_HOST:?"Need to set CF_UAA_HOST non-empty"}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/../export/admin-client-creds.sh"
: ${PCF_ADMIN_CLIENT_PASSWORD:?"Need to set PCF_ADMIN_CLIENT_PASSWORD non-empty"}

# Equivalent to uaac token client get admin -s $admin_client_password --trace
token_response=$(curl -sk -u admin:$PCF_ADMIN_CLIENT_PASSWORD -d grant_type=client_credentials  https://$CF_UAA_HOST/oauth/token)
access_token=$(echo $token_response | jq -r .access_token)
export CF_UAA_ACCESS_TOKEN=$access_token