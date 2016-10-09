#!/bin/bash

set -e

: ${CF_OPS_MAN_GUI_USER:?"Need to set CF_OPS_MAN_GUI_USER non-empty"}
: ${CF_OPS_MAN_GUI_PASSWORD:?"Need to set CF_OPS_MAN_GUI_PASSWORD non-empty"}
: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}

# https://github.com/cloudfoundry/uaa/blob/master/docs/UAA-APIs.rst#password-grant-with-client-and-user-credentials-post-oauth-token
echo "Getting Ops Man API token from ${CF_OPS_MAN_GUI_HOST} with user $CF_OPS_MAN_GUI_USER"
api_token_json=$(curl -s -k -H "Accept: application/json;charset=utf-8" -d "grant_type=password" -d "username=${CF_OPS_MAN_GUI_USER}" -d "password="${CF_OPS_MAN_GUI_PASSWORD}"" -u 'opsman:' https://${CF_OPS_MAN_GUI_HOST}/uaa/oauth/token)
api_token=$(echo $api_token_json | jq -r .access_token)
expires_in=$(echo $api_token_json | jq -r .expires_in)
scopes=$(echo $api_token_json | jq -r .scope)
export PCF_OPS_MAN_API_TOKEN=$api_token
echo "Exported Ops Man API token as PCF_OPS_MAN_API_TOKEN which expires in $expires_in and includes scopes '$scopes'"