# Person 2 Ansible Handoff

This document is for Person 2 to work independently from a separate laptop.

It explains:
- what is already done
- what is not done yet
- how to work with private-only VMs
- what files to use in this repo
- what to do first, second, and third

## 1. Current project state

The Azure infrastructure already exists.

Important resources:
- Resource group: `project2-burgerbuilder-team-5`
- Region: `westus2`
- VNet: `vnet-bb-dev`
- Web VM: `vm-web-bb-dev` = `10.20.2.4`
- API VM: `vm-api-bb-dev` = `10.20.3.4`
- Ops VM: `vm-ops-bb-dev` = `10.20.4.4`
- Frontend ILB: `ilb-web-bb-dev` = `10.20.2.10`
- Backend ILB: `ilb-api-bb-dev` = `10.20.3.10`
- App Gateway public IP: `20.230.242.199`
- SQL host: `sql-bb-dev-team5.database.windows.net`
- SQL database: `burgerbuilderdb`
- Key Vault: `kv-bb-dev-team5`

Important architecture facts:
- No VM has a public IP.
- SQL public network access is disabled.
- Key Vault public network access is disabled.
- The ops VM must be used as the control point for Ansible.

## 2. What has already been prepared in the repo

These starter files now exist:
- `config/ansible/ansible.cfg`
- `config/ansible/inventories/dev/hosts.yml`
- `config/ansible/group_vars/all.yml`
- `config/ansible/playbooks/ping.yml`
- `config/ansible/playbooks/deploy-frontend.yml`
- `config/ansible/playbooks/deploy-backend.yml`
- `config/ansible/roles/common/`
- `config/ansible/roles/frontend_deploy/`
- `config/ansible/roles/backend_deploy/`

These are starter files only.

They are meant to:
- give you the correct repo structure
- match the paths used by GitHub Actions
- give you a first working direction

They do **not** mean Person 2 is finished.

## 3. What is NOT done yet

You still need to do the real Person 2 work:
- bootstrap the ops VM
- install Ansible on the ops VM
- install Azure CLI on the ops VM
- place the SSH private key on the ops VM
- create the SQL secrets inside Key Vault
- test SSH from ops VM to web/api VMs
- verify nginx deployment really works
- verify backend deployment really works
- verify backend service reads SQL credentials correctly
- likely improve the starter playbooks after first tests
- later set up GitHub self-hosted runner on the ops VM
- later set up SonarQube on the ops VM

So only the **starting scaffold** is done, not the whole Person 2 responsibility.

## 4. Important separate-laptop explanation

Person 1 and Person 2 are on different laptops.

That means Person 2 cannot rely on:
- Person 1's local SSH key files
- Person 1's local Terraform local files
- Person 1's Codex session

Person 2 should work like this:
- use her own local git clone of the repo
- read this handoff document
- use Azure Run Command to bootstrap the ops VM
- then work mostly from inside the ops VM

## 5. How private VM access works

Because the VMs are private-only:
- Person 2 cannot SSH directly from her laptop to `10.20.2.4` or `10.20.3.4`
- Person 2 first needs the ops VM prepared
- then Ansible should run **from the ops VM**

Real access path:

`Person 2 laptop -> Azure control plane / Run Command -> ops VM -> SSH -> web/api VMs`

This is the intended secure path.

## 6. SSH key decision

For the first working version, the team decided to reuse the current Azure VM SSH key.

That means:
- the private key matching the VM public key must be placed on the ops VM
- the file path expected by the starter inventory is:
  `~/.ssh/id_rsa_azure`

This key should be transferred securely by the team.

Recommended simple approach:
- Person 1 gives Person 2 the private key securely out-of-band
- Person 2 places it on the ops VM during bootstrap
- file permissions should be strict, for example `chmod 600 ~/.ssh/id_rsa_azure`

Later, the team can rotate to a separate automation-only key if desired.

## 7. Terraform change needed before Ansible can use Key Vault

Person 1 already prepared the code changes, but they still need to be applied.

Those changes do two things:
- enable a system-assigned managed identity on `vm-ops-bb-dev`
- give that identity permission to read Key Vault secrets

Before Person 2 starts the Key Vault flow, Person 1 must run:
- `terraform plan`
- `terraform apply`

After apply, the ops VM should be able to authenticate to Azure Key Vault using managed identity.

## 8. First work order for Person 2

### Step 1: Pull latest repo changes

Why:
- you need the new Ansible scaffold and the latest Terraform code

### Step 2: Coordinate with Person 1

Why:
- Person 1 must apply the latest Terraform change for ops VM managed identity

What to ask Person 1:
- confirm Terraform apply completed
- confirm ops VM managed identity is enabled

### Step 3: Bootstrap the ops VM using Azure Run Command

Why:
- the ops VM is private-only, so this is the clean way to do first setup

Install on the ops VM:
- `ansible`
- `azure-cli`
- `git`
- `python3-pip`
- `unzip`
- the SSH private key at `~/.ssh/id_rsa_azure`

Goal:
- the ops VM becomes the Ansible control node

### Step 4: Clone the repo onto the ops VM

Why:
- Ansible should run from the ops VM against the private web/api VMs

Recommended path:
- something like `~/repo_clean`

### Step 5: Create the SQL secrets in Key Vault

Why:
- the vault exists, but these secrets do not yet exist:
  - `sql-admin-username`
  - `sql-admin-password`

These must be created from inside the VNet, ideally from the ops VM.

### Step 6: Test Ansible connectivity

From inside the repo on the ops VM:

```bash
cd config/ansible
ansible-playbook playbooks/ping.yml
```

Goal:
- both `vm-web-bb-dev` and `vm-api-bb-dev` respond successfully

### Step 7: Deploy frontend manually once

Why:
- prove nginx + file copy + inventory work before CI tries it

Expected playbook:
- `playbooks/deploy-frontend.yml`

### Step 8: Deploy backend manually once

Why:
- prove Java + systemd + Key Vault secret retrieval work before CI tries it

Expected playbook:
- `playbooks/deploy-backend.yml`

### Step 9: Hand results back to Person 3

Why:
- once manual deploy works, CI can be wired much more safely

## 9. What the starter Ansible files currently assume

Inventory assumptions:
- SSH user is `azureuser`
- SSH private key path is `~/.ssh/id_rsa_azure`

Frontend assumptions:
- site served by `nginx`
- files copied to `/var/www/burgerbuilder`

Backend assumptions:
- Java runtime installed on API VM
- backend app root is `/opt/burgerbuilder/backend`
- service name is `burgerbuilder-backend`
- service port is `8080`
- Key Vault is the source for SQL credentials

These assumptions are reasonable defaults, but Person 2 should adjust them if testing shows a mismatch.

## 10. Key Vault secret flow

The intended backend secret flow is:

`Key Vault -> ops VM Ansible -> backend.env on API VM -> systemd service -> Spring Boot app`

This is the chosen design because:
- it is more secure than hardcoding SQL credentials in repo files
- it is easier than making the Java app directly fetch Key Vault secrets at runtime on day one

## 11. What to improve after first success

After the first manual deployment works, Person 2 should improve:
- idempotency checks
- cleaner nginx config
- backend service hardening
- service user permissions
- maybe separate provisioning playbooks from deployment playbooks more clearly
- maybe add an ops VM role for self-hosted runner and SonarQube

## 12. What Person 2 should report back to the team

After first success, Person 2 should send:
- whether Ansible ping works
- whether frontend deploy works
- whether backend deploy works
- whether `/actuator/health` works on the API VM
- whether SQL secret retrieval from Key Vault works
- what still needs fixing before CI can depend on it

## 13. Questions Person 2 should answer early

Before going too far, Person 2 should decide:
- do we want one big site playbook or separate provisioning/deploy playbooks
- do we want SonarQube setup now or after frontend/backend deployment is stable
- do we want GitHub runner setup before or after manual Ansible deployment succeeds

Recommended answers:
- separate provisioning and deploy concerns gradually
- SonarQube later
- GitHub runner after manual Ansible deployment works
