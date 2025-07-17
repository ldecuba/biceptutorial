# deploy-template.ps1
# Generic deployment script template for Bicep templates

param(
    [string]$ResourceGroupName = "rg-bicep-tutorial",
    [string]$Location = "East US",
    [string]$TemplateFile = "main.bicep",
    [string]$ParametersFile = "",
    [string]$DeploymentName = ""
)

# Set default deployment name if not provided
if (-not $DeploymentName) {
    $templateBaseName = [System.IO.Path]::GetFileNameWithoutExtension($TemplateFile)
    $DeploymentName = "$templateBaseName-deployment-20250717-133443"
}

Write-Host "Deploying Bicep template..." -ForegroundColor Green
Write-Host "Template: $TemplateFile" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan
Write-Host "Deployment Name: $DeploymentName" -ForegroundColor Cyan

# Check if template file exists
if (-not (Test-Path $TemplateFile)) {
    Write-Host "Template file not found: $TemplateFile" -ForegroundColor Red
    exit 1
}

# Create resource group if it doesn't exist
Write-Host "
Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location "$Location"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Build deployment command
$deployCommand = @(
    "az", "deployment", "group", "create",
    "--resource-group", $ResourceGroupName,
    "--template-file", $TemplateFile,
    "--name", $DeploymentName
)

# Add parameters file if provided
if ($ParametersFile -and (Test-Path $ParametersFile)) {
    Write-Host "Using parameters file: $ParametersFile" -ForegroundColor Cyan
    $deployCommand += "--parameters"
    $deployCommand += "@$ParametersFile"
}

# Deploy template
Write-Host "
Deploying template..." -ForegroundColor Yellow
& $deployCommand[0] $deployCommand[1..($deployCommand.Length-1)]

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
