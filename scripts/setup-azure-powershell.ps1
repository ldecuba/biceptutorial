# setup-azure-powershell.ps1
# Setup script for Azure PowerShell environment

Write-Host "Setting up Azure PowerShell environment for Bicep..." -ForegroundColor Green

# Check if Azure PowerShell is installed
try {
    Get-Module -Name Az -ListAvailable | Out-Null
    Write-Host "✓ Azure PowerShell module is installed" -ForegroundColor Green
} catch {
    Write-Host "Azure PowerShell module is not installed. Installing..." -ForegroundColor Yellow
    Install-Module -Name Az -AllowClobber -Force
    Write-Host "✓ Azure PowerShell module installed" -ForegroundColor Green
}

# Check if Azure CLI is installed (needed for Bicep)
try {
    az --version | Out-Null
    Write-Host "✓ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "Azure CLI is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Install/upgrade Bicep CLI (via Azure CLI)
Write-Host "Installing/upgrading Bicep CLI..." -ForegroundColor Yellow
az bicep install
az bicep upgrade
Write-Host "✓ Bicep CLI installed/upgraded" -ForegroundColor Green

# Check versions
Write-Host ""
Write-Host "Installed versions:" -ForegroundColor Cyan
Write-Host "Azure CLI: " -NoNewline
az --version | Select-String "azure-cli" | ForEach-Object { Write-Host $_.ToString().Split()[1] -ForegroundColor White }
Write-Host "Bicep: " -NoNewline
az --version | Select-String "bicep" | ForEach-Object { Write-Host $_.ToString().Split()[1] -ForegroundColor White }
Write-Host "Azure PowerShell: " -NoNewline
(Get-Module -Name Az -ListAvailable | Select-Object -First 1).Version | ForEach-Object { Write-Host $_.ToString() -ForegroundColor White }

# Login check
Write-Host ""
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    $context = Get-AzContext
    if ($context) {
        Write-Host "✓ Already logged in to Azure PowerShell" -ForegroundColor Green
        Write-Host "Account: $($context.Account.Id)" -ForegroundColor Cyan
        Write-Host "Subscription: $($context.Subscription.Name)" -ForegroundColor Cyan
    } else {
        Write-Host "Please log in to Azure PowerShell:" -ForegroundColor Yellow
        Connect-AzAccount
    }
} catch {
    Write-Host "Please log in to Azure PowerShell:" -ForegroundColor Yellow
    Connect-AzAccount
}

Write-Host ""
Write-Host "Setup complete! You can now use Azure PowerShell for Bicep deployments." -ForegroundColor Green
Write-Host ""
Write-Host "Available deployment options:" -ForegroundColor Cyan
Write-Host "- Azure CLI (Bash): ./deploy.sh" -ForegroundColor White
Write-Host "- Azure CLI (PowerShell): .\deploy.ps1" -ForegroundColor White
Write-Host "- Azure PowerShell: .\deploy-azpowershell.ps1" -ForegroundColor White
