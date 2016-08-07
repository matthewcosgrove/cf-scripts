#!/usr/bin/env bash

source_file=products.json
script_destination="/home/ubuntu"
echo "Copying file $source_file to Ops Manager $script_destination"
scp -P $CF_OPS_MAN_GUI_SSH_PORT $source_file ubuntu@$CF_OPS_MAN_GUI_HOST:$script_destination
# ssh username@machine VAR=value cmd cmdargs
cat prep-download-products.sh download-products.sh | ssh ubuntu@$CF_OPS_MAN_GUI_HOST -p $CF_OPS_MAN_GUI_SSH_PORT CF_PIVNET_TOKEN=$CF_PIVNET_TOKEN "bash -s" 


