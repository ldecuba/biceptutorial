# quick-validate.ps1 - Quick syntax validation (no Azure resources needed)

Write-Host "Quick validation: Checking Bicep syntax..." -ForegroundColor Green

$failedCount = 0
$totalCount = 0

# Find all .bicep files
$bicepFiles = Get-ChildItem -Path "examples" -Filter "*.bicep" -Recurse -File

if ($bicepFiles.Count -eq 0) {
    Write-Host "No Bicep templates found in examples directory" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($bicepFiles.Count) Bicep template(s)" -ForegroundColor Cyan
Write-Host ""

foreach ($templateFile in $bicepFiles) {
    $totalCount++
    $relativePath = $templateFile.FullName.Replace((Get-Location).Path, '').TrimStart('\')
    
    Write-Host "Checking syntax: $relativePath" -ForegroundColor Cyan
    
    try {
        $buildResult = az bicep build --file $templateFile.FullName --stdout 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Syntax valid" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Syntax error: $buildResult" -ForegroundColor Red
            $failedCount++
        }
    } catch {
        Write-Host "  ✗ Error: $_" -ForegroundColor Red
        $failedCount++
    }
}

# Summary
Write-Host ""
Write-Host "Quick Validation Summary:" -ForegroundColor Cyan
Write-Host "  Total templates: $totalCount" -ForegroundColor White
Write-Host "  Valid syntax: " -ForegroundColor Green
Write-Host "  Syntax errors: $failedCount" -ForegroundColor Red

if ($failedCount -eq 0) {
    Write-Host ""
    Write-Host "✓ All templates have valid syntax!" -ForegroundColor Green
    Write-Host "Run 'scripts\validate-all.ps1' for full deployment validation." -ForegroundColor Yellow
    exit 0
} else {
    Write-Host ""
    Write-Host "✗ Some templates have syntax errors" -ForegroundColor Red
    exit 1
}
