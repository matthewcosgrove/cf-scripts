#!/usr/bin/env bash

CF_OPS_MAN_GUI_SSH_PORT="${CF_OPS_MAN_GUI_SSH_PORT:-22}"

: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}
upload_host="localhost"

: ${CF_OPS_MAN_GUI_USER:?"Need to set CF_OPS_MAN_GUI_USER non-empty"}
: ${CF_OPS_MAN_GUI_PASS:?"Need to set CF_OPS_MAN_GUI_PASS non-empty"}

file_destination="/home/ubuntu" # IMPORTANT: Must correspond with script_destination in ssh-and-download-products.sh

echo "TIP: For fasttrack login use ../set-up-ssh-copy-key.sh to upload your ssh key to Ops Manager"

# ssh username@machine VAR=value cmd cmdargs
cat upload-helpers.sh helpers.sh upload-products.sh | ssh ubuntu@$CF_OPS_MAN_GUI_HOST -p $CF_OPS_MAN_GUI_SSH_PORT CF_PIVNET_TOKEN=$CF_PIVNET_TOKEN CF_BINARY_STORE=$file_destination CF_OPS_MAN_GUI_HOST=$upload_host CF_OPS_MAN_GUI_USER=$CF_OPS_MAN_GUI_USER CF_OPS_MAN_GUI_PASS=$CF_OPS_MAN_GUI_PASS "bash -s"
