# list-resources.ps1
# Utility script to list all resources in tutorial resource groups

param(
    [string]$ResourceGroupPattern = "*bicep*"
)

Write-Host "Listing resources in Bicep tutorial resource groups..." -ForegroundColor Green
Write-Host "Pattern: $ResourceGroupPattern" -ForegroundColor Cyan

# Get all resource groups matching the pattern
$resourceGroups = az group list --query "[?contains(name, 'bicep')]" | ConvertFrom-Json

if ($resourceGroups.Count -eq 0) {
    Write-Host "No resource groups found matching pattern: $ResourceGroupPattern" -ForegroundColor Yellow
    exit 0
}

Write-Host "
Found $($resourceGroups.Count) resource group(s):" -ForegroundColor Cyan

foreach ($rg in $resourceGroups) {
    Write-Host "
📁 $($rg.name) ($($rg.location))" -ForegroundColor Yellow
    Write-Host "   Status: $($rg.properties.provisioningState)" -ForegroundColor Gray
    
    # List resources in this resource group
    $resources = az resource list --resource-group $rg.name | ConvertFrom-Json
    
    if ($resources.Count -eq 0) {
        Write-Host "   No resources found" -ForegroundColor Gray
    } else {
        Write-Host "   Resources ($($resources.Count)):" -ForegroundColor Cyan
        $resources | ForEach-Object {
            Write-Host "   └─ $($_.name) ($($_.type))" -ForegroundColor White
        }
    }
}

# Summary
$totalResources = ($resourceGroups | ForEach-Object { 
    $rgName = $_.name
    (az resource list --resource-group $rgName | ConvertFrom-Json).Count 
}) | Measure-Object -Sum

Write-Host "
Summary:" -ForegroundColor Green
Write-Host "  Resource Groups: $($resourceGroups.Count)" -ForegroundColor White
Write-Host "  Total Resources: $($totalResources.Sum)" -ForegroundColor White
