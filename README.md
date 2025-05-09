# DevOps Project: Azure Minimal API + Function with Full CI/CD and Monitoring

Welcome to the **Azure DevOps Demo Project**!  
This project demonstrates a full-featured DevOps pipeline and infrastructure automation using:

- Azure infrastructure provisioning with **Terraform**
- A **.NET 8 Minimal API** application
- A **serverless Azure Function** for custom logging
- **CI/CD** using both **GitHub Actions** and **Azure DevOps**
- Built-in **monitoring and alerting** using **Application Insights** and **Log Analytics**

---

## 🚀 Project Structure

```
/src/Azure-demo-app/                - .NET 8 Minimal API app
/src/Azure-demo-function/          - Azure Function (log ingestion)
/infra/                            - Terraform files (App Plan, Function App, Insights, etc.)
.github/workflows/                 - GitHub pipelines (App + Function)
/azure-pipelines.yml               - Azure DevOps pipeline
```

---

## 🛠️ Technologies Used

- **Azure App Service + Function App**
- **Terraform** (IaC for clean deployments)
- **Azure DevOps Pipelines**
- **GitHub Actions**
- **Application Insights + Log Analytics**
- **C# .NET 8 Minimal API + Azure Functions**
- **PowerShell & Python scripts** (for health checks and alert simulations)

---

## 🔧 Infrastructure Provisioned

- App Service Plan + Web App (for Minimal API)
- Linux Function App (serverless logging endpoint)
- Azure Storage (Function App dependencies)
- Application Insights + Log Analytics Workspace
- Monitoring setup (availability test, alerts, traces)

---

## 🖥️ Deploying the App & Infrastructure

### Prerequisites:
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure account with permission to create resources

```bash
az login
cd infra/
terraform init
terraform apply
```

---

## 🔒 Authentication & Secrets

Authentication is handled using a **Service Principal** with environment variables:

| Variable | Description |
|----------|-------------|
| ARM_CLIENT_ID | SP App ID |
| ARM_CLIENT_SECRET | SP Secret |
| ARM_SUBSCRIPTION_ID | Subscription ID |
| ARM_TENANT_ID | Tenant ID |

These are stored in:
- GitHub → **Repository → Secrets**
- Azure DevOps → **Service Connections**

---

## ⚙️ CI/CD Pipelines

### GitHub Actions:
- **App**: Deploys the Minimal API to App Service
- **Function**: Deploys the Azure Function via publish profile

### Azure DevOps:
- Full pipeline: Terraform infra + build + deploy
- Triggered on commits to `devops` branch
- Pushes build artifacts and deploys the web app

---

## 🔍 Monitoring & Automation

- **Application Insights**: request logs, traces, exceptions
- **Log Analytics**: custom KQL queries
- **Alerts**: error thresholds and performance drop detection
- **Availability Test**: pings `/hello` endpoint
- **Custom scripts**:
  - PowerShell: simulate errors, test alert flow
  - Python: monitor health and call logging endpoint

---

## 📈 Future Additions

- Auto-scaling policy
- Azure Key Vault integration
- Alerting via Teams or Slack
- Container-based deployment to AKS

---

## 📜 License

This is a portfolio-ready DevOps demo project — use freely to learn or impress at your next interview!
