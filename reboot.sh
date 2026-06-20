#!/usr/bin/env bash
set -euo pipefail

INVENTORY="${INVENTORY:-inventory/my-cluster/hosts.ini}"
ansible-playbook reboot.yml -i "$INVENTORY"
