# DevOps Project: Azure Infrastructure with Terraform and CI/CD Pipelines

Welcome to the **DevOps AzureDemoApp Project**!  
This project demonstrates a **professional DevOps workflow** including:

- Azure infrastructure deployment using **Terraform**
- C# **.NET 8 minimal API application**
- **Azure DevOps** pipeline
- **GitHub Actions** workflow
- **Remote state management** (Azure Blob Storage)
- **Service Principal authentication**
- Full **Infrastructure as Code (IaC)** best practices

---

## 🚀 Project Structure

```
/app/                                - .NET 8 C# minimal API app
/infra/                              - Terraform files for Azure infrastructure
.azure-pipelines.yml                 - Azure DevOps pipeline
.github/workflows/terraform.yml      - GitHub Actions workflow
README.md                            - This file
```

---

## 🛠️ Technologies Used

- Azure Resource Manager (App Service, AKS, Azure SQL, VNet)
- Terraform (Infrastructure as Code)
- Azure DevOps Pipelines
- GitHub Actions
- C# (.NET 8 Minimal API)
- Azure Service Principal (for secure authentication)

---

## 📦 Infrastructure Deployed

- **Resource Group** (per environment: dev/prod)
- **Virtual Network (VNet)** and Subnet
- **Azure App Service Plan + Web App** (to host the .NET app)
- **Azure Kubernetes Service (AKS)** (optional future deployment)
- **Azure SQL Database** (optional)

---

## 🛠️ How to Deploy Locally

1. Install [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Login to Azure:

   ```bash
   az login
   ```

4. Navigate to the `infra/` directory and run:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

✅ This will create all the necessary Azure infrastructure.

---

## 🔒 Secrets and Authentication

This project uses a **Service Principal** for authentication to Azure.

### Required Environment Variables:

| Variable | Description |
|:---------|:------------|
| `ARM_CLIENT_ID` | Azure Service Principal App ID |
| `ARM_CLIENT_SECRET` | Azure Service Principal Secret |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID |
| `ARM_TENANT_ID` | Azure Tenant ID |

### Where Secrets Are Stored:

- **Azure DevOps:** Project Settings → Service Connections
- **GitHub Actions:** Repository Settings → Secrets and Variables

---

## 🔥 CI/CD Pipelines

### Azure DevOps
- Pipeline file: `azure-pipelines.yml`
- Automatically triggered on pushes to `main`
- Steps:
  - `terraform init`, `terraform plan`, `terraform apply`
  - Build .NET app
  - Deploy app to Azure App Service

### GitHub Actions
- Workflow file: `.github/workflows/terraform.yml`
- Automatically triggered on pushes to `main`
- Same flow: Terraform + .NET App Deployment

---

## 📈 Environment Management

- Separate **Resource Groups** for different environments (e.g., dev, prod)
- **Remote backend** for Terraform state stored securely in Azure Blob Storage
- (Optional) Use Terraform Workspaces for full environment separation

---

## 🧐 Future Enhancements

- Add Azure Key Vault integration for secrets
- Expand to full AKS deployment with Dockerized .NET app
- Implement application monitoring with Azure Monitor
- Auto-scaling setup for App Service and AKS

---

## 📜 License

This project is provided for **learning**, **demonstration**, and **portfolio** purposes.

Feel free to fork, modify, and use it for your own professional growth!

---

✅ Built fully with real DevOps best practices — ready for production standards.