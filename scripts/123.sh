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

# Step 2: Validate dependencies
echo "🔍 Validating dependencies..."
if ! command -v jq >/dev/null 2>&1; then
    echo "❌ 'jq' is required but not installed. Please install jq."
    exit 1
fi

# Validate subscription
if ! az account show --subscription "$ARM_SUBSCRIPTION_ID" >/dev/null 2>&1; then
    echo "❌ Subscription '$ARM_SUBSCRIPTION_ID' not found or inaccessible. Available subscriptions:"
    az account list --output table
    exit 1
fi

# Step 3: Check if Service Principal exists
echo "🔎 Checking if Service Principal '$CUSTOMER_NAME-sp' exists..."
existing_sp=""

# Check if the Service Principal exists
existing_sp=$(az ad sp list --display-name "$CUSTOMER_NAME-sp" --query "[0].appId" -o tsv 2>/dev/null)

set -x  # Enable verbose mode

if [ -n "$existing_sp" ]; then
    echo "ℹ️ Service Principal '$CUSTOMER_NAME-sp' already exists."
    # If SP exists, fetch its credentials (you might need to reset credentials or fetch existing ones)
    sp_credentials=$(az ad sp credential reset --id "$existing_sp" --query "{client_id: appId, client_secret: password, tenant_id: tenant}" -o json) || {
        echo "❌ Failed to reset Service Principal credentials."
        exit 1
    }

    # Extract credentials
    CLIENT_ID=$(echo "$sp_credentials" | jq -r '.client_id')
    CLIENT_SECRET=$(echo "$sp_credentials" | jq -r '.client_secret')
    TENANT_ID=$(echo "$sp_credentials" | jq -r '.tenant_id')
else
    echo "❌ Service Principal '$CUSTOMER_NAME-sp' not found. Creating Service Principal..."
    sp_credentials=$(MSYS_NO_PATHCONV=1 az ad sp create-for-rbac --name "http://$CUSTOMER_NAME-sp" --role contributor --scopes "/subscriptions/$ARM_SUBSCRIPTION_ID" --query "{client_id: appId, client_secret: password, tenant_id: tenant}" -o json) || {
        echo "❌ Failed to create Service Principal."
        exit 1
    }

    # Extract credentials
    CLIENT_ID=$(echo "$sp_credentials" | jq -r '.client_id')
    CLIENT_SECRET=$(echo "$sp_credentials" | jq -r '.client_secret')
    TENANT_ID=$(echo "$sp_credentials" | jq -r '.tenant_id')

    echo "✅ Service Principal '$CUSTOMER_NAME-sp' created successfully."
fi

# Step 4: Get the subscription name (required for service endpoint configuration)
echo "🔍 Fetching subscription name for '$ARM_SUBSCRIPTION_ID'..."
SUBSCRIPTION_NAME=$(az account show --subscription "$ARM_SUBSCRIPTION_ID" --query name -o tsv) || {
    echo "❌ Failed to fetch subscription name."
    exit 1
}

# Step 5: Create Service Connection in Azure DevOps using SP credentials
echo "🔧 Checking if Service Connection '$CUSTOMER_NAME-sp' exists in Azure DevOps..."

existing_connection=$(az devops service-endpoint list --org https://dev.azure.com/"$AZURE_DEVOPS_ORG" --project "$AZURE_DEVOPS_PROJECT" --query "[?name=='$CUSTOMER_NAME-sp'].name" -o tsv 2>/dev/null)

if [ "$existing_connection" == "$CUSTOMER_NAME-sp" ]; then
    echo "ℹ️ Service connection '$CUSTOMER_NAME-sp' already exists."
else
    echo "❌ Service connection '$CUSTOMER_NAME-sp' not found. Creating service connection..."

    # Construct the service endpoint configuration JSON as a single-line string
    SERVICE_ENDPOINT_CONFIG=$(jq -nc \
        --arg name "$CUSTOMER_NAME-sp" \
        --arg type "azureRm" \
        --arg spId "$CLIENT_ID" \
        --arg spKey "$CLIENT_SECRET" \
        --arg tenantId "$TENANT_ID" \
        --arg subId "$ARM_SUBSCRIPTION_ID" \
        --arg subName "$SUBSCRIPTION_NAME" \
        '{
            "name": $name,
            "serviceEndpointType": $type,
            "connectionData": {
                "serviceprincipalid": $spId,
                "serviceprincipalkey": $spKey,
                "tenantid": $tenantId,
                "subscriptionId": $subId,
                "subscriptionName": $subName
            }
        }')

    # Debug: Print the JSON to verify
    echo "DEBUG: Service Endpoint Config JSON: $SERVICE_ENDPOINT_CONFIG"

    # Create the service connection using the JSON configuration
    # Capture the output (including errors) in a variable
    if output=$(az devops service-endpoint create \
        --org https://dev.azure.com/"$AZURE_DEVOPS_ORG" \
        --project "$AZURE_DEVOPS_PROJECT" \
        --service-endpoint-configuration "$SERVICE_ENDPOINT_CONFIG" 2>&1); then
        echo "✅ Service connection '$CUSTOMER_NAME-sp' created successfully."
    else
        echo "❌ Failed to create service connection. Detailed error message:"
        echo "$output"
        exit 1
    fi
fi

echo "🎉 All steps completed successfully."