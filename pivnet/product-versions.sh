#!/bin/bash

set -e

arg1=$1
no_of_versions="${arg1:-"5"}"

CF_PIVNET_TILES="${CF_PIVNET_TILES:-"elastic-runtime p-spring-cloud-services p-mysql"}"

: ${CF_PIVNET_TILES:?"Need to set CF_PIVNET_TILES non-empty"}

arr=($CF_PIVNET_TILES)
echo "To override defaults..."
echo "1) create env var CF_PIVNET_TILES as a space seperated set of 'slug' from https://network.pivotal.io/api/v2/products/"
echo "2) pass in an arg to set the amount of previous versions to show for each product"
echo "Getting versions for tiles: $CF_PIVNET_TILES"
for i in "${arr[@]}"
do
	tile_name=$i
	tile_response=$(curl -s "https://network.pivotal.io/api/v2/products/$tile_name/releases")

	raw_array=$(echo "$tile_response" | jq .releases[])
	flat_version_json=$(echo "$raw_array" | jq '[. | {version: .version}]')
	filtered_out_edge_version_json=$(echo "$flat_version_json" | jq '. - map(select(.version | contains ("edge")))')
	filtered_out_beta_version_json=$(echo "$filtered_out_edge_version_json" | jq '. - map(select(.version | contains ("BETA")))')
	filtered_version_list=$(echo "$filtered_out_beta_version_json" | jq '.[] | .version')
	# http://stackoverflow.com/questions/4493205/unix-sort-of-version-numbers
	sorted_version_list=$(echo "$filtered_version_list" | sort -t. -k 1,1nr -k 2,2nr -k 3,3nr -k 4,4nr)

	echo 
	echo "Latest $no_of_versions versions of $tile_name are..."
	echo "$sorted_version_list" | head -$no_of_versions
done





