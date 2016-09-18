#!/usr/bin/env bash
set -e
: ${CF_BINARY_STORE:?"Need to set CF_BINARY_STORE non-empty"}
: ${CF_OPS_MAN_GUI_HOST:?"Need to set CF_OPS_MAN_GUI_HOST non-empty"}
: ${CF_OPS_MAN_GUI_USER:?"Need to set CF_OPS_MAN_GUI_USER non-empty"}
: ${CF_OPS_MAN_GUI_PASS:?"Need to set CF_OPS_MAN_GUI_PASS non-empty"}

api_token_json=$(curl -s -k -u 'opsman:' -G https://$CF_OPS_MAN_GUI_HOST/uaa/oauth/token --data-urlencode "username=$CF_OPS_MAN_GUI_USER" --data-urlencode "password=$CF_OPS_MAN_GUI_PASS" --data-urlencode "grant_type=password")
access_token=$(echo $api_token_json | jq -r .access_token)

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
if [[ -f $DIR/helpers.sh ]] ; then
		source "$DIR/helpers.sh"
		echo "Sourced $DIR/helpers.sh"
	else
		echo "Skipping source of helper script"
fi

pushd $CF_BINARY_STORE
echo "Looking for tiles and stemcells to upload..."
if ls | grep pivotal; then
	echo
else
	echo "No products to process"
fi
if ls | grep bosh-stemcell; then
	echo
else
	echo "No stemcells to process"
fi

echo "Checking available products..."
available_tiles=$(formatAvailableProducts $access_token)
declare -A available_versions
while IFS= read -r tile
		read -r version; do
	echo "Found $tile with version $version"
	version=${version//-*}
	echo "Will process as version $version"
	if [[ ${available_versions[$tile]+_} ]] ; then
		available_versions_array=${available_versions[$tile]}
		available_versions_array=(${available_versions_array[@]} $version)
		
		available_versions[$tile]=${available_versions_array[@]}
	else
		available_versions_array=($version)
		available_versions[$tile]=$available_versions_array
	fi
done <<< "$available_tiles"
shopt -s nullglob # prevents literal *.suffix being processed
for product in *.pivotal
do
	skip_tile=false
	tile_name=$(extractTileNameFromFile $product)
	product_version=$(extractProductVersionFromFile $product)
	echo "Checking for tile name $tile_name with version $product_version"
	for tile in "${!available_versions[@]}"
	do 
		if [ "$tile" = "$tile_name" ] ; then
			echo $tile --- ${available_versions[$tile]}
			for version in ${available_versions[$tile]}
			do
				if [ "$version" = "$product_version" ] ; then
					echo "Already uploaded $tile $version will skip"
					skip_tile=true
				fi
			done
		fi
	done
if [ "$skip_tile" = false ] ; then
	available_products_url=$(getAvailableProductsUrl)
	echo "Uploading $product to $available_products_url"
	curl $available_products_url -F "product[file]=@$product" --insecure -X POST -H "Authorization: Bearer $access_token"
fi
done	
for stemcell in bosh-stemcell*.tgz
do
	echo
	echo "Uploading $stemcell"
	curl -vvv "https://$CF_OPS_MAN_GUI_HOST/api/v0/stemcells" -F "stemcell[file]=@$stemcell" --insecure -X POST -H "Authorization: Bearer $access_token"
done
popd