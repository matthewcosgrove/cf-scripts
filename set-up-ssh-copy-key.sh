#!/bin/bash
set -e

: ${CF_OPS_MAN_GUI_USER:?"Need to set CF_OPS_MAN_GUI_USER non-empty"}
: ${CF_OPS_MAN_GUI_PASS:?"Need to set CF_OPS_MAN_GUI_PASS non-empty"}
: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}

CF_OPS_MAN_GUI_SSH_PORT="${CF_OPS_MAN_GUI_SSH_PORT:-22}"

if hash ssh-copy-id &>/dev/null
	then
		echo "ssh-copy-id is installed"
	else
		echo "Exiting as ssh-copy-id install required.. e.g. brew install ssh-copy-id"
		exit 1
fi

ssh-copy-id ubuntu@$CF_OPS_MAN_GUI_HOST -p $CF_OPS_MAN_GUI_SSH_PORT