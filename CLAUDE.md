# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

An Ansible playbook that provisions a highly-available k3s Kubernetes cluster with:
- **kube-vip** for control-plane VIP
- **MetalLB** for LoadBalancer IPs (layer2 or BGP)
- **Two Traefik instances** (internal + external IngressClass) deployed via Helm
- **Rancher** management UI deployed via Helm
- **cert-manager** for TLS

Targets Debian/Ubuntu/CentOS on x64/arm64/armhf. Optionally manages Proxmox LXC containers as cluster nodes.

## Initial setup

```bash
./repo-init.sh                        # creates inventory/my-cluster/ from sample
# then edit inventory/my-cluster/hosts.ini
# then edit inventory/my-cluster/group_vars/all.yml
```

Install Python dependencies and Ansible collections:

```bash
pip install -r requirements.txt
ansible-galaxy collection install -r collections/requirements.yml
```

## Key commands

| Task | Command |
|------|---------|
| Deploy cluster | `ansible-playbook site.yml` |
| Syntax check | `./test.sh` |
| Tear down cluster | `ansible-playbook reset.yml` |
| Reboot all nodes | `ansible-playbook reboot.yml` |
| Lint playbooks | `ansible-lint` |
| Lint YAML | `yamllint .` |

The `ansible.cfg` sets `inventory = inventory/my-cluster/hosts.ini` as the default, so `-i` is not required when that file exists.

## Playbook execution order (`site.yml`)

1. **proxmox_lxc** — optional; configures Proxmox LXC containers (only when `proxmox_lxc_configure: true`)
2. **prereq / download / raspberrypi / k3s_custom_registries** — node preparation on all cluster hosts
3. **k3s_server** — installs k3s on master nodes; first master uses `--cluster-init`, others join via the first master's IP
4. **k3s_agent** — installs k3s agent on worker nodes
5. **k3s_server_post** — deploys kube-vip (VIP DaemonSet), MetalLB (via manifests), applies MetalLB IP pool CRs
6. **helm** — installs Helm binary on first master
7. **cert-manager** — deploys cert-manager CRDs + controller
8. **traefik_internal** — deploys internal Traefik (default IngressClass) with MetalLB IP `traefik_int_endpoint_ip`
9. **traefik_external** — deploys external Traefik (IngressClass `traefik-external`) with `traefik_ext_endpoint_ip`
10. **rancher** — deploys Rancher via Helm

Steps 6–10 run only on `master[0]`.

## Configuration

All tunables live in `inventory/my-cluster/group_vars/all.yml` (sample at `inventory/sample/group_vars/all.yml`). Critical variables:

| Variable | Purpose |
|----------|---------|
| `k3s_version` | k3s release tag |
| `apiserver_endpoint` | kube-vip VIP address for the control plane |
| `k3s_token` | Shared secret for master↔master and master↔agent auth |
| `flannel_iface` | Network interface for flannel (typically `eth0` or `ens18`) |
| `metal_lb_ip_range` | IP range allocated to MetalLB (must include Traefik IPs) |
| `traefik_int_endpoint_ip` | First IP from MetalLB range, used by internal Traefik |
| `traefik_ext_endpoint_ip` | Second IP from MetalLB range, used by external Traefik |
| `deploy_traefik` | Set `false` to skip Traefik + cert-manager |
| `deploy_rancher` | Set `false` to skip Rancher |
| `proxmox_lxc_configure` | Set `true` only for Proxmox LXC deployments |

## Traefik configuration

Traefik chart values and middleware config are Jinja2 templates under each role's `templates/` directory:

- `roles/traefik_internal/templates/traefik-chart-values.yaml.j2` — Helm values (ports, replicas, LoadBalancer IP)
- `roles/traefik_internal/templates/traefik-config.yaml.j2` — Traefik middleware/config CRDs
- `roles/traefik_internal/templates/dashboard.yaml.j2` — IngressRoute for the Traefik dashboard

The same three files exist under `roles/traefik_external/templates/`. Keep filenames identical; the playbook references them by name.

## Ansible collections required

- `ansible.utils` — used for `ipwrap` filter in server init args
- `community.general`
- `ansible.posix`
- `kubernetes.core`

## Linting rules

`.ansible-lint` skips `fqcn-builtins`. `.yamllint` extends `default` with max line length 120 (warning level).
