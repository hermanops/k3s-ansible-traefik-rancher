#!/usr/bin/env bash
set -euo pipefail

INVENTORY="${INVENTORY:-inventory/my-cluster/hosts.ini}"

if [[ ! -f "$INVENTORY" ]]; then
	echo "Inventory file not found: $INVENTORY"
	echo "Run ./repo-init.sh first, then edit inventory/my-cluster/hosts.ini"
	exit 1
fi

ansible-playbook --syntax-check site.yml -i "$INVENTORY"