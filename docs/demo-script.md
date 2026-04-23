# Demo Script — 3 to 5 Minute Walkthrough

## 1. Architecture Overview (30 seconds)
- Show the architecture diagram
- Explain: "Only the Application Gateway has a public IP"
- All other resources are private

## 2. Azure Portal — Resources (60 seconds)
- Open Resource Group — show all resources
- Open any VM — show that there is NO public IP
- Open SQL Server — show "Public network access: Disabled"
- Open App Gateway — show WAF v2 configuration

## 3. Live Application Demo (90 seconds)
- Open browser: `http://<AGW_PUBLIC_IP>/`
- Show the Burger Builder frontend loads
- Create a new burger order
- Show the order is saved (API call to backend → SQL)

## 4. Monitoring (60 seconds)
- Azure Portal → Application Insights → Live Metrics
- Show requests coming in
- Open Alerts — show 3 configured alerts:
  1. App Gateway Backend Health < 100%
  2. VM CPU > 70%
  3. SQL DTU > 80%

## 5. CI/CD Pipeline (30 seconds)
- GitHub → Actions tab
- Show successful pipeline runs for frontend and backend
- Explain: build → test → scan → deploy
