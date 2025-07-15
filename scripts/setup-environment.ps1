# setup-environment.ps1
# PowerShell script to set up Bicep development environment

Write-Host "Setting up Bicep development environment..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    az --version | Out-Null
    Write-Host "✓ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "Azure CLI is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows" -ForegroundColor Yellow
    exit 1
}

# Install/upgrade Bicep CLI
Write-Host "Installing/upgrading Bicep CLI..." -ForegroundColor Yellow
az bicep install
az bicep upgrade

Write-Host "✓ Bicep CLI installed/upgraded" -ForegroundColor Green

# Check versions
Write-Host ""
Write-Host "Installed versions:" -ForegroundColor Cyan
az --version | Select-String -Pattern "(azure-cli|bicep)"

# Login check
Write-Host ""
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    az account show | Out-Null
    Write-Host "✓ Already logged in to Azure" -ForegroundColor Green
    az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" --output table
} catch {
    Write-Host "Please log in to Azure:" -ForegroundColor Yellow
    az login
}

Write-Host ""
Write-Host "Setup complete! You can now run the Bicep examples." -ForegroundColor Green
Write-Host ""
Write-Host "Recommended VS Code extensions:" -ForegroundColor Cyan
Write-Host "- Bicep" -ForegroundColor White
Write-Host "- Azure Account" -ForegroundColor White
Write-Host "- Azure Resources" -ForegroundColor White
