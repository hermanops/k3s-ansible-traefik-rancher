# AGENTS.md

This repository provisions a highly-available k3s cluster with kube-vip, MetalLB, dual Traefik instances, Rancher, and cert-manager using Ansible.

For full setup and architecture details, start with:
- [CLAUDE.md](CLAUDE.md)
- [README.md](README.md)

## Fast Start For Agents

1. Initialize inventory for a new cluster:
   - `./repo-init.sh`
2. Install local dependencies:
   - `pip install -r requirements.txt`
   - `ansible-galaxy collection install -r collections/requirements.yml`
3. Validate before changes and before final handoff:
   - `./test.sh`
   - `ansible-lint`
   - `yamllint .`

## Common Commands

- Deploy cluster: `ansible-playbook site.yml`
- Tear down cluster: `ansible-playbook reset.yml`
- Reboot all nodes: `ansible-playbook reboot.yml`

Default inventory is set in `ansible.cfg` to `inventory/my-cluster/hosts.ini`.

## Project Boundaries

- Top-level playbooks:
  - `site.yml`: full provisioning flow
  - `reset.yml`: remove cluster components
  - `reboot.yml`: reboot all cluster nodes
- Main role areas:
  - `roles/k3s_server`: server install/bootstrap, kube-vip, MetalLB bootstrap pieces
  - `roles/k3s_agent`: worker node join
  - `roles/k3s_server_post`: MetalLB CRs
  - `roles/traefik_internal` and `roles/traefik_external`: dual ingress setup
  - `roles/cert_manager`, `roles/rancher`, `roles/helm`: control-plane add-ons

## High-Importance Conventions

- Keep Traefik template filenames aligned across both roles:
  - `roles/traefik_internal/templates/traefik-chart-values.yaml.j2`
  - `roles/traefik_external/templates/traefik-chart-values.yaml.j2`
  - `roles/traefik_internal/templates/traefik-config.yaml.j2`
  - `roles/traefik_external/templates/traefik-config.yaml.j2`
  - `roles/traefik_internal/templates/dashboard.yaml.j2`
  - `roles/traefik_external/templates/dashboard.yaml.j2`
- Keep `traefik_int_endpoint_ip` and `traefik_ext_endpoint_ip` inside `metal_lb_ip_range`.
- Respect toggle flags from inventory variables (`deploy_traefik`, `deploy_rancher`, `proxmox_lxc_configure`, `custom_registries`).
- Preserve role/task layout (`roles/<role>/tasks/main.yml` plus included task files).

## Where To Edit Configuration

- Template source for new cluster config:
  - `inventory/sample/group_vars/all.yml`
- Runtime cluster config after init:
  - `inventory/my-cluster/group_vars/all.yml`

When changing defaults or adding variables, keep naming consistent with existing `group_vars` and role defaults.

## Validation Expectations For PRs

Before finishing substantial changes, run:
- `./test.sh`
- `ansible-lint`
- `yamllint .`

If a command cannot run in the current environment, explicitly report what was skipped and why.
