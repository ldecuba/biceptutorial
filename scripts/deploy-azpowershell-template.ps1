# deploy-azpowershell-template.ps1
# Generic Azure PowerShell deployment script template

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

Write-Host "Deploying Bicep template using Azure PowerShell..." -ForegroundColor Green
Write-Host "Template: $TemplateFile" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan
Write-Host "Deployment Name: $DeploymentName" -ForegroundColor Cyan

# Check if template file exists
if (-not (Test-Path $TemplateFile)) {
    Write-Host "Template file not found: $TemplateFile" -ForegroundColor Red
    exit 1
}

# Ensure you're logged in to Azure
$context = Get-AzContext
if (-not $context) {
    Write-Host "Please login to Azure first..." -ForegroundColor Yellow
    Connect-AzAccount
}

# Create resource group if it doesn't exist
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-Host "Creating resource group..." -ForegroundColor Yellow
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
} else {
    Write-Host "Resource group already exists" -ForegroundColor Green
}

# Deploy template
Write-Host "
Deploying template..." -ForegroundColor Yellow
try {
    $deployParams = @{
        ResourceGroupName = $ResourceGroupName
        TemplateFile = $TemplateFile
        Name = $DeploymentName
        Verbose = $true
    }
    
    # Add parameters file if provided
    if ($ParametersFile -and (Test-Path $ParametersFile)) {
        Write-Host "Using parameters file: $ParametersFile" -ForegroundColor Cyan
        $deployParams.TemplateParameterFile = $ParametersFile
    }
    
    $deployment = New-AzResourceGroupDeployment @deployParams

    if ($deployment.ProvisioningState -eq "Succeeded") {
        Write-Host "
Deployment completed successfully!" -ForegroundColor Green
        
        # Show deployment details
        Write-Host "
Deployment details:" -ForegroundColor Cyan
        $deployment | Select-Object DeploymentName, ProvisioningState, Timestamp, Mode | Format-Table
        
        # Show outputs if any
        if ($deployment.Outputs) {
            Write-Host "Deployment outputs:" -ForegroundColor Cyan
            $deployment.Outputs | ConvertTo-Json -Depth 3
        }
        
        # Show created resources
        Write-Host "
Created resources:" -ForegroundColor Green
        Get-AzResource -ResourceGroupName $ResourceGroupName | Format-Table Name, ResourceType, Location
    } else {
        Write-Host "Deployment failed with state: $($deployment.ProvisioningState)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "
Deployment completed successfully! 🎉" -ForegroundColor Green
