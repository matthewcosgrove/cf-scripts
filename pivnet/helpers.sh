#!/usr/bin/env bash

function getAccessToken {
	api_token_json=$(curl -s -k -u 'opsman:' -G https://$CF_OPS_MAN_GUI_HOST/uaa/oauth/token --data-urlencode "username=$CF_OPS_MAN_GUI_USER" --data-urlencode "password=$CF_OPS_MAN_GUI_PASS" --data-urlencode "grant_type=password")
	echo $api_token_json | jq -r .access_token
}

function getProductRelease {
	product_name=$1
	product_version=$2
	releases="https://network.pivotal.io/api/v2/products/$product_name/releases"
	product_response=$(curl -sfS "$releases")
	product_releases_raw_array=$(echo "$product_response" | jq [.releases[]])
	product_release=$(echo "$product_releases_raw_array" | jq --arg version "$product_version" '.[]  | select(.version==$version)')
	echo $product_release
}

function generateFileName {
	tile_name=$1
	version=$2
	if [[ ! $version =~ ^[0-9]+\.[0-9]+ ]]; then
		echo "Exiting due to validation error : Illegal argument for version number '$version'" >&2
		exit 1
	fi
	echo "${tile_name}_${version}.pivotal"
}

function extractTileNameAndVersionFromFile {
	file_name=$1
	tile_name_and_version=${file_name//.pivotal}
	echo $tile_name_and_version
}

function extractTileName {
	product_name_with_alias=$1
	if [[ $product_name_with_alias != *[';']* ]] ; then
		echo $product_name_with_alias
	else
		tile_name=${product_name_with_alias%%;*}
		echo $tile_name
	fi
}

function extractTileNameFromFile {
	file_name=$1
	tile_name_and_version=$(extractTileNameAndVersionFromFile $file_name)
	tile_name=${tile_name_and_version//_*.*.*}
	echo $tile_name
}

function extractProductVersionFromFile {
	file_name=$1
	tile_name_and_version=$(extractTileNameAndVersionFromFile $file_name)
	version=${tile_name_and_version#*_}
	echo $version
}

function extractProductName {
	product_name_with_alias=$1
	if [[ $product_name_with_alias != *[';']* ]] ; then
		echo $product_name_with_alias
	else
		product_name=${product_name_with_alias#*;}
		echo $product_name
	fi
}
