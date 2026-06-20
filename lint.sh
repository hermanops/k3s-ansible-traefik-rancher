#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="${VENV_PATH:-$ROOT_DIR/.venv}"

if [[ ! -d "$VENV_PATH" ]]; then
  echo "Virtual environment not found at: $VENV_PATH"
  echo "Create one first with: python3 -m venv .venv"
  exit 1
fi

# Use venv binaries directly without sourcing activate (ShellCheck-friendly).
export VIRTUAL_ENV="$VENV_PATH"
export PATH="$VENV_PATH/bin:$PATH"

# Ansible may require an explicit UTF-8 locale in some environments.
# Use the canonical UTF-8 form and force it to avoid inherited bad locales.
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

echo "Running syntax check..."
"$ROOT_DIR/test.sh"

echo "Running ansible-lint..."
ansible-lint --nocolor

echo "Running yamllint..."
yamllint .

echo "All local checks completed."