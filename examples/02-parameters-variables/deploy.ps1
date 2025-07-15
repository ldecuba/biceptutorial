# deploy.ps1 - Example 2 PowerShell deployment script

param(
    [string]$ResourceGroup = "rg-bicep-tutorial",
    [string]$Location = "East US",
    [string]$Environment = "dev"
)

$DeploymentName = "params-deployment-20250715-131118"

Write-Host "Deploying Bicep template with parameters and variables..." -ForegroundColor Green
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "Deployment Name: $DeploymentName" -ForegroundColor Cyan

# Determine parameter file based on environment
$parameterFile = if ($Environment -eq "prod") { 
    "storage.prod.parameters.json" 
} else { 
    "storage.parameters.json" 
}

Write-Host "Using parameter file: $parameterFile" -ForegroundColor Yellow

# Create resource group if it doesn't exist
Write-Host "
Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location "$Location"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Deploy template with parameters
Write-Host "Deploying template..." -ForegroundColor Yellow
az deployment group create `
  --resource-group $ResourceGroup `
  --template-file storage-with-params.bicep `
  --parameters "@$parameterFile" `
  --name $DeploymentName

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed" -ForegroundColor Red
    exit 1
}

# Show deployment outputs
Write-Host "
Deployment completed successfully!" -ForegroundColor Green
Write-Host "
Deployment outputs:" -ForegroundColor Cyan
az deployment group show `
  --resource-group $ResourceGroup `
  --name $DeploymentName `
  --query "properties.outputs" `
  --output json

Write-Host "
Created resources:" -ForegroundColor Green
az resource list --resource-group $ResourceGroup --output table

Write-Host "
Example usage for different environments:" -ForegroundColor Yellow
Write-Host "Development: .\deploy.ps1 -Environment dev" -ForegroundColor White
Write-Host "Production:  .\deploy.ps1 -Environment prod -ResourceGroup 'rg-bicep-prod'" -ForegroundColor White
