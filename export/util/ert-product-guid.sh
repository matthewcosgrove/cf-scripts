#!/bin/bash

set -e

: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}
: ${PCF_OPS_MAN_API_TOKEN:?"Need to set PCF_OPS_MAN_API_TOKEN non-empty"}

product_guid=$(curl -k -s -X GET "https://${CF_OPS_MAN_GUI_HOST}/api/v0/deployed/products" -H "Authorization: bearer $PCF_OPS_MAN_API_TOKEN" | jq -r '.[] | select(.type=="cf") | .guid')
export PCF_ERT_PRODUCT_GUID=$product_guid
echo "Exported PCF_ERT_PRODUCT_GUID=${PCF_ERT_PRODUCT_GUID}"
