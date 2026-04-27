# Person 3 — DevOps Engineer Handoff

## Purpose

This document summarizes:
- What Person 3 has completed
- Every file created or modified in the repository
- What each teammate needs from Person 3
- The environment variable reference for Person 4's runbook

This file should be committed to the repository so the team always has an up-to-date CI/CD and application reference.

---

## Role and Responsibility

Person 3 is the **DevOps Engineer**. The role sits between the application code and the Azure infrastructure — responsible for making the app behave correctly in the cloud and for building the automation that tests, packages, and deploys it automatically on every commit.

No other team member touches the CI/CD configuration or the application source code. Person 3 owns both entirely.

Delivery order: **Code → Pipeline → Monitor**

---

## Architecture Context

The application is a Burger Builder web app running on:

- **Frontend:** React with Vite — deployed to `vm-web-bb-dev` (`10.20.2.4`)
- **Backend:** Spring Boot Java API — deployed to `vm-api-bb-dev` (`10.20.3.4`)
- **Database:** Azure SQL — `sql-bb-dev-team5.database.windows.net` (private only)
- **Entry point:** Application Gateway WAF v2 — public IP `20.230.242.199`
- **Operations:** `vm-ops-bb-dev` (`10.20.4.4`) — hosts SonarQube and the GitHub Actions self-hosted runner

Traffic flow in production:
```
Internet  →  HTTPS  →  Application Gateway (20.230.242.199)
                  /        →  ilb-web-bb-dev (10.20.2.10)  →  vm-web-bb-dev
                  /api/*   →  ilb-api-bb-dev (10.20.3.10)  →  vm-api-bb-dev  →  Azure SQL
```

---

## Step 1 — Application Cloud-Readiness

Before any pipeline could be built, the application source code had to be sanitised so it behaves correctly in a multi-tier Azure environment where the frontend and backend run on separate private VMs.

### 1A — api.ts: Remove Hardcoded localhost URL

**File:** `frontend/src/services/api.ts`

**Problem:** The API client fell back to `http://localhost:8080` when the environment variable was missing. In Azure the frontend VM has no idea where `localhost:8080` is — the backend is on a completely different private VM.

**Fix:** Changed the fallback to an empty string. An empty base URL causes all API calls to use relative paths like `/api/ingredients`. The Application Gateway routes `/api/*` to the backend automatically. Also removed two debug `console.log` lines that would have exposed internal URLs in the browser console.

```
BEFORE:  const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';
AFTER:   const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '';
```

---

### 1B — BurgerBuilder.tsx: Remove Demo Ingredient Fallback

**File:** `frontend/src/components/BurgerBuilder/BurgerBuilder.tsx`

**Problem:** When the backend API call failed, the app silently loaded 14 hardcoded fake ingredients and showed a misleading message saying it was using sample data for demo purposes. A user would have no idea the real backend was unreachable.

**Fix:** Deleted the entire `setSampleIngredients()` function and its call from the catch block. The error message now clearly tells the user to try again. Nothing fake is ever shown.

```
BEFORE catch: setError('...Using sample data for demo.'); setSampleIngredients();
AFTER catch:  setError('Failed to load ingredients. Please try again.');
```

---

### 1C — OrderSummary.tsx: Remove Fake Order Success

**File:** `frontend/src/components/OrderSummary/OrderSummary.tsx`

**Problem:** If the `createOrder` API call failed, the app still displayed `Order Placed Successfully!` with a fake generated order ID like `ORD-1714000000000`. The customer would believe their order was confirmed but nothing was saved in Azure SQL.

**Fix:** Removed four lines from the catch block that faked a successful order. The success screen now only appears when the backend returns a real confirmed order with a real order number.

```
REMOVED: const mockOrderId = `ORD-${Date.now()}`;
REMOVED: setOrderId(mockOrderId);
REMOVED: setOrderPlaced(true);
REMOVED: clearCart();
```

---

### 1D — vite.config.ts: Production Build Configuration

**File:** `frontend/vite.config.ts`

Configured the Vite development server proxy so local development continues to work with `/api` paths pointing to `localhost:8080`, while the production bundle uses relative paths routed by the Application Gateway. The proxy block has no effect on the built output.

---

### 1E — application-prod.properties: Backend Production Config

**File:** `backend/src/main/resources/application-prod.properties`

Created from scratch. Loaded by Spring Boot only when `SPRING_PROFILES_ACTIVE=prod`. Key settings:

- Connects to Azure SQL using environment variables — no hardcoded credentials
- JPA set to `validate` mode — never auto-creates or drops tables in production
- SQL init scripts disabled — schema already exists in Azure SQL
- Exposes `/actuator/health` for the Application Gateway health probe
- CORS restricted to the `APP_GATEWAY_FQDN` environment variable
- Logging reduced to WARN level for production

---

### 1F — CorsConfig.java: Backend CORS Restriction

**File:** `backend/src/main/java/com/burgerbuilder/config/CorsConfig.java`

Created from scratch. A Spring Boot `@Configuration` bean that restricts which origins can make cross-origin requests to the `/api/**` endpoints. Only the Application Gateway FQDN is whitelisted. The value is injected from the `APP_GATEWAY_FQDN` environment variable at runtime.

---

## Step 2 — Secrets and Environment Definition

All secrets are stored in GitHub repository secrets and injected as environment variables at workflow runtime. No secret is hardcoded in any file in the repository.

**Location:** `GitHub repo → Settings → Secrets and variables → Actions`

| Secret Name | What It Contains | Who Provides It |
|---|---|---|
| `AZURE_CREDENTIALS` | Full Service Principal JSON blob | Person 1 |
| `AZURE_CLIENT_ID` | Service principal client ID | Person 1 |
| `AZURE_CLIENT_SECRET` | Service principal password | Person 1 |
| `AZURE_TENANT_ID` | Azure AD tenant ID | Person 1 |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | Person 1 |
| `AZURE_SQL_HOSTNAME` | `sql-bb-dev-team5.database.windows.net` | Person 1 |
| `AZURE_SQL_DBNAME` | `burgerbuilderdb` | Person 1 |
| `AZURE_SQL_USER` | SQL admin login username | Person 1 |
| `SQL_PASSWORD` | SQL admin login password | Person 1 |
| `APP_GATEWAY_FQDN` | Application Gateway public URL | Person 1 |
| `FRONTEND_VM_IP` | `10.20.2.4` — vm-web-bb-dev private IP | Person 1 |
| `BACKEND_VM_IP` | `10.20.3.4` — vm-api-bb-dev private IP | Person 1 |
| `VITE_APPINSIGHTS_CONNECTION_STRING` | App Insights connection string | Person 1 |
| `SONAR_HOST_URL` | `http://10.20.4.4:9000` — Ops VM SonarQube | Person 2 |
| `SONAR_TOKEN` | Generated from SonarQube UI | Person 3 |

### Frontend Production Environment File

**File:** `frontend/.env.production`

`VITE_API_BASE_URL` is intentionally empty so all API calls use relative paths routed by the Application Gateway.

```
VITE_API_BASE_URL=
VITE_APPINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=https://...
```

### Key Vault Access

The CI/CD service principal requires **Get** and **List** permissions on Key Vault `kv-bb-dev-team5` to read secrets at deploy time. Person 1 must add an access policy for the service principal client ID.

---

## Step 3 — CI/CD Workflow Construction

Three workflow files are committed to `.github/workflows/`. Build jobs run on GitHub-hosted runners. Deploy jobs run on the self-hosted runner on `vm-ops-bb-dev` because the frontend and backend VMs have private IPs that GitHub's servers cannot reach.

### infra.yml — Terraform Infrastructure Pipeline

- Triggers only when files inside `infra/` change
- On Pull Request → runs `fmt`, `init`, `validate`, `plan` only — never touches real Azure resources
- On merge to `main` → runs `terraform apply` to create or update Azure infrastructure
- Runs on `ubuntu-latest` GitHub-hosted runner

### frontend.yml — React Build and Deploy

**Job 1: Build — GitHub-hosted runner**
- Installs Node.js 20
- Runs `npm ci` for a clean deterministic install
- Runs `npm test`
- Runs `npm run build` with `VITE_API_BASE_URL` empty
- Uploads `dist/` as a GitHub Actions artifact

**Job 2: Deploy — self-hosted runner on vm-ops-bb-dev**
- Only runs on merges to `main`
- Downloads the `dist/` artifact
- Runs Ansible `deploy-frontend.yml` targeting `vm-web-bb-dev` via private IP
- Verifies deployment with `curl` against `FRONTEND_VM_IP`

### backend.yml — Spring Boot Build and Deploy

**Job 1: Build — GitHub-hosted runner**
- Installs Java 17 Eclipse Temurin
- Runs `mvn clean package` with all unit tests
- Uploads the JAR as a GitHub Actions artifact

**Job 2: SonarQube Scan — self-hosted runner**
- Must run on self-hosted — SonarQube is on the private Ops VM, GitHub's servers cannot reach it
- Runs `mvn sonar:sonar` connecting to `SONAR_HOST_URL`
- Fails the pipeline if the Quality Gate is not passed — no deployment proceeds with failing code quality

**Job 3: Deploy — self-hosted runner**
- Only starts after both build and SonarQube jobs pass
- Only runs on merges to `main`
- Runs Ansible `deploy-backend.yml` targeting `vm-api-bb-dev` via private IP
- Verifies deployment by calling `/actuator/health` and asserting `"status":"UP"`

---

## Step 4 — SonarQube and Telemetry Integration

### SonarQube — Code Quality Gates

SonarQube scanning is built into `backend.yml` as Job 2. Every push to `main` and every pull request triggers a full analysis of the Spring Boot backend. The Quality Gate is enforced — if critical issues are found or coverage drops, the deployment is automatically blocked.

The scan targets the SonarQube instance on `vm-ops-bb-dev`. GitHub-hosted runners cannot reach this private address, which is why this job runs on the self-hosted runner.

### Application Insights — Frontend

**File:** `frontend/src/telemetry.ts`
**Package:** `@microsoft/applicationinsights-web`

Initialised once at startup and imported in `frontend/src/index.tsx`. Automatically tracks:

- Every page navigation via React Router
- Time users spend on each page
- All outgoing API requests with correlation headers linking frontend to backend traces
- Unhandled JavaScript exceptions

Safely disabled in local development if `VITE_APPINSIGHTS_CONNECTION_STRING` is not set.

### Application Insights — Backend

The Azure Monitor Java agent is installed on `vm-api-bb-dev` and configured in the systemd service file by Person 2. It automatically captures inbound HTTP requests, database call timing, JVM metrics, and distributed traces.

Configuration added to the backend systemd service by Person 2:

```
Environment="JAVA_TOOL_OPTIONS=-javaagent:/opt/applicationinsights/applicationinsights-agent.jar"
Environment="APPLICATIONINSIGHTS_CONNECTION_STRING=<value from Person 1>"
```

Agent download command for Person 2 to run on `vm-api-bb-dev`:

```bash
mkdir -p /opt/applicationinsights
curl -L -o /opt/applicationinsights/applicationinsights-agent.jar \
  https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.5.2/applicationinsights-agent-3.5.2.jar
```

---

## Step 5 — Final Validation

### Backend Health Check

The Application Gateway probes `/actuator/health` on port 8080. The backend must return HTTP 200 with `"status":"UP"` for the backend pool to be marked healthy.

Manual verification:
```bash
curl https://20.230.242.199/api/actuator/health
```

Expected response:
```json
{"status":"UP","components":{"db":{"status":"UP"},"diskSpace":{"status":"UP"}}}
```

If `db` shows `DOWN`: check Azure SQL firewall allows the backend VM private IP, confirm `AZURE_SQL_HOSTNAME` secret is correct, and confirm `SPRING_PROFILES_ACTIVE=prod` is set in the systemd service.

### Full Pipeline Verification

```bash
echo "# pipeline verified $(date)" >> README.md
git add README.md
git commit -m "test: verify full pipeline"
git push origin main
```

Then go to **GitHub → Actions tab** and confirm all three workflows complete green.

---

## What Teammates Need from Person 3

### What Person 2 Needs

- **GitHub Actions runner registration token** — Person 3 generates this from `GitHub → Settings → Actions → Runners → New self-hosted runner → Linux → copy the --token value` and sends it to Person 2
- Confirmation that `backend.yml` expects Ansible playbooks at `ansible/deploy-backend.yml` and `ansible/inventory.ini`
- Confirmation that `frontend.yml` expects Ansible playbooks at `ansible/deploy-frontend.yml` and `ansible/inventory.ini`
- `SPRING_PROFILES_ACTIVE=prod` must be set in the systemd service on `vm-api-bb-dev`

### What Person 4 Needs

- Confirmation that `/actuator/health` returns `UP` when connected to Azure SQL
- Application Insights dashboard URL: `Azure Portal → Resource Group → Application Insights → Application Dashboard`
- The complete environment variable table below for the runbook

---

## Environment Variable Reference for Person 4

| Variable Name | Used By | Description |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | Backend VM systemd | Must be set to `prod` to load `application-prod.properties` |
| `AZURE_SQL_HOSTNAME` | Spring Boot | Azure SQL server FQDN |
| `AZURE_SQL_DBNAME` | Spring Boot | Database name |
| `AZURE_SQL_USER` | Spring Boot | SQL admin username |
| `AZURE_SQL_PASSWORD` | Spring Boot | SQL admin password |
| `APP_GATEWAY_FQDN` | Spring Boot CORS | Allowed CORS origin — Application Gateway URL |
| `JAVA_TOOL_OPTIONS` | Backend JVM | Path to App Insights Java agent JAR |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Backend JVM | Azure Monitor connection string for backend traces |
| `VITE_API_BASE_URL` | React build | Empty string — all API calls use relative paths |
| `VITE_APPINSIGHTS_CONNECTION_STRING` | React build | Azure Monitor connection string for frontend traces |

---

## Complete File Reference

| File | Path in Repository | Action |
|---|---|---|
| `api.ts` | `frontend/src/services/` | Modified — removed localhost fallback and debug logs |
| `BurgerBuilder.tsx` | `frontend/src/components/BurgerBuilder/` | Modified — removed fake ingredient fallback |
| `OrderSummary.tsx` | `frontend/src/components/OrderSummary/` | Modified — removed fake order success |
| `vite.config.ts` | `frontend/` | Modified — added dev proxy config |
| `telemetry.ts` | `frontend/src/` | Created — Application Insights JS SDK setup |
| `.env.production` | `frontend/` | Created — production environment variables |
| `application-prod.properties` | `backend/src/main/resources/` | Created — Spring Boot production config |
| `CorsConfig.java` | `backend/src/main/java/com/burgerbuilder/config/` | Created — CORS restriction bean |
| `infra.yml` | `.github/workflows/` | Created — Terraform infrastructure pipeline |
| `frontend.yml` | `.github/workflows/` | Created — React build and deploy pipeline |
| `backend.yml` | `.github/workflows/` | Created — Spring Boot build and deploy pipeline |

---

## Quick Summary

Person 3 has delivered:

- 6 application code fixes making the app production-safe for Azure
- 15 GitHub Secrets defined and documented
- 3 CI/CD workflow files covering infrastructure, frontend, and backend
- SonarQube quality gate enforcement built into the backend pipeline
- Application Insights telemetry for both frontend and backend
- A production Spring Boot configuration targeting Azure SQL privately
- A CORS restriction allowing only the Application Gateway as an origin
- Full environment variable documentation for Person 4

The CI/CD pipeline follows the **hybrid runner pattern** — build jobs run on free GitHub-hosted runners, deploy jobs run on the self-hosted runner on the Ops VM — because the frontend and backend VMs have private IPs that GitHub's public infrastructure cannot reach.

---

*End of Person 3 Handoff — devops-project2-ih*
