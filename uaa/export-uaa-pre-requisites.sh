#!/usr/bin/env bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/../export/cloud-controller-v2-info.sh"
: ${CF_UAA_HOST:?"Need to set CF_UAA_HOST non-empty"}

echo "Host: $CF_UAA_HOST"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/export-uaa-access-token.sh"
: ${CF_UAA_ACCESS_TOKEN:?"Need to set CF_UAA_ACCESS_TOKEN non-empty"}

#clients=$(curl -sk -H "Authorization: Bearer $CF_UAA_ACCESS_TOKEN" https://$CF_UAA_HOST/oauth/clients)
#echo $clients | jq .

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/export-new-client-authorities.sh"
: ${CF_UAA_NEW_CLIENT_AUTHORITIES:?"Need to set CF_UAA_NEW_CLIENT_AUTHORITIES non-empty"}