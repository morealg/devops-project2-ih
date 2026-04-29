# Demo Script — Burger Builder on Azure

**Total time:** 4–5 minutes  
**Presenter setup:** Azure Portal open, browser tab with `https://20.230.242.199/` ready, GitHub Actions tab ready

---

## Opening (15 seconds)

> "We were given a legacy Burger Builder app running on a single on-premise VM —
> no scalability, no security, no automation.
> Our job was to redesign and redeploy it on Azure using production-grade DevOps practices.
> Here is what we built."

---

## Part 1 — Architecture (45 seconds)

**Show the architecture diagram.**

> "The core design principle is: **nothing is public except the Application Gateway.**"

Point to each component:

> - "Users connect over HTTPS to the Application Gateway — WAF v2 enabled, public IP: 20.230.242.199"
> - "The gateway routes `/` to the frontend, and `/api/*` to the backend — through private Internal Load Balancers"
> - "The frontend VM runs Nginx and serves the React app"
> - "The backend VM runs a Java Spring Boot REST API"
> - "The database is Azure SQL — accessible only through a Private Endpoint. There is no public access at all."
> - "Key Vault stores secrets — also private only."
> - "The Ops VM hosts our GitHub Actions self-hosted runner and SonarQube."

---

## Part 2 — Security Proof (60 seconds)

**Open Azure Portal → Resource Group `project2-burgerbuilder-team-5`**

> "Let me prove the security model works."

**Click on `vm-web-bb-dev`:**
> "Frontend VM — Public IP address: **None**."

**Click on `vm-api-bb-dev`:**
> "Backend VM — Public IP address: **None**."

**Click on `sql-bb-dev-team5`:**
> "SQL Server — Public network access: **Disabled**. Only reachable through the private endpoint inside our VNet."

**Click on `kv-bb-dev-team5`:**
> "Key Vault — same. Public network access: **Disabled**."

**Click on `agw-bb-dev`:**
> "And here is the only public-facing resource — Application Gateway with WAF v2 enabled."

---

## Part 3 — Live Application (60 seconds)

**Open browser → `https://20.230.242.199/`**

> "The Burger Builder app — live, running through the Application Gateway."

**Walk through the app:**
> - "I can build a burger — select ingredients"
> - "Place the order"
> - "The order is sent to the backend API, which writes it to Azure SQL through the private endpoint"
> - "End-to-end flow — fully working."

---

## Part 4 — Monitoring (45 seconds)

**Open Azure Portal → Monitor → Alerts → Alert rules**

> "We have 3 alerts configured:"
> - "If App Gateway detects an unhealthy backend — immediate alert"
> - "If any VM CPU exceeds 70% for 5 minutes — warning alert"
> - "If SQL DTU consumption exceeds 80% — warning alert"

**Open `appi-api-bb-dev` → Live Metrics**

> "Application Insights is connected to the backend — we can see live requests, response times, and failures in real time."

---

## Part 5 — CI/CD Pipeline (45 seconds)

**Open GitHub → Actions tab**

> "Everything is automated. We have three pipelines:"
> - "`infra.yml` — provisions the entire Azure infrastructure with Terraform"
> - "`frontend.yml` — builds, tests, and deploys the React app"
> - "`backend.yml` — builds, runs tests, runs SonarQube code quality scan, then deploys the Java app"

> "Deployments to private VMs go through our self-hosted runner on the Ops VM — because GitHub-hosted runners cannot reach private subnets."

> "Push to main — everything deploys automatically. No manual steps."

---

## Closing (15 seconds)

> "To summarize: private 3-tier architecture, WAF-protected public entry point, fully automated infrastructure and deployment, live monitoring with alerts, and code quality scanning on every push."
>
> "Thank you."

---

## Q&A Preparation

| Question | Answer |
|---|---|
| Why Internal Load Balancers? | Scalability — we can add more VMs behind the ILB without changing the App Gateway configuration |
| How do you access private VMs? | Only through the Ops VM — no direct SSH from the internet |
| What if the frontend VM goes down? | The App Gateway health probe detects it immediately and the alert fires |
| Why WAF v2? | It provides built-in protection against OWASP Top 10 attacks |
| How are secrets managed? | All secrets are stored in Key Vault — no hardcoded credentials anywhere |

