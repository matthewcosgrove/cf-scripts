#!/usr/bin/env bash

echo Input file..
json=echo cat input-map.json | jq '.'
echo $json
# http://stackoverflow.com/questions/26717277/converting-a-json-array-to-a-bash-array
# jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" input-map.json

if [[ $BASH_VERSION != 4* ]] ; then
	echo "Warning: Use of associative arrays requires Bash 4. Detected version $BASH_VERSION"
fi
declare -A myarray
while IFS="=" read -r key value
do
    myarray[$key]="$value"
done < <(jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" input-map.json)

echo Result of json processed as map...
for key in "${!myarray[@]}"
do
    echo "$key = ${myarray[$key]}"
done


