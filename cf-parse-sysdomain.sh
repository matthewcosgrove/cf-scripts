#!/bin/bash

set -e

prefix="API endpoint: https://api."
suffix=" (API version: 2.54.0)" # Leaving for reference only
api_out=$(cf api)

tmp=${api_out#$prefix}
sysdomain=${tmp% * * *} # suffix could change so using wildcards
echo $sysdomain