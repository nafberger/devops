#!/bin/bash
set -e

# Step 1: Load environment variables from the .env file
ENV_FILE=".env.customer"

echo "📄 Loading environment variables from $ENV_FILE..."
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Missing $ENV_FILE file."
  exit 1
fi

# Export the variables from the .env file
export $(grep -v '^#' "$ENV_FILE" | xargs)

# Step 2: Install the Azure DevOps extension (if not installed) without asking
echo "🔧 Ensuring Azure DevOps extension is installed..."
az extension add --name azure-devops --yes || echo "ℹ️ Azure DevOps extension is already installed."

# Step 3: Create the Azure DevOps Project name using CUSTOMER_NAME
PROJECT_NAME="${CUSTOMER_NAME}-Project"

# Step 4: Login to Azure DevOps using your Azure DevOps Personal Access Token (PAT)
echo "🔑 Logging into Azure DevOps using PAT..."
echo $AZURE_DEVOPS_PAT | az devops login

# Step 5: Check if the project already exists
echo "📁 Checking if Azure DevOps project '$PROJECT_NAME' exists..."

# Initialize existing_project as empty
existing_project=""
# Check if project exists without exiting on failure
if az devops project show --project "$PROJECT_NAME" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --query "name" -o tsv 2>/dev/null; then
    existing_project=$(az devops project show --project "$PROJECT_NAME" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --query "name" -o tsv)
fi

# Debugging output
echo "existing_project: '$existing_project'"

set -x  # Enable verbose mode
# If the project doesn't exist, create it
if [ -z "$existing_project" ]; then
    echo "❌ Project '$PROJECT_NAME' not found. Creating the project..."
    if az devops project create --name "$PROJECT_NAME" --org "https://dev.azure.com/$AZURE_DEVOPS_ORG" --process "Agile" --source-control "git" --visibility "private" >/dev/null; then
        echo "✅ Project '$PROJECT_NAME' created successfully."
    else
        echo "❌ Failed to create project '$PROJECT_NAME'."
        exit 1
    fi
else
    echo "ℹ️ Project '$PROJECT_NAME' already exists."
fi