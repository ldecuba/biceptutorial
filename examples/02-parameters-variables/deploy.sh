#!/bin/bash

# deploy.sh - Example 2 Bash deployment script

# Set default values
RESOURCE_GROUP="rg-bicep-tutorial"
LOCATION="East US"
ENVIRONMENT="dev"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -g|--resource-group)
      RESOURCE_GROUP="$2"
      shift 2
      ;;
    -l|--location)
      LOCATION="$2"
      shift 2
      ;;
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

DEPLOYMENT_NAME="params-deployment-$(date +%Y%m%d-%H%M%S)"

echo "Deploying Bicep template with parameters and variables..."
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Environment: $ENVIRONMENT"
echo "Deployment Name: $DEPLOYMENT_NAME"

# Determine parameter file based on environment
if [ "$ENVIRONMENT" = "prod" ]; then
    PARAMETER_FILE="storage.prod.parameters.json"
else
    PARAMETER_FILE="storage.parameters.json"
fi

echo "Using parameter file: $PARAMETER_FILE"

# Create resource group if it doesn't exist
echo ""
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Deploy template with parameters
echo "Deploying template..."
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file storage-with-params.bicep \
  --parameters "@$PARAMETER_FILE" \
  --name $DEPLOYMENT_NAME

# Show deployment outputs
echo ""
echo "Deployment outputs:"
az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs" \
  --output json

echo ""
echo "Created resources:"
az resource list --resource-group $RESOURCE_GROUP --output table

echo ""
echo "Example usage for different environments:"
echo "Development: ./deploy.sh -e dev"
echo "Production:  ./deploy.sh -e prod -g rg-bicep-prod"
