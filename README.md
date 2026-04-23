# Azure 3-Tier Architecture — Burger Builder Application

## Project Overview
A full-stack Burger Builder web application deployed on a production-style 3-tier Azure architecture. The app is exposed only via Application Gateway (WAF v2) with private networking end-to-end.

## Architecture
![Architecture Diagram](docs/architecture-diagram.png)

## Prerequisites
- Azure CLI installed and logged in (`az login`)
- Terraform >= 1.5
- Ansible >= 2.14
- Java 21
- Node.js 20
- GitHub repository access

## 1. Infrastructure Provisioning (Terraform)

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
```bash
cd config/ansible
ansible-playbook site.yml -i inventories/dev/hosts.yml
```

## 3. Deploy (GitHub Actions)
Push to `main` branch — pipelines run automatically:
- `infra.yml` — provisions infrastructure
- `frontend.yml` — builds and deploys React app
- `backend.yml` — builds and deploys Java app

## 4. Validation

### Test via App Gateway
```bash
curl http://<AGW_PUBLIC_IP>/
curl http://<AGW_PUBLIC_IP>/api/health
```

### Verify Security
```bash
# This should FAIL (SQL is private)
curl http://<SQL_SERVER>.database.windows.net
```

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
