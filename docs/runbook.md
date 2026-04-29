# Runbook — Operational Guide

> This runbook describes how to operate, validate, troubleshoot, and recover the Burger Builder Azure environment after deployment.

---

## System Overview

| Component | Name | Address / Access |
|---|---|---|
| Application Gateway | `agw-bb-dev` | `https://20.230.242.199/` |
| Frontend VM | `vm-web-bb-dev` | `10.20.2.4` private only |
| Backend VM | `vm-api-bb-dev` | `10.20.3.4` private only |
| Ops VM | `vm-ops-bb-dev` | `10.20.4.4` private only |
| Frontend ILB | `ilb-web-bb-dev` | `10.20.2.10` |
| Backend ILB | `ilb-api-bb-dev` | `10.20.3.10` |
| SQL Database | `burgerbuilderdb` | Private Endpoint only |
| Key Vault | `kv-bb-dev-team5` | Private Endpoint only |
| SonarQube | Docker on Ops VM | `http://localhost:9000` from ops VM |
| GitHub Runner | `ops-vm-runner` | Self-hosted runner on ops VM |

> All VMs are private. The normal operational path is Azure Run Command to the ops VM, then private access from inside the VNet.

---

## Access Model

### Preferred operator access

Use Azure Run Command from your laptop or admin workstation:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
hostname
'
```

### Reach private services from the ops VM

From the ops VM you can reach:

- frontend VM: `10.20.2.4`
- backend VM: `10.20.3.4`
- SonarQube: `http://localhost:9000`

Example:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
curl -I http://10.20.2.4
curl -f http://10.20.3.4:8080/actuator/health
'
```

---

## Standard Health Checks

### Public checks

Frontend:

```bash
curl -k https://20.230.242.199/
```

Backend public health:

```bash
curl -k https://20.230.242.199/api/health
```

Backend sample data:

```bash
curl -k https://20.230.242.199/api/ingredients
```

### Internal backend check

Run on the API VM:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-api-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
curl -f http://localhost:8080/actuator/health
'
```

Expected result:

- public frontend returns HTML
- `/api/health` returns JSON with `"status":"UP"`
- internal actuator check returns `"status":"UP"` and `"db":{"status":"UP"}`

---

## Deployment Operations

### CI/CD normal path

Push to `main` and let GitHub Actions handle:

- `infra.yml`
- `frontend.yml`
- `backend.yml`

The private deployment steps run on the self-hosted runner `ops-vm-runner`.

### Manual frontend redeploy

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
cd /home/azureuser/repo_clean/config/ansible
sudo -u azureuser ansible-playbook playbooks/deploy-frontend.yml \
  -i inventories/dev/hosts.yml \
  --extra-vars "artifact_path=/home/azureuser/repo_clean/frontend/dist"
'
```

### Manual backend redeploy

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
cd /home/azureuser/repo_clean/config/ansible
sudo -u azureuser ansible-playbook playbooks/deploy-backend.yml \
  -i inventories/dev/hosts.yml \
  --extra-vars "artifact_path=/home/azureuser/repo_clean/backend/target"
'
```

### Manual SonarQube redeploy

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
cd /home/azureuser/repo_clean/config/ansible
sudo -u azureuser ansible-playbook playbooks/deploy-sonarqube.yml \
  -i inventories/dev/hosts.yml
'
```

### Infrastructure reprovision

```bash
cd infra/terraform/envs/dev
terraform init
terraform plan
terraform apply
```

---

## Troubleshooting

### Problem: Public site does not load

1. Open Azure Portal -> `agw-bb-dev` -> `Backend health`
2. Confirm the web backend pool is healthy
3. Check Nginx on the web VM:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-web-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
sudo systemctl status nginx --no-pager -l
sudo journalctl -u nginx -n 50 --no-pager || true
'
```

4. Restart Nginx if needed:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-web-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
sudo systemctl restart nginx
sudo systemctl status nginx --no-pager -l
'
```

### Problem: Backend API does not respond

1. Check public backend health:

```bash
curl -k -i https://20.230.242.199/api/health
```

2. Check the backend service on the API VM:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-api-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
sudo systemctl status burgerbuilder-backend --no-pager -l || true
sudo journalctl -u burgerbuilder-backend -n 100 --no-pager || true
'
```

3. Restart if needed:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-api-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
sudo systemctl restart burgerbuilder-backend
sudo systemctl status burgerbuilder-backend --no-pager -l
'
```

### Problem: `/api/health` is healthy but `/api/actuator/health` fails

This is expected in the current design.

- App Gateway public path routing sends `/api/*` to the backend
- internal App Gateway probe goes directly to the backend on `/actuator/health`
- use `/api/health` for public smoke tests
- use `http://localhost:8080/actuator/health` for VM-local backend health

Do not change the App Gateway probe to `/api/actuator/health`.

### Problem: SQL connectivity issue

1. Confirm internal actuator still reports DB `UP`
2. Confirm SQL remains private-only
3. Check DNS resolution from the API VM:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-api-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
nslookup sql-bb-dev-team5.database.windows.net
'
```

Expected result:

- hostname resolves through private DNS to a private address

### Problem: Key Vault secret read fails during deploy

Verify the ops VM managed identity can read secrets:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
az login --identity --allow-no-subscriptions >/dev/null
az keyvault secret show \
  --vault-name kv-bb-dev-team5 \
  --name sql-admin-username \
  --query value -o tsv
'
```

If this fails with RBAC errors, re-check the Key Vault RBAC role assignment for the ops VM managed identity.

### Problem: GitHub self-hosted runner is offline

Check the runner service on the ops VM:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
cd /home/azureuser/actions-runner
sudo ./svc.sh status || true
'
```

If needed, start it:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
cd /home/azureuser/actions-runner
sudo ./svc.sh start
sudo ./svc.sh status || true
'
```

### Problem: SonarQube is unavailable

Check SonarQube from the ops VM:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
curl -I http://localhost:9000 || true
docker ps -a
'
```

If containers need investigation:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-ops-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
docker logs sonarqube --tail 100 || true
docker logs sonarqube-postgres --tail 50 || true
'
```

### Problem: High CPU alert triggered

1. Open Azure Portal -> `Monitor` -> `Alerts`
2. Identify the affected VM
3. Inspect the service
4. Restart only if the process is unhealthy

Backend restart:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-api-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
sudo systemctl restart burgerbuilder-backend
'
```

Frontend restart:

```bash
az vm run-command invoke \
  --resource-group project2-burgerbuilder-team-5 \
  --name vm-web-bb-dev \
  --command-id RunShellScript \
  --scripts '
set -e
sudo systemctl restart nginx
'
```

---

## Monitoring and Alerting

| What to Check | Where |
|---|---|
| Frontend telemetry | Azure Portal -> `appi-web-bb-dev` |
| Backend telemetry | Azure Portal -> `appi-api-bb-dev` |
| Platform diagnostics | Azure Portal -> Log Analytics workspace |
| Alerts | Azure Portal -> Monitor -> Alerts |
| Email notifications | Configured action group mailbox |

Alert coverage includes:

- Application Gateway backend health
- VM CPU threshold
- SQL utilization threshold

---

## Recovery Priorities

If the environment is degraded, recover in this order:

1. Confirm Application Gateway public availability
2. Confirm backend internal health on the API VM
3. Confirm SQL private connectivity
4. Confirm Key Vault secret access from the ops VM
5. Confirm GitHub runner and SonarQube availability

---

## Notes

- HTTPS uses a self-signed certificate for the demo environment, so browsers show a trust warning even though traffic is encrypted
- Internal load balancers keep the design ready for future VMSS scale-out, even though the current environment uses one VM per tier
- Public smoke tests should use `/api/health`, not `/api/actuator/health`
