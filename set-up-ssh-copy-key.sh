#!/usr/bin/env bash

set -e

: ${CF_OPS_MAN_GUI_USER:?"Need to set CF_OPS_MAN_GUI_USER non-empty"}
: ${CF_OPS_MAN_GUI_PASS:?"Need to set CF_OPS_MAN_GUI_PASS non-empty"}
: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}

CF_OPS_MAN_GUI_SSH_PORT="${CF_OPS_MAN_GUI_SSH_PORT:-22}"

if hash ssh-copy-id &>/dev/null
	then
		echo "ssh-copy-id is installed"
	else
		if [ "$(uname)" == "Darwin" ]; then
			brew install ssh-copy-id
		elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
			echo "Exiting as ssh-copy-id install required..but you are on Linux so this is surely not possible?"
			exit 1
		elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
			echo "Fingers crossed. Attempting Windows voodoo...(btw hope you have an id_rsa.pub)"
			cat ~/.ssh/id_rsa.pub | ssh ubuntu@$CF_OPS_MAN_GUI_HOST -p $CF_OPS_MAN_GUI_SSH_PORT "cat >> ~/.ssh/authorized_keys"
			echo "My eyes are still closed. Did we do it?"
			exit 1
		else
			echo "Exiting as ssh-copy-id install required. Best of luck.."
			exit 1
		fi
fi
echo "Public key will be copied to OpsManager"
ssh-copy-id ubuntu@$CF_OPS_MAN_GUI_HOST -p $CF_OPS_MAN_GUI_SSH_PORT