# Person 1 Infrastructure Handoff

## Purpose

This document summarizes:
- what Person 1 has completed
- what is still remaining for Person 1
- what other teammates need from Person 1
- the key Azure outputs and infrastructure details for the team

This file is meant to be committed with the Terraform work so the team always has an up-to-date infrastructure reference.

---

## Current Status

Person 1 has completed the core Azure foundation for the project.

### Current completion estimate
- Core infrastructure: mostly done
- Approximate Person 1 progress: `70% to 80%`

The hardest part of the infrastructure work is already completed.

---

## What Person 1 Has Completed

### 1. Terraform foundation
- Terraform remote state bootstrap created
- Azure Storage Account for Terraform state created
- Blob container for Terraform state created
- `envs/dev` configured to use remote state

### 2. Networking
- VNet created: `vnet-bb-dev`
- Address space: `10.20.0.0/16`

Subnets created:
- `snet-agw` = `10.20.1.0/24`
- `snet-web` = `10.20.2.0/24`
- `snet-api` = `10.20.3.0/24`
- `snet-ops` = `10.20.4.0/24`
- `snet-private-endpoints` = `10.20.5.0/24`

### 3. NSG foundation
- NSGs created for:
  - web
  - api
  - ops
  - private endpoints
- NSGs are attached to the correct subnets
- Further hardening is still pending

### 4. Azure SQL private setup
- Azure SQL Server created: `sql-bb-dev-team5`
- Database created: `burgerbuilderdb`
- SQL public network access disabled
- Private Endpoint created for SQL
- Private DNS Zone created: `privatelink.database.windows.net`
- Private DNS VNet link created

### 5. Key Vault private setup
- Key Vault created: `kv-bb-dev-team5`
- Key Vault public network access disabled
- Private Endpoint created for Key Vault
- Private DNS Zone created: `privatelink.vaultcore.azure.net`
- Private DNS VNet link created

Important note:
- planned secret names exist in outputs
- actual secrets are not yet inserted because Key Vault is private-only and Terraform is running from outside the VNet

### 6. Compute layer
Three private Ubuntu 22.04 VMs created:
- `vm-web-bb-dev`
- `vm-api-bb-dev`
- `vm-ops-bb-dev`

VM admin username:
- `azureuser`

Authentication:
- SSH key only
- no password login

No VM has a public IP.

### 7. Internal load balancers
- Frontend ILB created: `ilb-web-bb-dev`
- Frontend ILB IP: `10.20.2.10`
- Backend ILB created: `ilb-api-bb-dev`
- Backend ILB IP: `10.20.3.10`

Backend targets:
- frontend ILB -> `vm-web-bb-dev`
- backend ILB -> `vm-api-bb-dev`

### 8. Public entry point
- Application Gateway WAF v2 created: `agw-bb-dev`
- Public IP created and attached
- HTTPS configured using self-signed certificate
- WAF enabled in detection mode
- Routing model implemented:
  - `/` -> frontend ILB
  - `/api/*` -> backend ILB

### 9. Stable Terraform state
- `terraform plan` has been brought back to a stable state after resource creation
- Infrastructure has been applied successfully

---

## Current Important Outputs

### Resource group
- `project2-burgerbuilder-team-5`

### Region
- `West US 2`

### Application Gateway
- Name: `agw-bb-dev`
- Public IP: `20.230.242.199`

### Internal load balancers
- Frontend ILB: `ilb-web-bb-dev` -> `10.20.2.10`
- Backend ILB: `ilb-api-bb-dev` -> `10.20.3.10`

### Virtual machines
- `vm-web-bb-dev` -> `10.20.2.4`
- `vm-api-bb-dev` -> `10.20.3.4`
- `vm-ops-bb-dev` -> `10.20.4.4`

### SQL
- Server name: `sql-bb-dev-team5`
- FQDN: `sql-bb-dev-team5.database.windows.net`
- Database: `burgerbuilderdb`
- Public access: disabled

### Key Vault
- Name: `kv-bb-dev-team5`
- URI: `https://kv-bb-dev-team5.vault.azure.net/`
- Public access: disabled

### Planned Key Vault secret names
- `sql-admin-username`
- `sql-admin-password`

---

## Current Architecture Summary

### Public path
```text
Internet
  -> HTTPS
Application Gateway (20.230.242.199)
```

### Frontend path
```text
Application Gateway
  -> ilb-web-bb-dev (10.20.2.10)
  -> vm-web-bb-dev (10.20.2.4)
```

### Backend path
```text
Application Gateway
  -> ilb-api-bb-dev (10.20.3.10)
  -> vm-api-bb-dev (10.20.3.4)
  -> Azure SQL via Private Endpoint
```

### Ops path
```text
vm-ops-bb-dev (10.20.4.4)
```

### Security statement
- only Application Gateway is public
- all VMs are private-only
- SQL is private-only
- Key Vault is private-only

---

## What Is Still Remaining For Person 1

### Must-do / high priority
- harden NSG rules
- add monitoring resources
- add alerting resources if handled in Terraform
- refine outputs if teammates need more exact values

### Recommended next tasks
1. NSG hardening
2. Log Analytics workspace
3. Application Insights resources
4. Azure Monitor alert rules
5. diagnostic settings where practical

### Optional / stretch work
- autoscaling-related design improvements
- VMSS-based scale-out
- stronger secret automation flow
- more advanced WAF/TLS tuning

---

## What Other Teammates Need From Person 1

## What Person 2 Needs

Person 2 needs the server and networking details for Ansible and machine configuration.

### Give Person 2
- resource group name
- region
- VNet name
- subnet names and CIDRs
- VM names
- VM private IPs
- VM admin username
- SSH auth model
- ILB names and private IPs
- SQL FQDN and database name
- Key Vault name and URI
- planned Key Vault secret names

### Important notes for Person 2
- no VM has a public IP
- configuration should happen through private networking
- Key Vault secrets are not inserted yet
- likely secret insertion should happen later from inside the VNet, probably from the ops VM

---

## What Person 3 Needs

Person 3 needs infra values for app configuration and deployment logic.

### Give Person 3
- Application Gateway public IP
- frontend routing path design
- backend routing path design
- frontend ILB private IP
- backend ILB private IP
- frontend VM private IP
- backend VM private IP
- ops VM private IP
- SQL FQDN
- SQL database name
- Key Vault name and URI

### Important notes for Person 3
- App Gateway is the only public entry point
- SQL is private-only
- Key Vault is private-only
- app deploys should target the private VM layer
- Key Vault secret values are not inserted yet

---

## What Person 4 Needs

Person 4 needs proof and architecture details for documentation and validation.

### Give Person 4
- complete architecture summary
- resource names
- subnet layout
- App Gateway name and public IP
- ILB names and private IPs
- VM names and private IPs
- SQL private-only configuration details
- Key Vault private-only configuration details
- confirmation that no compute public IPs exist

### Important notes for Person 4
- only Application Gateway is public
- SQL public access is disabled
- Key Vault public access is disabled
- private endpoints exist for SQL and Key Vault

---

## Current Dependencies On Other Teammates

Person 1 is not heavily blocked right now.

### Minor dependencies

#### From Person 2
- final SSH / ops access expectations
- whether they want additional temporary NSG allowances for setup

#### From Person 3
- final backend health probe path confirmation
- final frontend probe expectation if anything changes

#### From Person 4
- exact evidence/screenshots they want from Terraform-created resources
- final alert documentation expectations

These are not blocking the next Person 1 tasks.

---

## Suggested Next Person 1 Work Order

1. confirm clean `terraform plan`
2. harden NSG rules
3. add Log Analytics
4. add Application Insights
5. add alerting resources
6. support Person 2 and Person 3 handoff

---

## Notes And Caveats

- The App Gateway certificate is self-signed for demo/testing.
- Browser warnings are expected until a real trusted certificate/domain is used.
- Key Vault is intentionally private-only.
- Key Vault secret values are not yet inserted because Terraform is being run from outside the VNet.
- The chosen architecture is scalable-ready because App Gateway routes to internal load balancers instead of directly to VM IPs.

---

## Quick Summary

Person 1 has already completed the backbone of the project:
- state
- network
- private database
- private key vault
- private compute
- internal load balancers
- public HTTPS gateway

What remains is mostly:
- security tightening
- monitoring
- alerting
- documentation support for the rest of the team
