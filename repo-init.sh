#!/usr/bin/env bash
set -euo pipefail

SRC="inventory/sample"
DST="inventory/my-cluster"

if [[ -d "$DST" ]]; then
	echo "Inventory already exists at $DST."
	echo "No changes made. Remove it first if you want a fresh copy."
	exit 0
fi

echo "Creating inventory path and copying sample to $DST ..."
cp -R "$SRC" "$DST"
echo "Done."
echo "===================================================================="
echo "Next step: Edit inventory/my-cluster/hosts.ini"
echo "Second: Edit inventory/my-cluster/group_vars/all.yml"
echo "===================================================================="
echo "More details are in README.md and CLAUDE.md"