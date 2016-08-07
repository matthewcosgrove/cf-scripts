#!/usr/bin/env bash

echo "About to download products.."
jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" products.json

if [[ $BASH_VERSION != 4* ]] ; then
	echo "Error: Use of associative arrays requires Bash 4. Detected version $BASH_VERSION"
fi
: ${CF_PIVNET_TOKEN:?"Need to set CF_PIVNET_TOKEN non-empty where token can be retrieved from edit-profile page of network.pivotal.io"}

declare -A arr
while IFS="=" read -r key value
do
    arr[$key]="$value"
done < <(jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" products.json)

for product_name in "${!arr[@]}"
do
    product_version=${arr[$product_name]}
    echo "Handling $product_name = $product_version"
    product_response=$(curl -sfS "https://network.pivotal.io/api/v2/products/$product_name/releases")
	product_releases_raw_array=$(echo "$product_response" | jq [.releases[]])
	product_release=$(echo "$product_releases_raw_array" | jq --arg version "$product_version" '.[]  | select(.version==$version)')
	link_eula=$(echo $product_release | jq -r ._links.eula_acceptance.href)
	echo "Accepting EULA at $link_eula"
	curl -s -X POST ${link_eula} --header "Authorization: Token ${CF_PIVNET_TOKEN}"
	echo
	echo
	link_product_files=$(echo $product_release | jq -r ._links.product_files.href)
	product_files_response=$(curl -sfS "$link_product_files")
	link_product_download=$(echo "$product_files_response" | jq -r .product_files[0]._links.download.href)
	wget -O "${product_name}-${product_version}.pivotal" --post-data="" --header="Authorization: Token ${CF_PIVNET_TOKEN}" ${link_product_download}
done

