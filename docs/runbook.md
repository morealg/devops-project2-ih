# Runbook — Operational Guide

> This document provides step-by-step instructions for operating, troubleshooting,
> and recovering the Burger Builder application running on Azure.

---

## System Overview

| Component | Name | Address |
|---|---|---|
| Application Gateway | agw-bb-dev | 20.230.242.199 (public) |
| Frontend VM | vm-web-bb-dev | 10.20.2.4 (private) |
| Backend VM | vm-api-bb-dev | 10.20.3.4 (private) |
| Ops VM | vm-ops-bb-dev | 10.20.4.4 (private) |
| Frontend ILB | ilb-web-bb-dev | 10.20.2.10 |
| Backend ILB | ilb-api-bb-dev | 10.20.3.10 |
| SQL Database | burgerbuilderdb | Private Endpoint only |
| Key Vault | kv-bb-dev-team5 | Private Endpoint only |

> **Note:** All VMs are private. SSH access is only possible through the Ops VM.

---

## Access

### SSH into VMs (via Ops VM)

```bash
# Step 1 — SSH into Ops VM
ssh azureuser@vm-ops-bb-dev

# Step 2 — From Ops VM, SSH into other VMs
ssh azureuser@10.20.2.4   # Frontend VM
ssh azureuser@10.20.3.4   # Backend VM
```

---

## Health Checks

### Quick system check

```bash
# Frontend
curl -k https://20.230.242.199/

# Backend API
curl -k https://20.230.242.199/api/ingredients
```

Expected: HTTP 200 responses.

---

## Troubleshooting

### Problem: Site not loading (`https://20.230.242.199/` returns error)

1. Azure Portal → `agw-bb-dev` → **Backend health** tab
   - Check if the frontend backend pool is healthy
2. SSH into `vm-web-bb-dev`
3. Check Nginx status:
   ```bash
   sudo systemctl status nginx
   ```
4. If not running, start it:
   ```bash
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```
5. Check Nginx logs:
   ```bash
   sudo journalctl -u nginx -f
   ```

---

### Problem: API not responding (`/api/ingredients` returns error)

1. SSH into `vm-api-bb-dev`
2. Check backend service status:
   ```bash
   sudo systemctl status backend
   ```
3. If not running, start it:
   ```bash
   sudo systemctl start backend
   sudo systemctl enable backend
   ```
4. Check backend logs:
   ```bash
   sudo journalctl -u backend -n 100
   sudo journalctl -u backend -f
   ```

---

### Problem: Cannot connect to SQL Database

1. Azure Portal → `sql-bb-dev-team5` → verify **Public network access: Disabled**
2. Azure Portal → verify Private Endpoint `pe-sql-bb-dev` exists and is approved
3. SSH into `vm-api-bb-dev`, test DNS resolution:
   ```bash
   nslookup sql-bb-dev-team5.database.windows.net
   ```
   Expected: resolves to a private IP (10.20.5.x)
4. Check backend environment variables — connection string must be set correctly

---

### Problem: GitHub Actions pipeline failing

1. GitHub → **Actions** tab → find the failed workflow run
2. Click on the failed step to read the error message
3. If the self-hosted runner is offline:
   ```bash
   # SSH into Ops VM
   ssh azureuser@vm-ops-bb-dev
   cd /opt/actions-runner
   ./run.sh
   ```
4. If Ansible deployment step fails, check that inventory IPs are correct

---

### Problem: High CPU alert triggered

1. Azure Portal → **Monitor** → **Alerts** — identify which VM triggered the alert
2. SSH into the affected VM
3. Identify the process:
   ```bash
   top
   # or
   htop
   ```
4. If it is the application service, restart it:
   ```bash
   sudo systemctl restart nginx      # Frontend VM
   sudo systemctl restart backend    # Backend VM
   ```

---

### Problem: App Gateway backend health shows unhealthy

1. Azure Portal → `agw-bb-dev` → **Backend health**
2. Identify which pool is unhealthy (web or api)
3. Check the corresponding VM service (see above)
4. Check NSG rules — ensure App Gateway subnet can reach VM subnet

---

## Deployment

### Re-deploy frontend

```bash
cd /path/to/repo
git push origin main
# GitHub Actions frontend.yml triggers automatically
```

### Re-deploy backend

```bash
cd /path/to/repo
git push origin main
# GitHub Actions backend.yml triggers automatically
```

### Re-provision infrastructure (if needed)

```bash
cd infra/terraform/envs/dev
terraform init
terraform plan
terraform apply
```

---

## Monitoring

| Resource | Where to find |
|---|---|
| Live metrics | Azure Portal → `appi-api-bb-dev` → Live Metrics |
| Request logs | Azure Portal → `law-bb-dev` → Logs |
| Active alerts | Azure Portal → Monitor → Alerts |
| VM CPU/memory | Azure Portal → Virtual Machines → Metrics |

