A set of useful scripts for setting up a PCF installation by downloading binaries from network.pivotal.io and uploading them to OpsManager. Tested with vSphere for PCF 1.7. (Note that by 1.8 there should be better integration with PivNet but that remains to be seen)

#### Usage
The recommended approach is to use the ssh wrapper scripts which are written specifically to ssh onto and to be run on the OpsManager VM (which implies that the OpsManager has internet access)

1. Configure the products.json file with required products/versions*
2. Ensure all env vars are set as required (see scripts for details)
3. ./ssh-and-download-products.sh
4. ./ssh-and-upload-products.sh

TIP: For fasttrack login use ../set-up-ssh-copy-key.sh to upload your ssh key to Ops Manager prior to running the scripts in steps 3 & 4.

\* WARNING (Dirty workaround) the format of the product name in the products.json uses a workaround for the quirks of the Ops Manager API url formats. It is strict! 
The input is a simple json file with "product-name":"version" where the product-name is in the format "name;product-alias". Breaking this down, 'name' prior to the semi-colon, is the tile or product name as returned within the json response of 'https://$CF_OPS_MAN_GUI_HOST/api/v0/available_products' as the name as seen in this sample json response..

```json
[
{
"product_version": "1.7.12.0",
"name": "p-bosh"
},
{
"product_version": "1.7.9",
"name": "p-mysql"
},
{
"product_version": "1.7.15-build.17",
"name": "cf"
},
{
"product_version": "1.7.8",
"name": "p-mysql"
},
]
```
The product-alias, after the semi-colon, is used formulate the download url. For example the Elastic Runtime, has the name 'cf' but in the url formation we see 'elastic-runtime' as in 'https://network.pivotal.io/api/v2/products/elastic-runtime/releases/2134/product_files/5888/download' so this has been incorporated as the product-alias part of the input (apologies for the extra complexity but this is a knock on effect of inconsistent naming conventions in the API)

So the alias is only used for the initial urls, and when it comes to naming the binaries which get uploaded, those are named according to the approach seen above for 'https://$CF_OPS_MAN_GUI_HOST/api/v0/available_products'
 
If you use the underlying scripts directly instead of the ssh wrapper scripts (which are for running direct on the Ops Manager VM), be careful about where they are run, as latency will likely defy any attempts. A VM with internet access on the same network as OpsManager is best.
