# manage-resource-groups.ps1
# Script to manage tutorial resource groups

param(
    [ValidateSet("list", "create", "delete", "clean")]
    [string]$Action = "list",
    [string]$ResourceGroupName = "",
    [string]$Location = "East US"
)

Write-Host "Managing Bicep tutorial resource groups..." -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Cyan

switch ($Action) {
    "list" {
        Write-Host "
Listing all tutorial resource groups..." -ForegroundColor Yellow
        $resourceGroups = az group list --query "[?contains(name, 'bicep')]" | ConvertFrom-Json
        
        if ($resourceGroups.Count -eq 0) {
            Write-Host "No tutorial resource groups found" -ForegroundColor Gray
        } else {
            Write-Host "Found $($resourceGroups.Count) resource group(s):" -ForegroundColor Cyan
            $resourceGroups | ForEach-Object {
                Write-Host "  📁 $($_.name) ($($_.location)) - $($_.properties.provisioningState)" -ForegroundColor White
            }
        }
    }
    
    "create" {
        if (-not $ResourceGroupName) {
            Write-Host "Resource group name is required for create action" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "
Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
        az group create --name $ResourceGroupName --location "$Location"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Resource group created successfully" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to create resource group" -ForegroundColor Red
            exit 1
        }
    }
    
    "delete" {
        if (-not $ResourceGroupName) {
            Write-Host "Resource group name is required for delete action" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "
Deleting resource group: $ResourceGroupName" -ForegroundColor Yellow
        $response = Read-Host "Are you sure you want to delete this resource group? (y/N)"
        
        if ($response -eq 'y' -or $response -eq 'Y') {
            az group delete --name $ResourceGroupName --yes --no-wait
            Write-Host "✓ Resource group deletion initiated" -ForegroundColor Green
        } else {
            Write-Host "Deletion cancelled" -ForegroundColor Yellow
        }
    }
    
    "clean" {
        Write-Host "
Cleaning up empty tutorial resource groups..." -ForegroundColor Yellow
        $resourceGroups = az group list --query "[?contains(name, 'bicep')]" | ConvertFrom-Json
        
        foreach ($rg in $resourceGroups) {
            $resources = az resource list --resource-group $rg.name | ConvertFrom-Json
            
            if ($resources.Count -eq 0) {
                Write-Host "Empty resource group found: $($rg.name)" -ForegroundColor Yellow
                $response = Read-Host "Delete empty resource group $($rg.name)? (y/N)"
                
                if ($response -eq 'y' -or $response -eq 'Y') {
                    az group delete --name $rg.name --yes --no-wait
                    Write-Host "✓ Deleted empty resource group: $($rg.name)" -ForegroundColor Green
                }
            }
        }
    }
}

Write-Host "
Usage examples:" -ForegroundColor Cyan
Write-Host "  List all: .\scripts\manage-resource-groups.ps1 -Action list" -ForegroundColor White
Write-Host "  Create: .\scripts\manage-resource-groups.ps1 -Action create -ResourceGroupName 'rg-test'" -ForegroundColor White
Write-Host "  Delete: .\scripts\manage-resource-groups.ps1 -Action delete -ResourceGroupName 'rg-test'" -ForegroundColor White
Write-Host "  Clean empty: .\scripts\manage-resource-groups.ps1 -Action clean" -ForegroundColor White
