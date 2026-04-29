# Azure 3-Tier Architecture — Burger Builder

> A production-style cloud deployment on Microsoft Azure, built by a 4-person team.  
> The application is publicly accessible only through an Application Gateway WAF v2 — all backend compute and data resources are fully private.

---

## Architecture Overview

```
Internet (HTTPS)
       │
       ▼
App Gateway WAF v2 — 20.230.242.199
       │                    │
       ▼                    ▼
ilb-web-bb-dev        ilb-api-bb-dev
  (10.20.2.10)          (10.20.3.10)
       │                    │
       ▼                    ▼
vm-web-bb-dev         vm-api-bb-dev
  Nginx / React         Java Spring Boot
  (10.20.2.4)           (10.20.3.4)
                              │
                              ▼
                       Azure SQL Database
                       (Private Endpoint)

vm-ops-bb-dev — GitHub Runner + SonarQube
Key Vault — Secrets (Private Endpoint)
```

![Architecture Diagram](docs/architecture-diagram.png)

---

## Technology Stack

| Layer | Technology |
|---|---|
| Infrastructure as Code | Terraform |
| Configuration Management | Ansible |
| CI/CD | GitHub Actions |
| Frontend | React + Vite (Nginx) |
| Backend | Java 21 + Spring Boot |
| Database | Azure SQL |
| Secret Management | Azure Key Vault |
| Monitoring | Azure Monitor + Application Insights |
| Security | Azure WAF v2 + NSGs + Private Endpoints |

---

## Prerequisites

Before provisioning, ensure the following tools are installed and configured:

- Azure CLI — `az login` completed
- Terraform >= 1.5
- Ansible >= 2.14
- Java 21
- Node.js 20
- GitHub repository access with collaborator permissions

---

## 1. Infrastructure Provisioning (Terraform)

All infrastructure is defined as code under `infra/terraform/`.

### Bootstrap (run once — creates remote state storage)

```bash
cd infra/terraform/bootstrap
terraform init
terraform apply
```

### Main Infrastructure

```bash
cd infra/terraform/envs/dev
terraform init
terraform plan
terraform apply
```

This provisions the following resources:
- Virtual Network with 5 subnets
- Application Gateway WAF v2
- 2 Internal Load Balancers
- 3 Linux VMs (web, api, ops)
- Azure SQL Server + Database (private)
- Azure Key Vault (private)
- Private Endpoints for SQL and Key Vault
- Network Security Groups

---

## 2. Server Configuration (Ansible)

All VM configuration is automated via Ansible under `ansible/`.

```bash
cd ansible
ansible-playbook site.yml -i inventories/dev/hosts.yml
```

This playbook:
- Hardens all VMs (firewall, time sync, package updates)
- Installs and configures Nginx on the frontend VM
- Installs Java 21 and configures the Spring Boot service on the backend VM
- Sets up GitHub Actions self-hosted runner and SonarQube on the ops VM

---

## 3. CI/CD Pipelines (GitHub Actions)

Three automated pipelines are configured under `.github/workflows/`:

| Workflow | Trigger | What it does |
|---|---|---|
| `infra.yml` | Push to `main` | Terraform init → plan → apply |
| `frontend.yml` | Push to `main` | Build → Test → Deploy to vm-web-bb-dev |
| `backend.yml` | Push to `main` | Build → Test → SonarQube scan → Deploy to vm-api-bb-dev |

Deployments use a **hybrid runner model**:
- GitHub-hosted runners for build and test
- Self-hosted runner on `vm-ops-bb-dev` for private network deployments

---

## 4. Validation

### Functional Tests

```bash
# Test frontend
curl -k https://20.230.242.199/

# Test backend API
curl -k https://20.230.242.199/api/ingredients
```

### Security Verification

| Check | Expected Result | Verified |
|---|---|---|
| VM public IPs | None — all VMs are private | ✅ |
| SQL public network access | Disabled | ✅ |
| Key Vault public network access | Disabled | ✅ |
| Private Endpoints | Exist for SQL and Key Vault | ✅ |
| WAF | Enabled on Application Gateway | ✅ |

---

## 5. Monitoring & Observability

### Resources

| Resource | Name |
|---|---|
| Log Analytics Workspace | `law-bb-dev` |
| Application Insights (Frontend) | `appi-web-bb-dev` |
| Application Insights (Backend) | `appi-api-bb-dev` |

### Alerts

| Alert | Condition | Severity |
|---|---|---|
| App Gateway Unhealthy Host | Count > 0 | Error |
| VM High CPU | CPU > 70% for 5 min | Warning |
| SQL High DTU | DTU > 80% for 5 min | Warning |

### Kusto Queries

**All HTTP requests in the last hour:**
```kusto
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
| render piechart
```

**Slowest API endpoints:**
```kusto
requests
| where name startswith "/api"
| summarize avg(duration) by name
| order by avg_duration desc
| top 10
```

**Exceptions in the last 24 hours:**
```kusto
exceptions
| where timestamp > ago(24h)
| summarize count() by type, outerMessage
| order by count_ desc
```

---

## Project Structure

```
devops-project2-ih/
├── .github/workflows/       # CI/CD pipelines
├── frontend/                # React + Vite application
├── backend/                 # Java Spring Boot application
├── infra/terraform/         # Infrastructure as Code
│   ├── bootstrap/           # Remote state setup
│   ├── envs/dev/            # Environment configuration
│   └── modules/             # Reusable Terraform modules
├── ansible/                 # Server configuration playbooks
└── docs/                    # Documentation
    ├── architecture-diagram.png
    ├── runbook.md
    ├── demo-script.md
    ├── validation.md
    └── screenshots/
```

---

## Documentation

| Document | Description |
|---|---|
| [Runbook](docs/runbook.md) | Operational guide — troubleshooting steps |
| [Validation Report](docs/validation.md) | Proof of all acceptance criteria |
| [Demo Script](docs/demo-script.md) | Presentation walkthrough |
| [Screenshots](docs/screenshots/) | Azure Portal evidence |



