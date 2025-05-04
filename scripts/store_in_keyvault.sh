#!/bin/bash
set -e

ENV_FILE=".env.customer"

echo "📄 Loading environment variables from $ENV_FILE..."
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Missing $ENV_FILE file."
  exit 1
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)

VAULT_NAME="${CUSTOMER_NAME}-kv"
RESOURCE_GROUP="${CUSTOMER_NAME}-rg"

# Login
echo "🔐 Logging into Azure..."
az login --service-principal \
  --username "$ARM_CLIENT_ID" \
  --password "$ARM_CLIENT_SECRET" \
  --tenant "$ARM_TENANT_ID" > /dev/null

echo "📦 Setting subscription context..."
az account set --subscription "$ARM_SUBSCRIPTION_ID"
az account show --output table

# Register Key Vault provider
echo "📦 Ensuring KeyVault provider is registered..."
az provider register --namespace Microsoft.KeyVault > /dev/null

# Resource group
echo "📁 Checking resource group '$RESOURCE_GROUP'..."
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "ℹ️ Resource group already exists."
else
  echo "📁 Creating resource group..."
  az group create --name "$RESOURCE_GROUP" --location "$REGION" > /dev/null
  echo "✅ Resource group created."
fi

# Key Vault
echo "🔐 Checking Key Vault '$VAULT_NAME'..."
if az keyvault show --name "$VAULT_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "ℹ️ Key Vault already exists."
else
  echo "🔐 Creating Key Vault (with RBAC enabled)..."
  az keyvault create \
    --name "$VAULT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$REGION" \
    --enable-rbac-authorization true > /dev/null
  echo "✅ Key Vault created."
fi

# RBAC role assignment
echo "⚙️ Assigning 'Key Vault Secrets Officer' role to SP..."

# Ensure context is explicitly set before assigning
az account set --subscription "$ARM_SUBSCRIPTION_ID"

az role assignment create \
  --assignee "$ARM_CLIENT_ID" \
  --role "Key Vault Secrets Officer" \
  --scope "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$VAULT_NAME" \
  > /dev/null || echo "⚠️ Role already assigned or permission denied."

# Wait for RBAC propagation
echo "⏳ Waiting 20s for RBAC permissions to take effect..."
sleep 20

# Secret storage with retries
store_secret() {
  local name="$1"
  local value="$2"
  local max_retries=5

  for ((i=1; i<=max_retries; i++)); do
    echo "🔐 Setting secret '$name' (attempt $i/$max_retries)..."
    if az keyvault secret set --vault-name "$VAULT_NAME" --name "$name" --value "$value" > /dev/null; then
      echo "✅ Secret '$name' stored."
      return 0
    else
      echo "❌ Failed to set '$name'. Retrying in 10s..."
      sleep 10
    fi
  done

  echo "🚨 Giving up after $max_retries failed attempts to set '$name'."
  exit 1
}

# Store secrets
store_secret "client-id" "$ARM_CLIENT_ID"
store_secret "client-secret" "$ARM_CLIENT_SECRET"
store_secret "tenant-id" "$ARM_TENANT_ID"
store_secret "subscription-id" "$ARM_SUBSCRIPTION_ID"

echo "🎉 All secrets stored successfully in Key Vault: $VAULT_NAME"
