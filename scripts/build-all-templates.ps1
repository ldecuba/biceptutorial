# build-all-templates.ps1
# Script to build all Bicep templates to ARM JSON

param(
    [string]$SourcePath = "examples",
    [string]$OutputPath = "compiled",
    [switch]$Force
)

Write-Host "Building all Bicep templates..." -ForegroundColor Green
Write-Host "Source: $SourcePath" -ForegroundColor Cyan
Write-Host "Output: $OutputPath" -ForegroundColor Cyan

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Find all Bicep files
$bicepFiles = Get-ChildItem -Path $SourcePath -Filter "*.bicep" -Recurse -File

if ($bicepFiles.Count -eq 0) {
    Write-Host "No Bicep files found in $SourcePath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($bicepFiles.Count) Bicep file(s)" -ForegroundColor Cyan

$successCount = 0
$failedCount = 0

foreach ($bicepFile in $bicepFiles) {
    $relativePath = $bicepFile.FullName.Replace((Get-Location).Path, '').TrimStart('\')
    $outputFile = Join-Path $OutputPath ($bicepFile.Name -replace '\.bicep$', '.json')
    
    Write-Host "
Building: $relativePath" -ForegroundColor Yellow
    Write-Host "Output: $outputFile" -ForegroundColor Gray
    
    try {
        # Build the Bicep file
        az bicep build --file $bicepFile.FullName --outfile $outputFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Build successful" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  ✗ Build failed" -ForegroundColor Red
            $failedCount++
        }
    } catch {
        Write-Host "  ✗ Build error: $_" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host "
Build Summary:" -ForegroundColor Cyan
Write-Host "  Total files: $($bicepFiles.Count)" -ForegroundColor White
Write-Host "  Successful: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failedCount" -ForegroundColor Red

if ($failedCount -eq 0) {
    Write-Host "
✓ All templates built successfully!" -ForegroundColor Green
} else {
    Write-Host "
✗ Some templates failed to build" -ForegroundColor Red
    exit 1
}
