variable "location" {
  default = "Australia Central"
}

variable "resource_group_name" {
  default = "devops-demo2-rg"
}

variable "sql_admin_username" {
  description = "Administrator login for the SQL Server"
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Administrator password for the SQL Server"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}