# Runbook — Operational Guide

## Site Not Loading
1. Azure Portal → App Gateway → Check Backend Health
2. SSH into vm-frontend
3. `sudo systemctl status nginx`
4. If not running: `sudo systemctl start nginx`
5. Check logs: `sudo journalctl -u nginx -f`

## API Not Responding
1. SSH into vm-backend
2. `sudo systemctl status backend`
3. If not running: `sudo systemctl start backend`
4. Check logs: `sudo journalctl -u backend -f`

## Pipeline Failing
1. GitHub → Actions tab → Find the failed step
2. If runner is offline: SSH into vm-ops
3. `cd /opt/actions-runner && ./run.sh`

## Cannot Connect to SQL
1. Check Private Endpoint in Azure Portal
2. Verify backend connection string is correct
3. Check NSG rules allow traffic from backend subnet

## High CPU Alert Triggered
1. Azure Portal → Virtual Machines → Check CPU metrics
2. SSH into the affected VM
3. `top` or `htop` to find the process causing high CPU
4. Restart the service if needed
