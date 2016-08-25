#!/usr/bin/env bash

echo "Preparing pre-requisites for downloading products.."

if hash jq &>/dev/null
	then
		jq_version=$(jq --version)
    	echo "Skipping jq install. Already installed: $jq_version"
	else
		echo "jq install required.."
    	sudo apt-get update
		sudo apt-get install jq
		jq --version
fi
