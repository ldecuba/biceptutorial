# deploy.ps1 - Common patterns example

param(
    [string]$ResourceGroupName = "rg-bicep-tutorial",
    [string]$Location = "East US"
)

$DeploymentName = "conditional-deployment-deployment-20250717-134617"

Write-Host "Common patterns example..." -ForegroundColor Green
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan
Write-Host "Deployment Name: $DeploymentName" -ForegroundColor Cyan

# Create resource group if it doesn't exist
Write-Host "
Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location "$Location"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Deploy template
Write-Host "Deploying template..." -ForegroundColor Yellowaz deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "conditional-deployment.bicep" `
    --name $DeploymentName
if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed" -ForegroundColor Red
    exit 1
}

# Show deployment status
Write-Host "
Deployment completed successfully!" -ForegroundColor Green
az deployment group show `
    --resource-group $ResourceGroupName `
    --name $DeploymentName `
    --query "properties.{Status:provisioningState, Timestamp:timestamp}" `
    --output table

# Show outputs if any
Write-Host "
Deployment outputs:" -ForegroundColor Cyan
az deployment group show `
    --resource-group $ResourceGroupName `
    --name $DeploymentName `
    --query "properties.outputs" `
    --output json

Write-Host "
Created resources:" -ForegroundColor Green
az resource list --resource-group $ResourceGroupName --output table

Write-Host "
Deployment completed! 🎉" -ForegroundColor Green
