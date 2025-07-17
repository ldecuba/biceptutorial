# add-api-version-docs.ps1
# Complete PowerShell script to add API version management documentation

Write-Host "Adding API Version Management documentation..." -ForegroundColor Green

# Ensure docs directory exists
if (-not (Test-Path "docs")) {
    New-Item -ItemType Directory -Path "docs" -Force | Out-Null
}

# Ensure scripts directory exists  
if (-not (Test-Path "scripts")) {
    New-Item -ItemType Directory -Path "scripts" -Force | Out-Null
}

Write-Host "Creating API Version Management guide..." -ForegroundColor Yellow

# Create the complete API version management documentation
@"
# API Version Management in Bicep

## Overview

API versions are crucial in Bicep templates as they determine which features and properties are available for each Azure resource type. Proper API version management ensures your templates are stable, secure, and future-proof.

## Understanding API Versions

### What are API Versions?

API versions represent different iterations of the Azure Resource Manager (ARM) REST API for each resource type. Each version may include:
- New properties and features
- Bug fixes and improvements
- Breaking changes
- Deprecated functionality

### API Version Format

``````bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
//                      Resource Type ──────────┘        └── API Version
``````

API versions follow the format: ``YYYY-MM-DD`` or ``YYYY-MM-DD-preview``

## API Version Lifecycle

### 1. Preview Versions
- **Format**: ``2023-01-01-preview``
- **Purpose**: Early access to new features
- **Stability**: May change or be removed
- **Use Case**: Testing and development only

### 2. Stable Versions
- **Format**: ``2023-01-01``
- **Purpose**: Production-ready functionality
- **Stability**: Guaranteed backward compatibility
- **Use Case**: Production deployments

### 3. Deprecated Versions
- **Status**: Still functional but marked for removal
- **Timeline**: Usually supported for 2-3 years after deprecation
- **Migration**: Should be updated to newer versions

## Best Practices for API Version Management

### 1. Use Stable Versions in Production

``````bicep
// ✅ Good: Stable version for production
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// ❌ Avoid: Preview version in production
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01-preview' = {
  // Preview versions may change or be removed
}
``````

### 2. Use Variables for API Version Management

``````bicep
// Define API versions as variables for easier maintenance
var apiVersions = {
  storage: '2023-01-01'
  webSites: '2023-01-01'
  appServicePlans: '2023-01-01'
  keyVault: '2023-02-01'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@`${apiVersions.storage}' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
``````

### 3. Document API Version Choices

``````bicep
metadata apiVersions = {
  description: 'API versions used in this template'
  lastUpdated: '2025-01-15'
  versions: {
    'Microsoft.Storage/storageAccounts': '2023-01-01'
    'Microsoft.Web/sites': '2023-01-01'
    'Microsoft.Web/serverfarms': '2023-01-01'
  }
  notes: [
    'Using stable versions only for production deployment'
    'Storage API version supports minimum TLS 1.2 requirement'
  ]
}
``````

## Finding and Updating API Versions

### Using Azure CLI

``````bash
# List all API versions for a resource type
az provider show --namespace Microsoft.Storage \
  --query "resourceTypes[?resourceType=='storageAccounts'].apiVersions"

# Get the latest API version
az provider show --namespace Microsoft.Storage \
  --query "resourceTypes[?resourceType=='storageAccounts'].apiVersions[0]" \
  --output tsv
``````

### Using PowerShell

``````powershell
# Get API versions for a resource type
(Get-AzResourceProvider -ProviderNamespace Microsoft.Storage).ResourceTypes | 
  Where-Object ResourceTypeName -eq storageAccounts | 
  Select-Object -ExpandProperty ApiVersions

# Get latest stable API version (non-preview)
`$apiVersions = (Get-AzResourceProvider -ProviderNamespace Microsoft.Storage).ResourceTypes | 
  Where-Object ResourceTypeName -eq storageAccounts | 
  Select-Object -ExpandProperty ApiVersions

`$latestStable = `$apiVersions | Where-Object { `$_ -notlike "*preview*" } | Select-Object -First 1
``````

## Summary

Effective API version management in Bicep templates requires:

1. **Use stable versions** in production environments
2. **Keep versions consistent** across related resources
3. **Document your choices** and update strategy
4. **Automate checking** for outdated versions
5. **Test updates** in non-production environments first

By following these practices, you'll ensure your Bicep templates remain maintainable, secure, and up-to-date with the latest Azure capabilities.
"@ | Out-File -FilePath "docs\04-api-version-management.md" -Encoding UTF8

Write-Host "Creating API version checking script..." -ForegroundColor Yellow

# Create the complete API version checking script
@"
# check-api-versions.ps1
# Script to check for outdated API versions in Bicep templates

param(
    [string]`$Path = "examples",
    [switch]`$ShowLatest,
    [switch]`$Detailed
)

Write-Host "Checking API versions in Bicep templates..." -ForegroundColor Green
Write-Host "Scanning path: `$Path" -ForegroundColor Cyan

# Find all Bicep files
`$bicepFiles = Get-ChildItem -Path `$Path -Filter "*.bicep" -Recurse -File

if (`$bicepFiles.Count -eq 0) {
    Write-Host "No Bicep files found in `$Path" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found `$(`$bicepFiles.Count) Bicep file(s)" -ForegroundColor Cyan

# Extract API versions from all files
`$allVersions = @{}
`$resourceTypes = @{}

foreach (`$file in `$bicepFiles) {
    `$content = Get-Content `$file.FullName -Raw
    `$relativePath = `$file.FullName.Replace((Get-Location).Path, '').TrimStart('\')
    
    # Match resource declarations with API versions
    `$resourcePattern = "resource\s+\w+\s+'([^']+)@([^']+)'"
    `$matches = [regex]::Matches(`$content, `$resourcePattern)
    
    foreach (`$match in `$matches) {
        `$resourceType = `$match.Groups[1].Value
        `$apiVersion = `$match.Groups[2].Value
        
        if (-not `$allVersions.ContainsKey(`$apiVersion)) {
            `$allVersions[`$apiVersion] = @()
        }
        `$allVersions[`$apiVersion] += @{
            File = `$relativePath
            ResourceType = `$resourceType
        }
        
        if (-not `$resourceTypes.ContainsKey(`$resourceType)) {
            `$resourceTypes[`$resourceType] = @()
        }
        `$resourceTypes[`$resourceType] += @{
            File = `$relativePath
            ApiVersion = `$apiVersion
        }
    }
}

# Display results
Write-Host "`nAPI Versions Summary:" -ForegroundColor Yellow
Write-Host "="*50 -ForegroundColor Gray

`$sortedVersions = `$allVersions.Keys | Sort-Object -Descending
foreach (`$version in `$sortedVersions) {
    `$count = `$allVersions[`$version].Count
    `$isPreview = `$version -like "*preview*"
    `$color = if (`$isPreview) { "Yellow" } else { "Green" }
    
    Write-Host "📅 `$version" -ForegroundColor `$color -NoNewline
    Write-Host " (used `$count time(s))" -ForegroundColor Gray
    
    if (`$Detailed) {
        `$allVersions[`$version] | ForEach-Object {
            Write-Host "   └─ `$(`$_.ResourceType) in `$(`$_.File)" -ForegroundColor Gray
        }
    }
}

# Check for outdated versions
Write-Host "`nOutdated Version Analysis:" -ForegroundColor Yellow
Write-Host "="*50 -ForegroundColor Gray

`$twoYearsAgo = (Get-Date).AddYears(-2).ToString("yyyy-MM-dd")
`$oneYearAgo = (Get-Date).AddYears(-1).ToString("yyyy-MM-dd")

`$veryOld = `$allVersions.Keys | Where-Object { `$_ -notlike "*preview*" -and `$_ -lt `$twoYearsAgo }
`$old = `$allVersions.Keys | Where-Object { `$_ -notlike "*preview*" -and `$_ -lt `$oneYearAgo -and `$_ -ge `$twoYearsAgo }
`$preview = `$allVersions.Keys | Where-Object { `$_ -like "*preview*" }

if (`$veryOld) {
    Write-Host "🔴 Very Old (2+ years):" -ForegroundColor Red
    `$veryOld | ForEach-Object {
        Write-Host "   `$_" -ForegroundColor Red
    }
}

if (`$old) {
    Write-Host "🟡 Old (1-2 years):" -ForegroundColor Yellow  
    `$old | ForEach-Object {
        Write-Host "   `$_" -ForegroundColor Yellow
    }
}

if (`$preview) {
    Write-Host "🟠 Preview Versions:" -ForegroundColor DarkYellow
    `$preview | ForEach-Object {
        Write-Host "   `$_" -ForegroundColor DarkYellow
    }
}

# Show latest available versions if requested
if (`$ShowLatest) {
    Write-Host "`nLatest Available API Versions:" -ForegroundColor Yellow
    Write-Host "="*50 -ForegroundColor Gray
    Write-Host "Checking Azure for latest versions..." -ForegroundColor Cyan
    
    `$uniqueResourceTypes = `$resourceTypes.Keys | Sort-Object
    foreach (`$resourceType in `$uniqueResourceTypes) {
        if (`$resourceType -notmatch '/') {
            continue  # Skip malformed resource types
        }
        
        `$namespace = `$resourceType.Split('/')[0]
        `$type = `$resourceType.Split('/')[1]
        
        try {
            `$latest = az provider show --namespace `$namespace --query "resourceTypes[?resourceType=='`$type'].apiVersions[0]" --output tsv 2>`$null
            if (`$latest) {
                `$current = (`$resourceTypes[`$resourceType] | Select-Object -First 1).ApiVersion
                `$status = if (`$current -eq `$latest) { "✅" } else { "⚠️" }
                Write-Host "`$status `$resourceType" -ForegroundColor Cyan
                Write-Host "   Current: `$current" -ForegroundColor Gray
                Write-Host "   Latest:  `$latest" -ForegroundColor Gray
            }
        } catch {
            Write-Host "❓ `$resourceType (unable to check)" -ForegroundColor Gray
        }
    }
}

# Summary and recommendations
Write-Host "`nRecommendations:" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Gray

if (`$veryOld) {
    Write-Host "🔴 Update very old API versions immediately" -ForegroundColor Red
    Write-Host "   These may have security vulnerabilities or missing features" -ForegroundColor Gray
}

if (`$old) {
    Write-Host "🟡 Consider updating old API versions" -ForegroundColor Yellow
    Write-Host "   These work but may lack newer features" -ForegroundColor Gray
}

if (`$preview) {
    Write-Host "🟠 Review preview API versions" -ForegroundColor DarkYellow
    Write-Host "   Use stable versions for production deployments" -ForegroundColor Gray
}

if (-not `$veryOld -and -not `$old -and -not `$preview) {
    Write-Host "✅ All API versions look good!" -ForegroundColor Green
    Write-Host "   No immediate updates required" -ForegroundColor Gray
}

Write-Host "`nUsage Examples:" -ForegroundColor Cyan
Write-Host "  Check with details:     .\scripts\check-api-versions.ps1 -Detailed" -ForegroundColor White
Write-Host "  Check latest versions:  .\scripts\check-api-versions.ps1 -ShowLatest" -ForegroundColor White
Write-Host "  Check specific path:    .\scripts\check-api-versions.ps1 -Path 'examples\05-modules'" -ForegroundColor White
"@ | Out-File -FilePath "scripts\check-api-versions.ps1" -Encoding UTF8

Write-Host "Creating API version example..." -ForegroundColor Yellow

# Create an example that demonstrates API version best practices
`$exampleDir = "examples\api-version-example"
if (-not (Test-Path `$exampleDir)) {
    New-Item -ItemType Directory -Path `$exampleDir -Force | Out-Null
}

@"
// API Version Management Example
// This template demonstrates best practices for API version management

metadata apiVersionInfo = {
  description: 'Template demonstrating API version management best practices'
  lastReviewed: '2025-01-15'
  updateSchedule: 'Quarterly'
  maintainer: 'Infrastructure Team'
}

@description('The application name')
param applicationName string

@description('The environment type')
@allowed(['dev', 'test', 'prod'])
param environmentType string = 'dev'

@description('The location for all resources')
param location string = resourceGroup().location

@description('Use preview API versions (dev/test only)')
param usePreviewAPIs bool = false

// API Version Management Strategy
// Define all API versions in one place for easy maintenance
var apiVersions = (environmentType == 'prod' || !usePreviewAPIs) ? {
  // Stable API versions for production
  storage: '2023-01-01'
  webSites: '2023-01-01'
  appServicePlans: '2023-01-01'
} : {
  // Preview API versions for dev/test (when enabled)
  storage: '2023-05-01-preview'
  webSites: '2023-12-01-preview'  
  appServicePlans: '2023-12-01-preview'
}

// Variables for consistent naming
var namePrefix = '`${applicationName}-`${environmentType}'
var storageAccountName = '`${applicationName}`${environmentType}`${uniqueString(resourceGroup().id)}'

// Storage Account - demonstrates feature availability by API version
resource storageAccount 'Microsoft.Storage/storageAccounts@`${apiVersions.storage}' = {
  name: storageAccountName
  location: location
  sku: {
    name: environmentType == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    // These properties require specific API versions:
    minimumTlsVersion: 'TLS1_2'           // Requires 2019-06-01+
    allowBlobPublicAccess: false           // Requires 2019-04-01+  
    supportsHttpsTrafficOnly: true         // Available since 2016-01-01
    allowCrossTenantReplication: false     // Requires 2021-02-01+
  }
  tags: {
    Environment: environmentType
    ApiVersion: apiVersions.storage
    LastUpdated: utcNow()
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@`${apiVersions.appServicePlans}' = {
  name: '`${namePrefix}-plan'
  location: location
  sku: {
    name: environmentType == 'prod' ? 'P1v3' : 'B1'
    tier: environmentType == 'prod' ? 'PremiumV3' : 'Basic'
  }
  properties: {
    reserved: false  // Windows App Service Plan
  }
  tags: {
    Environment: environmentType
    ApiVersion: apiVersions.appServicePlans
  }
}

// Web App - shows conditional features based on API version
resource webApp 'Microsoft.Web/sites@`${apiVersions.webSites}' = {
  name: '`${namePrefix}-app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      // These settings may require specific API versions
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: [
        {
          name: 'STORAGE_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=`${storageAccount.name};AccountKey=`${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'ENVIRONMENT_TYPE'
          value: environmentType
        }
        {
          name: 'API_VERSION_STRATEGY'
          value: usePreviewAPIs ? 'preview' : 'stable'
        }
      ]
    }
  }
  tags: {
    Environment: environmentType
    ApiVersion: apiVersions.webSites
  }
}

// Outputs that show API version information
output deploymentInfo object = {
  environmentType: environmentType
  usePreviewAPIs: usePreviewAPIs
  apiVersionsUsed: apiVersions
  resourcesDeployed: {
    storageAccount: {
      name: storageAccount.name
      apiVersion: apiVersions.storage
    }
    appServicePlan: {
      name: appServicePlan.name  
      apiVersion: apiVersions.appServicePlans
    }
    webApp: {
      name: webApp.name
      apiVersion: apiVersions.webSites
      url: 'https://`${webApp.properties.defaultHostName}'
    }
  }
}

output apiVersionAudit object = {
  templateLastUpdated: '2025-01-15'
  nextReviewDate: '2025-04-15'
  apiVersionStrategy: usePreviewAPIs ? 'Using preview versions for testing' : 'Using stable versions for production'
  upgradeRecommendations: [
    'Review API versions quarterly'
    'Test new API versions in dev environment first'
    'Monitor Azure announcements for deprecations'
    'Use automation to check for outdated versions'
  ]
}
"@ | Out-File -FilePath "`$exampleDir\api-version-demo.bicep" -Encoding UTF8

@"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "applicationName": {
      "value": "apitest"
    },
    "environmentType": {
      "value": "dev"
    },
    "location": {
      "value": "East US"
    },
    "usePreviewAPIs": {
      "value": false
    }
  }
}
"@ | Out-File -FilePath "`$exampleDir\api-version-demo.parameters.json" -Encoding UTF8

@"
# API Version Management Example

This example demonstrates best practices for managing API versions in Bicep templates.

## What You'll Learn

- **Centralized API version management** using variables
- **Environment-specific API version strategies**
- **Feature availability** based on API versions
- **API version documentation** and tracking
- **Automated API version checking**

## Files

- ``api-version-demo.bicep`` - Template demonstrating API version best practices
- ``api-version-demo.parameters.json`` - Parameter file for deployment

## How to Deploy

### Development with Stable APIs
``````powershell
az deployment group create \
  --resource-group rg-api-demo \
  --template-file api-version-demo.bicep \
  --parameters @api-version-demo.parameters.json
``````

### Testing with Preview APIs
``````powershell
az deployment group create \
  --resource-group rg-api-demo \
  --template-file api-version-demo.bicep \
  --parameters @api-version-demo.parameters.json \
  --parameters usePreviewAPIs=true
``````

## API Version Checking

Use the included script to check API versions:

``````powershell
# Check all templates
.\scripts\check-api-versions.ps1

# Check with details
.\scripts\check-api-versions.ps1 -Detailed

# Check for latest available versions
.\scripts\check-api-versions.ps1 -ShowLatest
``````

## Best Practices Demonstrated

1. ✅ **Centralized management** - All API versions in one place
2. ✅ **Documentation** - Metadata explains API version strategy
3. ✅ **Environment awareness** - Different strategies for different environments
4. ✅ **Feature tracking** - Comments explain API version requirements
5. ✅ **Automation ready** - Structure supports automated checking

## Next Steps

- Review the [API Version Management Guide](../../docs/04-api-version-management.md)
- Set up automated API version checking in your CI/CD pipeline
- Establish a regular review schedule for API versions
"@ | Out-File -FilePath "`$exampleDir\README.md" -Encoding UTF8

Write-Host "Updating main README..." -ForegroundColor Yellow

# Update the main README to include API version management
`$readmePath = "README.md"
if (Test-Path `$readmePath) {
    `$readmeContent = Get-Content `$readmePath -Raw
    
    # Add API version management to the tutorial structure
    if (`$readmeContent -match "### Part 2: Intermediate") {
        `$newSection = @"
### Part 2: Intermediate
- [Advanced Topics](docs/03-advanced-topics.md) - Modules, patterns, best practices

### Part 3: Production Readiness
- [API Version Management](docs/04-api-version-management.md) - Managing and updating API versions
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
"@
        
        `$readmeContent = `$readmeContent -replace "### Part 2: Intermediate.*?(?=### Part 3:|## 🔧)", `$newSection
        
        # If no Part 3 exists, replace the troubleshooting reference
        if (`$readmeContent -notmatch "### Part 3:") {
            `$readmeContent = `$readmeContent -replace "### Part 3: Reference.*?- \[Troubleshooting\].*?\r?\n", ""
            `$readmeContent = `$readmeContent -replace "(\r?\n)(## 🔧)", "`$1`$newSection`$1`$1`$2"
        }
    }
    
    `$readmeContent | Out-File -FilePath `$readmePath -Encoding UTF8
}

Write-Host ""
Write-Host "API Version Management documentation added successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Created files:" -ForegroundColor Cyan
Write-Host "  📄 docs\04-api-version-management.md - Comprehensive API version guide" -ForegroundColor White
Write-Host "  📄 scripts\check-api-versions.ps1 - Automated API version checking" -ForegroundColor White
Write-Host "  📄 examples\api-version-example\ - Complete working example" -ForegroundColor White
Write-Host "  📄 Updated README.md - Added to tutorial structure" -ForegroundColor White
Write-Host ""
Write-Host "Key features:" -ForegroundColor Yellow
Write-Host "  ✅ Complete API version management guide" -ForegroundColor Green
Write-Host "  ✅ Automated checking script" -ForegroundColor Green
Write-Host "  ✅ Working example with best practices" -ForegroundColor Green
Write-Host "  ✅ Production-ready patterns" -ForegroundColor Green
Write-Host ""
Write-Host "Test the API version checker:" -ForegroundColor Cyan
Write-Host "  .\scripts\check-api-versions.ps1 -Detailed" -ForegroundColor White