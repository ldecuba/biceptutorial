# whatif-deployment.ps1
# Utility script to preview deployment changes

param(
    [Parameter(Mandatory=$true)]
    [string]$TemplateFile,
    
    [string]$ResourceGroupName = "rg-bicep-tutorial",
    [string]$Location = "East US",
    [string]$ParametersFile = ""
)

Write-Host "Previewing deployment changes (What-If)..." -ForegroundColor Green
Write-Host "Template: $TemplateFile" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan

# Check if template file exists
if (-not (Test-Path $TemplateFile)) {
    Write-Host "Template file not found: $TemplateFile" -ForegroundColor Red
    exit 1
}

# Ensure resource group exists
$resourceGroup = az group show --name $ResourceGroupName 2>$null
if (-not $resourceGroup) {
    Write-Host "Resource group does not exist. Creating..." -ForegroundColor Yellow
    az group create --name $ResourceGroupName --location "$Location"
}

# Build what-if command
$whatIfCommand = @(
    "az", "deployment", "group", "what-if",
    "--resource-group", $ResourceGroupName,
    "--template-file", $TemplateFile
)

# Add parameters file if provided
if ($ParametersFile -and (Test-Path $ParametersFile)) {
    Write-Host "Using parameters file: $ParametersFile" -ForegroundColor Cyan
    $whatIfCommand += "--parameters"
    $whatIfCommand += "@$ParametersFile"
}

# Run what-if analysis
Write-Host "
Running what-if analysis..." -ForegroundColor Yellow
& $whatIfCommand[0] $whatIfCommand[1..($whatIfCommand.Length-1)]

if ($LASTEXITCODE -eq 0) {
    Write-Host "
What-if analysis completed successfully!" -ForegroundColor Green
    Write-Host "Review the changes above before deploying." -ForegroundColor Yellow
} else {
    Write-Host "
What-if analysis failed. Check the template and parameters." -ForegroundColor Red
    exit 1
}
