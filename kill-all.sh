#!/usr/bin/env bash
set -euo pipefail

INVENTORY="${INVENTORY:-inventory/my-cluster/hosts.ini}"
ansible-playbook reset.yml -i "$INVENTORY"
