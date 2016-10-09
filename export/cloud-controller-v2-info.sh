#!/bin/bash
set -e

: ${CF_CLOUD_CONTROLLER_HOST:?"Need to set CF_CLOUD_CONTROLLER_HOST non-empty"}

uaa_host=$(curl -k -s -X GET "https://${CF_CLOUD_CONTROLLER_HOST}/v2/info" | jq -r .token_endpoint)
export CF_UAA_HOST=${uaa_host#*//} # remove 'https://'
echo "Exported CF_UAA_HOST=${CF_UAA_HOST}"
