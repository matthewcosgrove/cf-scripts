#!/usr/bin/env bash

CF_OPS_MAN_GUI_SSH_PORT="${CF_OPS_MAN_GUI_SSH_PORT:-22}"

: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}

source_file=products.json
script_destination="/home/ubuntu"
echo "Copying file $source_file to Ops Manager $script_destination. TIP: For fasttrack login use ../set-up-ssh-copy-key.sh to upload your ssh key to Ops Manager"
scp -P $CF_OPS_MAN_GUI_SSH_PORT $source_file ubuntu@$CF_OPS_MAN_GUI_HOST:$script_destination

# ssh username@machine VAR=value cmd cmdargs
cat prep-download-products.sh helpers.sh download-products.sh | ssh ubuntu@$CF_OPS_MAN_GUI_HOST -p $CF_OPS_MAN_GUI_SSH_PORT CF_PIVNET_TOKEN=$CF_PIVNET_TOKEN CF_BINARY_STORE=$script_destination "bash -s"


