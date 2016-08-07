#!/bin/bash
set -e

: ${CF_OPS_MAN_GUI_USER:?"Need to set CF_OPS_MAN_GUI_USER non-empty"}
: ${CF_OPS_MAN_GUI_PASS:?"Need to set CF_OPS_MAN_GUI_PASS non-empty"}
: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}

CF_OPS_MAN_GUI_SSH_PORT="${CF_OPS_MAN_GUI_SSH_PORT:-22}"
# API Token
# https://github.com/cloudfoundry/uaa/blob/master/docs/UAA-APIs.rst#password-grant-with-client-and-user-credentials-post-oauth-token
# https://<opsman-host>/docs
echo "Getting API token from ${CF_OPS_MAN_GUI_HOST} with user $CF_OPS_MAN_GUI_USER"
api_token_json=$(curl -s -k -H "Accept: application/json;charset=utf-8" -d "grant_type=password" -d "username=${CF_OPS_MAN_GUI_USER}" -d "password="${CF_OPS_MAN_GUI_PASS}"" -u 'opsman:' https://${CF_OPS_MAN_GUI_HOST}/uaa/oauth/token)
api_token=$(echo $api_token_json | jq -r .access_token)
# Director
director_creds_response=$(curl -vvv -k -s -X GET "https://${CF_OPS_MAN_GUI_HOST}/api/v0/deployed/director/credentials/director_credentials" -H "Authorization: bearer $api_token")
echo "Ops Manager Director user: director"
echo $(echo $director_creds_response | jq -r .credential.value.password)
#Ops Man login
ssh ubuntu@$CF_OPS_MAN_GUI_HOST -p $CF_OPS_MAN_GUI_SSH_PORT