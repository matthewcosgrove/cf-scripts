#!/usr/bin/env bash

echo "About to download products.."
jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" products.json

if [[ $BASH_VERSION != 4* ]] ; then
	echo "Error: Use of associative arrays requires Bash 4. Detected version $BASH_VERSION"
	echo "NB: Might be error prone when Bash 5 is released ;-)"
fi
: ${CF_PIVNET_TOKEN:?"Need to set CF_PIVNET_TOKEN non-empty where token can be retrieved from edit-profile page of network.pivotal.io"}
: ${CF_BINARY_STORE:?"Need to set CF_BINARY_STORE non-empty"}

declare -A arr
while IFS="=" read -r key value
do
    arr[$key]="$value"
done < <(jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" products.json)

function getProductRelease {
	product_name=$1
	product_version=$2
	releases="https://network.pivotal.io/api/v2/products/$product_name/releases"
	product_response=$(curl -sfS "$releases")
	product_releases_raw_array=$(echo "$product_response" | jq [.releases[]])
	product_release=$(echo "$product_releases_raw_array" | jq --arg version "$product_version" '.[]  | select(.version==$version)')
	
	echo $product_release
}

echo "Validating config and PivNet API e.g. checking versions exist and urls are consistent"
for product_name in "${!arr[@]}"
do
	product_version=${arr[$product_name]}
	echo "Checking $product_name = $product_version"
	product_release=$(getProductRelease $product_name $product_version)
	hasVersion=$(echo $product_release | jq '. | has("id")')
	if [[ "$hasVersion" != "true" ]] ; then
		releases="https://network.pivotal.io/api/v2/products/$product_name/releases"
		echo "Please check version $product_version of $product_name exists at $releases and try again"
		exit 1
	fi
	link_product_files=$(echo $product_release | jq -r ._links.product_files.href)
	product_files_response=$(curl -sfS "$link_product_files")
	product_files_array=$(echo "$product_files_response" | jq [.product_files[]])
	product_files_array_size=$(echo $product_files_array | jq '. | length')
	echo $product_files_array_size
	if [[ $product_files_array_size = 0 ]] ; then 
		echo $link_product_files
		echo "the above link has no product files for $product_name $product_version, raise a support case at support.pivotal.io"
		echo "In the meantime, try a different version or remove from input and download manually. NOTE: Rabbit MQ is missing the link on all versions at the time of writing (See https://network.pivotal.io/api/v2/products/pivotal-rabbitmq/releases/)"
		echo "Apologies, but we need to exit, please retry again once you have dealt with this issue"
		exit 1
	fi
	if [[ $product_files_array_size > 1 ]] ; then
		echo "Multiple product files detected. Need to do some convoluted stuff with the response array.."
		if [[ $product_name = "elastic-runtime" || $product_name = "ops-metrics" ]] ; then
			echo "Specific support for $product_name has been added (it has array size $product_files_array_size), so the product will be processed"
		else
			nameOfZeroIndex=$(echo $product_files_array | jq -r .[0].aws_object_key)
			echo "Product files array size = $nameOfZeroIndex"
			if [[ $nameOfZeroIndex == *.pivotal ]] ; then
				echo "$product_name has array size $product_files_array_size but the .pivotal file is in expected location of index 0, so the product will be processed"
			else
				echo "$product_name $product_version not supported as .pivotal file not at index 0 as expected. Please update script or remove product from products.json input file"
				exit 1
			fi
		fi
	fi
	link_product_files=$(echo $product_release | jq -r ._links.product_files.href)
	product_files_response=$(curl -sfS "$link_product_files")
	if [[ $product_name = "elastic-runtime" ]] ; then
		link_product_download=$(echo "$product_files_response" | jq [.product_files[]] | jq --arg name "PCF Elastic Runtime" '.[]  | select(.name==$name)' | jq -r ._links.download.href)
	elif [[ $product_name = "ops-metrics" ]] ; then
		link_product_download=$(echo "$product_files_response" | jq [.product_files[]] | jq --arg name "PCF JMX Bridge" '.[]  | select(.name==$name)' | jq -r ._links.download.href)
	else
		link_product_download=$(echo "$product_files_response" | jq -r .product_files[0]._links.download.href)
	fi
	echo "Will be downloading from $link_product_download"
done

for product_name in "${!arr[@]}"
do
	product_version=${arr[$product_name]}
	file_loc_and_name=$CF_BINARY_STORE/"${product_name}-${product_version}.pivotal"
	if [[ -f $file_loc_and_name ]] ; then
		echo "File $file_loc_and_name already downloaded so skipping"
		continue
	fi
	echo "Handling $product_name = $product_version"
	product_release=$(getProductRelease $product_name $product_version)
	link_eula=$(echo $product_release | jq -r ._links.eula_acceptance.href)
	echo "Accepting EULA at $link_eula"
	curl -s -X POST ${link_eula} --header "Authorization: Token ${CF_PIVNET_TOKEN}"
	echo
	echo
	link_product_files=$(echo $product_release | jq -r ._links.product_files.href)
	product_files_response=$(curl -sfS "$link_product_files")
	if [[ $product_name = "elastic-runtime" ]] ; then
		link_product_download=$(echo "$product_files_response" | jq [.product_files[]] | jq --arg name "PCF Elastic Runtime" '.[]  | select(.name==$name)' | jq -r ._links.download.href)
	elif [[ $product_name = "ops-metrics" ]] ; then
		link_product_download=$(echo "$product_files_response" | jq [.product_files[]] | jq --arg name "PCF JMX Bridge" '.[]  | select(.name==$name)' | jq -r ._links.download.href)
	else
		link_product_download=$(echo "$product_files_response" | jq -r .product_files[0]._links.download.href)
	fi
	echo "Downloading from $link_product_download"
	mkdir -p $CF_BINARY_STORE
	wget -O $file_loc_and_name --post-data="" --header="Authorization: Token ${CF_PIVNET_TOKEN}" ${link_product_download}
done

