#!/bin/bash

set -e

: ${CF_OPS_MAN_GUI_USER:?"Need to set CF_OPS_MAN_GUI_USER non-empty"}
: ${CF_OPS_MAN_GUI_PASSWORD:?"Need to set CF_OPS_MAN_GUI_PASSWORD non-empty"}
: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/export/util/opsman-api-token.sh"
: ${PCF_OPS_MAN_API_TOKEN:?"Need to set PCF_OPS_MAN_API_TOKEN non-empty"}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/export/util/ert-product-guid.sh"
: ${PCF_ERT_PRODUCT_GUID:?"Need to set PCF_ERT_PRODUCT_GUID non-empty"}

# TODO: DRY refactoring...
# Director
director_creds_response=$(curl -k -s -X GET "https://${CF_OPS_MAN_GUI_HOST}/api/v0/deployed/director/credentials/director_credentials" -H "Authorization: bearer $PCF_OPS_MAN_API_TOKEN")
echo "Ops Manager Director user: director"
echo $(echo $director_creds_response | jq -r .credential.value.password)
# ER
er_creds_response=$(curl -k -s -X GET "https://${CF_OPS_MAN_GUI_HOST}/api/v0/deployed/products/${PCF_ERT_PRODUCT_GUID}/credentials/.uaa.admin_credentials" -H "Authorization: bearer $PCF_OPS_MAN_API_TOKEN")
echo "Elastic Runtime user: admin"
echo $(echo $er_creds_response | jq -r .credential.value.password)
# Router status
router_status_creds_response=$(curl -k -s -X GET "https://${CF_OPS_MAN_GUI_HOST}/api/v0/deployed/products/${PCF_ERT_PRODUCT_GUID}/credentials/.router.status_credentials" -H "Authorization: bearer $PCF_OPS_MAN_API_TOKEN")
echo "Elastic Runtime user: router_status"
echo $(echo $router_status_creds_response | jq -r .credential.value.password)
# Admin client
admin_client_creds_response=$(curl -k -s -X GET "https://${CF_OPS_MAN_GUI_HOST}/api/v0/deployed/products/${PCF_ERT_PRODUCT_GUID}/credentials/.uaa.admin_client_credentials" -H "Authorization: bearer $PCF_OPS_MAN_API_TOKEN")
echo "Elastic Runtime user: admin_client"
echo $(echo $admin_client_creds_response | jq -r .credential.value.password)