# cleanup.ps1 - PowerShell cleanup script

Write-Host "Cleaning up Bicep tutorial resources..." -ForegroundColor Yellow

# List of resource groups to clean up
$ResourceGroups = @(
    "rg-bicep-tutorial",
    "rg-bicep-examples",
    "rg-bicep-dev",
    "rg-bicep-test",
    "rg-bicep-prod",
    "rg-bicep-three-tier",
    "rg-api-demo",
    "rg-bicep-validation"
)

Write-Host "The following resource groups will be deleted:" -ForegroundColor Cyan
foreach ($rg in $ResourceGroups) {
    try {
        $exists = az group exists --name $rg | ConvertFrom-Json
        if ($exists) {
            Write-Host "  - $rg (exists)" -ForegroundColor Red
        } else {
            Write-Host "  - $rg (does not exist)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  - $rg (unable to check)" -ForegroundColor Yellow
    }
}

Write-Host ""
$response = Read-Host "Are you sure you want to delete these resource groups? (y/N)"

if ($response -eq 'y' -or $response -eq 'Y') {
    foreach ($rg in $ResourceGroups) {
        try {
            $exists = az group exists --name $rg | ConvertFrom-Json
            if ($exists) {
                Write-Host "Deleting resource group: $rg" -ForegroundColor Yellow
                az group delete --name $rg --yes --no-wait
            }
        } catch {
            Write-Host "Error checking/deleting $rg" -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "Cleanup initiated. Resource groups are being deleted in the background." -ForegroundColor Green
    Write-Host "Check status with: az group list --query "[?contains(name, 'bicep')].{Name:name, ProvisioningState:properties.provisioningState}" --output table" -ForegroundColor Cyan
} else {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
}
