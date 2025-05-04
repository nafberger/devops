variable "azure_devops_org_url" {
  description = "The URL of the Azure DevOps organization (e.g., https://dev.azure.com/your-org)"
  type        = string
  # Remove default to ensure the user provides the correct org URL
}

variable "azure_devops_pat" {
  description = "Personal Access Token (PAT) for Azure DevOps authentication"
  type        = string
  sensitive   = true
  # Remove default for security; value should be provided securely
}

variable "subscription_id" {
  description = "Azure subscription ID for resource management"
  type        = string
  # Remove default; value should be provided securely
}

variable "tenant_id" {
  description = "Azure AD tenant ID for authentication"
  type        = string
  # Remove default; value should be provided securely
}

variable "client_id" {
  description = "Client ID of the Azure AD service principal for authentication"
  type        = string
  # No default; value should be provided securely
}

variable "client_secret" {
  description = "Client secret of the Azure AD service principal for authentication"
  type        = string
  sensitive   = true
  # No default; value should be provided securely
}

variable "customer_name" {
  description = "Name of the customer or project, used for naming resources"
  type        = string
  default     = "demo-client"
}

variable "region" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "eastus"
}