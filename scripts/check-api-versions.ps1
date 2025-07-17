# check-api-versions.ps1
# Script to check for outdated API versions in Bicep templates

param(
    [string]$Path = "examples",
    [switch]$ShowLatest,
    [switch]$Detailed
)

Write-Host "Checking API versions in Bicep templates..." -ForegroundColor Green
Write-Host "Scanning path: $Path" -ForegroundColor Cyan

# Find all Bicep files
$bicepFiles = Get-ChildItem -Path $Path -Filter "*.bicep" -Recurse -File

if ($bicepFiles.Count -eq 0) {
    Write-Host "No Bicep files found in $Path" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($bicepFiles.Count) Bicep file(s)" -ForegroundColor Cyan

# Extract API versions from all files
$allVersions = @{}
$resourceTypes = @{}

foreach ($file in $bicepFiles) {
    $content = Get-Content $file.FullName -Raw
    $relativePath = $file.FullName.Replace((Get-Location).Path, '').TrimStart('\')
    
    # Match resource declarations with API versions
    $resourcePattern = "resource\s+\w+\s+'([^']+)@([^']+)'"
    $matches = [regex]::Matches($content, $resourcePattern)
    
    foreach ($match in $matches) {
        $resourceType = $match.Groups[1].Value
        $apiVersion = $match.Groups[2].Value
        
        if (-not $allVersions.ContainsKey($apiVersion)) {
            $allVersions[$apiVersion] = @()
        }
        $allVersions[$apiVersion] += @{
            File = $relativePath
            ResourceType = $resourceType
        }
        
        if (-not $resourceTypes.ContainsKey($resourceType)) {
            $resourceTypes[$resourceType] = @()
        }
        $resourceTypes[$resourceType] += @{
            File = $relativePath
            ApiVersion = $apiVersion
        }
    }
}

# Display results
Write-Host "
API Versions Summary:" -ForegroundColor Yellow
Write-Host "="*50 -ForegroundColor Gray

$sortedVersions = $allVersions.Keys | Sort-Object -Descending
foreach ($version in $sortedVersions) {
    $count = $allVersions[$version].Count
    $isPreview = $version -like "*preview*"
    $color = if ($isPreview) { "Yellow" } else { "Green" }
    
    Write-Host "📅 $version" -ForegroundColor $color -NoNewline
    Write-Host " (used $count time(s))" -ForegroundColor Gray
    
    if ($Detailed) {
        $allVersions[$version] | ForEach-Object {
            Write-Host "   └─ $($_.ResourceType) in $($_.File)" -ForegroundColor Gray
        }
    }
}

# Check for outdated versions
Write-Host "
Outdated Version Analysis:" -ForegroundColor Yellow
Write-Host "="*50 -ForegroundColor Gray

$twoYearsAgo = (Get-Date).AddYears(-2).ToString("yyyy-MM-dd")
$oneYearAgo = (Get-Date).AddYears(-1).ToString("yyyy-MM-dd")

$veryOld = $allVersions.Keys | Where-Object { $_ -notlike "*preview*" -and $_ -lt $twoYearsAgo }
$old = $allVersions.Keys | Where-Object { $_ -notlike "*preview*" -and $_ -lt $oneYearAgo -and $_ -ge $twoYearsAgo }
$preview = $allVersions.Keys | Where-Object { $_ -like "*preview*" }

if ($veryOld) {
    Write-Host "🔴 Very Old (2+ years):" -ForegroundColor Red
    $veryOld | ForEach-Object {
        Write-Host "   $_" -ForegroundColor Red
    }
}

if ($old) {
    Write-Host "🟡 Old (1-2 years):" -ForegroundColor Yellow  
    $old | ForEach-Object {
        Write-Host "   $_" -ForegroundColor Yellow
    }
}

if ($preview) {
    Write-Host "🟠 Preview Versions:" -ForegroundColor DarkYellow
    $preview | ForEach-Object {
        Write-Host "   $_" -ForegroundColor DarkYellow
    }
}

# Show latest available versions if requested
if ($ShowLatest) {
    Write-Host "
Latest Available API Versions:" -ForegroundColor Yellow
    Write-Host "="*50 -ForegroundColor Gray
    Write-Host "Checking Azure for latest versions..." -ForegroundColor Cyan
    
    $uniqueResourceTypes = $resourceTypes.Keys | Sort-Object
    foreach ($resourceType in $uniqueResourceTypes) {
        if ($resourceType -notmatch '/') {
            continue  # Skip malformed resource types
        }
        
        $namespace = $resourceType.Split('/')[0]
        $type = $resourceType.Split('/')[1]
        
        try {
            $latest = az provider show --namespace $namespace --query "resourceTypes[?resourceType=='$type'].apiVersions[0]" --output tsv 2>$null
            if ($latest) {
                $current = ($resourceTypes[$resourceType] | Select-Object -First 1).ApiVersion
                $status = if ($current -eq $latest) { "✅" } else { "⚠️" }
                Write-Host "$status $resourceType" -ForegroundColor Cyan
                Write-Host "   Current: $current" -ForegroundColor Gray
                Write-Host "   Latest:  $latest" -ForegroundColor Gray
            }
        } catch {
            Write-Host "❓ $resourceType (unable to check)" -ForegroundColor Gray
        }
    }
}

# Summary and recommendations
Write-Host "
Recommendations:" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Gray

if ($veryOld) {
    Write-Host "🔴 Update very old API versions immediately" -ForegroundColor Red
    Write-Host "   These may have security vulnerabilities or missing features" -ForegroundColor Gray
}

if ($old) {
    Write-Host "🟡 Consider updating old API versions" -ForegroundColor Yellow
    Write-Host "   These work but may lack newer features" -ForegroundColor Gray
}

if ($preview) {
    Write-Host "🟠 Review preview API versions" -ForegroundColor DarkYellow
    Write-Host "   Use stable versions for production deployments" -ForegroundColor Gray
}

if (-not $veryOld -and -not $old -and -not $preview) {
    Write-Host "✅ All API versions look good!" -ForegroundColor Green
    Write-Host "   No immediate updates required" -ForegroundColor Gray
}

Write-Host "
Usage Examples:" -ForegroundColor Cyan
Write-Host "  Check with details:     .\scripts\check-api-versions.ps1 -Detailed" -ForegroundColor White
Write-Host "  Check latest versions:  .\scripts\check-api-versions.ps1 -ShowLatest" -ForegroundColor White
Write-Host "  Check specific path:    .\scripts\check-api-versions.ps1 -Path 'examples\05-modules'" -ForegroundColor White
