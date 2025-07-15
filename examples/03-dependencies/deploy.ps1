# deploy.ps1 - Example 3 deployment script

param(
    [string]$ResourceGroup = "rg-bicep-tutorial",
    [string]$Location = "East US"
)

$DeploymentName = "dependencies-deployment-20250715-120706"

Write-Host "Deploying web app with dependencies..." -ForegroundColor Green

# Create resource group if it doesn't exist
az group create --name $ResourceGroup --location "$Location"

# Deploy template
Write-Host "Deploying template..." -ForegroundColor Yellow
az deployment group create `
  --resource-group $ResourceGroup `
  --template-file web-app-with-storage.bicep `
  --parameters "@web-app.parameters.json" `
  --name $DeploymentName

# Show deployment status
Write-Host "
Deployment completed:" -ForegroundColor Green
az deployment group show `
  --resource-group $ResourceGroup `
  --name $DeploymentName `
  --query "properties.{Status:provisioningState, Duration:duration}" `
  --output table

# Show created resources
Write-Host "
Created resources:" -ForegroundColor Green
az resource list --resource-group $ResourceGroup --output table
