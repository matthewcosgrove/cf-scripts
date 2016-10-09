#!/bin/bash

set -e

: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/util/opsman-api-token.sh"
: ${PCF_OPS_MAN_API_TOKEN:?"Need to set PCF_OPS_MAN_API_TOKEN non-empty"}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/util/ert-product-guid.sh"
: ${PCF_ERT_PRODUCT_GUID:?"Need to set PCF_ERT_PRODUCT_GUID non-empty"}

admin_client_creds_response=$(curl -k -s -X GET "https://${CF_OPS_MAN_GUI_HOST}/api/v0/deployed/products/${PCF_ERT_PRODUCT_GUID}/credentials/.uaa.admin_client_credentials" -H "Authorization: bearer $PCF_OPS_MAN_API_TOKEN")
admin_client_password=$(echo $admin_client_creds_response | jq -r .credential.value.password)

export PCF_ADMIN_CLIENT_PASSWORD=$admin_client_password
echo "Exported PCF_ADMIN_CLIENT_PASSWORD=***********"
