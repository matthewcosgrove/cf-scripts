#!/usr/bin/env bash
set -e

export CF_UAA_NEW_CLIENT_AUTHORITIES='"uaa.admin","clients.read","clients.write","clients.secret","scim.read","scim.write","clients.admin"'
