# deploy.ps1
# PowerShell deployment script for first Bicep template

# Set variables
$RESOURCE_GROUP = "rg-bicep-tutorial"
$LOCATION = "East US"
$DEPLOYMENT_NAME = "first-deployment-20250715-095520"

Write-Host "Deploying first Bicep template..." -ForegroundColor Green
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor Cyan
Write-Host "Location: $LOCATION" -ForegroundColor Cyan
Write-Host "Deployment Name: $DEPLOYMENT_NAME" -ForegroundColor Cyan

# Create resource group
Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Deploy template
Write-Host "Deploying template..." -ForegroundColor Yellow
az deployment group create `
  --resource-group $RESOURCE_GROUP `
  --template-file storage.bicep `
  --name $DEPLOYMENT_NAME

# Check deployment status
Write-Host "Deployment completed. Checking status..." -ForegroundColor Green
az deployment group show `
  --resource-group $RESOURCE_GROUP `
  --name $DEPLOYMENT_NAME `
  --query "properties.{Status:provisioningState, Timestamp:timestamp}" `
  --output table

Write-Host "Resources created:" -ForegroundColor Green
az resource list --resource-group $RESOURCE_GROUP --output table
