A set of useful scripts for setting up a PCF installation by downloading binaries from network.pivotal.io and uploading them to OpsManager. Tested with vSphere for PCF 1.7.

Recommended approach is to use the ssh wrapper scripts which are written specifically to be run on the OpsManager VM

1. Configure the products.json file with required products/versions
2. Ensure all env vars are set as required (see scripts for details)
3. ./ssh-and-download-products.sh
4. ./ssh-and-upload-products.sh

If you use the underlying scripts directly instead of the ssh wrapper scripts, be careful about where they are run, as latency will likely defy any attempts. A VM on the same network is best.
