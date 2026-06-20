# Build a Highly Available k3s Cluster with Ansible

This project provisions a highly available k3s Kubernetes cluster with:

- kube-vip for a control-plane virtual IP
- MetalLB for LoadBalancer IP assignment
- dual Traefik ingress controllers (internal and external)
- Rancher management UI
- cert-manager for TLS

Based on:
- https://docs.technotim.live/posts/k3s-etcd-ansible/
- https://github.com/k3s-io/k3s-ansible

## Supported Platforms

Operating systems:
- Debian
- Ubuntu
- CentOS

Architectures:
- x64
- arm64
- armhf

## Requirements

- Python 3.12+ (recommended for latest Ansible ecosystem)
- Use a virtual environment for tooling
- SSH connectivity to all cluster nodes
- Privilege escalation rights on target nodes

## Quick Start

1. Create a working inventory:

```bash
./repo-init.sh
```

2. Edit:
- inventory/my-cluster/hosts.ini
- inventory/my-cluster/group_vars/all.yml

3. Install Python and Ansible dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
ansible-galaxy collection install -r collections/requirements.yml
```

4. Validate:

```bash
./test.sh
ansible-lint
yamllint .
```

5. Deploy:

```bash
./deploy.sh
```

## Common Commands

Deploy cluster:

```bash
ansible-playbook site.yml
```

Reset cluster:

```bash
ansible-playbook reset.yml
```

Reboot all nodes:

```bash
ansible-playbook reboot.yml
```

Run syntax check:

```bash
./test.sh
```

Run lint checks:

```bash
ansible-lint
yamllint .
```

Run all local checks with environment setup:

```bash
./lint.sh
```

## Inventory Notes

Default inventory path is configured in ansible.cfg:
- inventory/my-cluster/hosts.ini

All helper scripts also support overriding inventory via environment variable:

```bash
INVENTORY=inventory/my-cluster/hosts.ini ./deploy.sh
```

## Configuration

Main cluster variables live in:
- inventory/my-cluster/group_vars/all.yml

Template source for new clusters:
- inventory/sample/group_vars/all.yml

Important values to set correctly:
- apiserver_endpoint
- k3s_token
- flannel_iface
- metal_lb_ip_range
- traefik_int_endpoint_ip
- traefik_ext_endpoint_ip

traefik_int_endpoint_ip and traefik_ext_endpoint_ip must be inside metal_lb_ip_range.

## Getting kubeconfig

Copy kubeconfig from one master node:

```bash
scp <user>@<master_ip>:~/.kube/config ~/.kube/config
```

## Additional Documentation

- Project walkthrough: https://thepcgeek.net/posts/ansible-to-k3s-rancher/
- kube-vip docs: https://kube-vip.io/control-plane/
- MetalLB docs: https://metallb.universe.tf/installation/
- k3s HA docs: https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/
- Maintainer-oriented repo notes: CLAUDE.md

## Tooling Notes

- Use a Python virtual environment and keep toolchain components updated together (`ansible`, `ansible-lint`, `yamllint`, and collections).
- Let collection metadata dictate minimum supported ansible-core for your environment.
- On WSL/Ubuntu, if Ansible reports locale errors, set:
  - `LANG=en_US.UTF-8`
  - `LC_ALL=en_US.UTF-8`
- If your shell aliases `grep` to `rg`, commands like `grep -E ...` may fail unexpectedly.

Quick checks:

```bash
type grep
alias grep
ansible-lint --version
ansible-galaxy collection list community.general
```

## Notes on Master Scheduling

This project does not automatically taint control-plane nodes with criticaladdonsonly=noexecute.
If you need dedicated control-plane nodes, apply taints after deployment.
