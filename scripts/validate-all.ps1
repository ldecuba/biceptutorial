# validate-all.ps1 - PowerShell validation script

Write-Host "Validating all Bicep templates..." -ForegroundColor Green

$RESOURCE_GROUP = "rg-bicep-validation"
$LOCATION = "East US"

# Create temporary resource group for validation
Write-Host "Creating temporary resource group: $RESOURCE_GROUP" -ForegroundColor Yellow
try {
    az group create --name $RESOURCE_GROUP --location "$LOCATION" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create validation resource group" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error creating resource group: $_" -ForegroundColor Red
    exit 1
}

# Function to validate a template
function Test-BicepTemplate {
    param(
        [string]$TemplateFile,
        [string]$ParametersFile,
        [string]$TemplateName
    )
    
    Write-Host "Validating: $TemplateFile" -ForegroundColor Cyan
    
    try {
        # First, try to build the template (syntax check)
        $buildResult = az bicep build --file $TemplateFile --stdout 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ✗ Build failed: $buildResult" -ForegroundColor Red
            return $false
        }
        
        # Then validate deployment
        if (Test-Path $ParametersFile) {
            $result = az deployment group validate `
                --resource-group $RESOURCE_GROUP `
                --template-file $TemplateFile `
                --parameters "@$ParametersFile" `
                --query "properties.provisioningState" `
                --output tsv 2>&1
        } else {
            $result = az deployment group validate `
                --resource-group $RESOURCE_GROUP `
                --template-file $TemplateFile `
                --query "properties.provisioningState" `
                --output tsv 2>&1
        }
        
        if ($result -eq "Succeeded") {
            Write-Host "  ✓ Valid" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ✗ Invalid: $result" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  ✗ Error: $_" -ForegroundColor Red
        return $false
    }
}

# Function to find parameter file for a template
function Get-ParameterFile {
    param(
        [string]$TemplateFile
    )
    
    $templateDir = Split-Path $TemplateFile -Parent
    $templateName = [System.IO.Path]::GetFileNameWithoutExtension($TemplateFile)
    
    # Try different parameter file naming patterns
    $possibleParamFiles = @(
        (Join-Path $templateDir "$templateName.parameters.json"),
        (Join-Path $templateDir "parameters.json"),
        (Join-Path $templateDir "$templateName.params.json")
    )
    
    foreach ($paramFile in $possibleParamFiles) {
        if (Test-Path $paramFile) {
            return $paramFile
        }
    }
    
    return $null
}

# Validate all templates
$failedCount = 0
$totalCount = 0
$validatedTemplates = @()

Write-Host "
Scanning for Bicep templates..." -ForegroundColor Yellow

# Find all .bicep files
$bicepFiles = Get-ChildItem -Path "examples" -Filter "*.bicep" -Recurse -File

if ($bicepFiles.Count -eq 0) {
    Write-Host "No Bicep templates found in examples directory" -ForegroundColor Yellow
} else {
    Write-Host "Found $($bicepFiles.Count) Bicep template(s)" -ForegroundColor Cyan
}

foreach ($templateFile in $bicepFiles) {
    $totalCount++
    
    $templatePath = $templateFile.FullName
    $templateName = $templateFile.BaseName
    $relativePath = $templatePath.Replace((Get-Location).Path, '').TrimStart('\')
    
    # Get parameter file
    $paramsFile = Get-ParameterFile -TemplateFile $templatePath
    
    # Skip main templates without parameter files (they usually need them)
    if (-not $paramsFile -and $templateName -eq "main") {
        Write-Host "Skipping $relativePath (main template without parameter file)" -ForegroundColor Yellow
        $totalCount--
        continue
    }
    
    # Skip module files that don't have parameter files (they're meant to be used by other templates)
    if (-not $paramsFile -and $templatePath -like "*\modules\*") {
        Write-Host "Skipping $relativePath (module without parameter file)" -ForegroundColor Gray
        $totalCount--
        continue
    }
    
    $validationResult = Test-BicepTemplate -TemplateFile $templatePath -ParametersFile $paramsFile -TemplateName $templateName
    
    $validatedTemplates += [PSCustomObject]@{
        Template = $relativePath
        ParameterFile = if ($paramsFile) { Split-Path $paramsFile -Leaf } else { "None" }
        Status = if ($validationResult) { "✓ Valid" } else { "✗ Invalid" }
        Valid = $validationResult
    }
    
    if (-not $validationResult) {
        $failedCount++
    }
}

# Cleanup temporary resource group
Write-Host "
Cleaning up temporary resource group..." -ForegroundColor Yellow
try {
    az group delete --name $RESOURCE_GROUP --yes --no-wait | Out-Null
} catch {
    Write-Host "Warning: Could not delete temporary resource group $RESOURCE_GROUP" -ForegroundColor Yellow
}

# Summary
Write-Host "
" + "="*60 -ForegroundColor Cyan
Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

if ($validatedTemplates.Count -gt 0) {
    $validatedTemplates | Format-Table Template, ParameterFile, Status -AutoSize
}

Write-Host "Total templates validated: $totalCount" -ForegroundColor White
Write-Host "Successful: " -ForegroundColor Green
Write-Host "Failed: $failedCount" -ForegroundColor Red

if ($failedCount -eq 0) {
    Write-Host "
✓ All templates are valid!" -ForegroundColor Green
    Write-Host "Your Bicep tutorial is ready for deployment! 🚀" -ForegroundColor Green
    exit 0
} else {
    Write-Host "
✗ Some templates failed validation" -ForegroundColor Red
    Write-Host "Please review the errors above and fix the templates." -ForegroundColor Yellow
    exit 1
}
