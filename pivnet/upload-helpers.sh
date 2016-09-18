#!/usr/bin/env bash

function getAvailableProductsUrl {
	api_prefix="https://$CF_OPS_MAN_GUI_HOST/api/v0"
	available_products_url="$api_prefix/available_products"
	echo $available_products_url
}

function getAvailableProducts {
	access_token=$1
	available_products_url=$(getAvailableProductsUrl)
	echo $(curl $available_products_url --insecure -H "Authorization: Bearer $access_token" | jq .)
}

function formatAvailableProducts {
	access_token=$1
	json=$(getAvailableProducts $access_token)
	echo $json | jq -r 'map({tile: .name, version: .product_version}) | .[] | .tile,.version'
}

