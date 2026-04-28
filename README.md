# Azure 3-Tier Architecture — Burger Builder Application

## Project Overview
A full-stack Burger Builder web application deployed on a production-style 3-tier Azure architecture. The app is exposed only via Application Gateway (WAF v2) with private networking end-to-end.

## Architecture
The architecture diagram will be added at `docs/architecture-diagram.png` once the Terraform implementation is in place.

## Prerequisites
- Azure CLI installed and logged in (`az login`)
- Terraform >= 1.5
- Ansible >= 2.14
- Java 21
- Node.js 20
- GitHub repository access

## 1. Infrastructure Provisioning (Terraform)

Terraform folder scaffolding is ready under `infra/terraform/`.
The actual Terraform code will be added next.

### Bootstrap (run once)
```bash
cd infra/terraform/bootstrap
terraform init
terraform apply
```

### Main Infrastructure
```bash
cd infra/terraform
terraform init
terraform apply
```

## 2. Server Configuration (Ansible)
Ansible folder scaffolding is ready under `config/ansible/`.
Playbooks and inventory will be added as Person 2 implements the server configuration layer.

```bash
cd config/ansible
# Example future command once playbooks are added:
# ansible-playbook playbooks/site.yml -i inventories/dev/hosts.yml
```

## 3. Deploy (GitHub Actions)
Workflow scaffolding is present in `.github/workflows/`.
Deploy jobs are intentionally gated until private infrastructure and Ansible playbooks exist.

Push to `main` branch after implementation is ready:
- `infra.yml` — provisions infrastructure
- `frontend.yml` — builds and deploys React app
- `backend.yml` — builds and deploys Java app

## 4. Validation

### Test via App Gateway
```bash
curl -k https://20.230.242.199/
curl -k https://20.230.242.199/api/ingredients
```

### Verify Security
- VMs have no public IPs — verified in Azure Portal
- SQL public network access: Disabled — verified in Azure Portal  
- Key Vault public network access: Disabled — verified in Azure Portal
- Private Endpoints exist for SQL and Key Vault — verified in Azure Portal

## 5. Monitoring
- Application Insights — requests, failures, dependencies
- Log Analytics — platform diagnostics
- 3 Alerts configured:
  1. App Gateway Backend Health < 100% for 5 min
  2. VM CPU > 70% for 5 min
  3. SQL DTU > 80% for 5 min

## Kusto Queries

### All HTTP requests in last 1 hour
```kusto
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
| render piechart
```

### Slowest API endpoints
```kusto
requests
| where name startswith "/api"
| summarize avg(duration) by name
| order by avg_duration desc
| top 10
```

### Exceptions in last 24 hours
```kusto
exceptions
| where timestamp > ago(24h)
| summarize count() by type, outerMessage
| order by count_ desc
```

## Screenshots
See `docs/screenshots/` folder.

## Runbook
See `docs/runbook.md` for troubleshooting steps.

## Demo Script
See `docs/demo-script.md` for presentation walkthrough.
# pipeline test Tue Apr 28 14:22:56 +04 2026
