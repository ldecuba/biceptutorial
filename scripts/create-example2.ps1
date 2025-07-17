# create-example-2.ps1
# PowerShell script to create complete Example 2: Parameters and Variables

Write-Host "Creating complete Example 2: Parameters and Variables..." -ForegroundColor Green

# Ensure directory exists
if (-not (Test-Path "examples\02-parameters-variables")) {
    New-Item -ItemType Directory -Path "examples\02-parameters-variables" -Force | Out-Null
}

Write-Host "Creating Bicep template with parameters and variables..." -ForegroundColor Yellow

# Create the main Bicep template (if not exists or update it)
@"
// Storage account with parameters and variables

@description('The name of the storage account (must be globally unique)')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The location for the storage account')
param location string = resourceGroup().location

@description('The SKU for the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

@description('The environment type')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string = 'dev'

@description('Enable blob public access')
param allowBlobPublicAccess bool = false

// Variables for computed values
var storageAccountTier = environmentType == 'prod' ? 'Standard' : 'Standard'
var accessTier = environmentType == 'prod' ? 'Hot' : 'Cool'
var tags = {
  Environment: environmentType
  CreatedBy: 'Bicep Tutorial'
  Purpose: 'Learning Parameters and Variables'
}

// Additional variables demonstrating different concepts
var namingPrefix = 'bicep-tutorial'
var uniqueSuffix = uniqueString(resourceGroup().id)
var computedStorageName = '`${namingPrefix}`${environmentType}`${uniqueSuffix}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: allowBlobPublicAccess
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
  tags: tags
}

// Create blob service with computed name
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

// Create a container demonstrating conditional creation
resource sampleContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = if (environmentType != 'prod') {
  parent: blobService
  name: 'sample-data'
  properties: {
    publicAccess: 'None'
  }
}

// Outputs demonstrating parameter and variable usage
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output primaryEndpoint string = storageAccount.properties.primaryEndpoints.blob
output environmentUsed string = environmentType
output tagsApplied object = tags
output computedName string = computedStorageName
output containerCreated bool = environmentType != 'prod'
"@ | Out-File -FilePath "examples\02-parameters-variables\storage-with-params.bicep" -Encoding UTF8

Write-Host "Creating parameter file..." -ForegroundColor Yellow

# Create/update the parameter file
@"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountName": {
      "value": "bicepstoragedev001"
    },
    "location": {
      "value": "East US"
    },
    "storageAccountType": {
      "value": "Standard_LRS"
    },
    "environmentType": {
      "value": "dev"
    },
    "allowBlobPublicAccess": {
      "value": false
    }
  }
}
"@ | Out-File -FilePath "examples\02-parameters-variables\storage.parameters.json" -Encoding UTF8

Write-Host "Creating production parameter file..." -ForegroundColor Yellow

# Create a production parameter file to show environment differences
@"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountName": {
      "value": "bicepmainprod001"
    },
    "location": {
      "value": "East US"
    },
    "storageAccountType": {
      "value": "Standard_GRS"
    },
    "environmentType": {
      "value": "prod"
    },
    "allowBlobPublicAccess": {
      "value": false
    }
  }
}
"@ | Out-File -FilePath "examples\02-parameters-variables\storage.prod.parameters.json" -Encoding UTF8

Write-Host "Creating PowerShell deployment script..." -ForegroundColor Yellow

# Create PowerShell deployment script
@"
# deploy.ps1 - Example 2 PowerShell deployment script

param(
    [string]`$ResourceGroup = "rg-bicep-tutorial",
    [string]`$Location = "East US",
    [string]`$Environment = "dev"
)

`$DeploymentName = "params-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "Deploying Bicep template with parameters and variables..." -ForegroundColor Green
Write-Host "Resource Group: `$ResourceGroup" -ForegroundColor Cyan
Write-Host "Location: `$Location" -ForegroundColor Cyan
Write-Host "Environment: `$Environment" -ForegroundColor Cyan
Write-Host "Deployment Name: `$DeploymentName" -ForegroundColor Cyan

# Determine parameter file based on environment
`$parameterFile = if (`$Environment -eq "prod") { 
    "storage.prod.parameters.json" 
} else { 
    "storage.parameters.json" 
}

Write-Host "Using parameter file: `$parameterFile" -ForegroundColor Yellow

# Create resource group if it doesn't exist
Write-Host "`nCreating resource group..." -ForegroundColor Yellow
az group create --name `$ResourceGroup --location "`$Location"

if (`$LASTEXITCODE -ne 0) {
    Write-Host "Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Deploy template with parameters
Write-Host "Deploying template..." -ForegroundColor Yellow
az deployment group create ``
  --resource-group `$ResourceGroup ``
  --template-file storage-with-params.bicep ``
  --parameters "@`$parameterFile" ``
  --name `$DeploymentName

if (`$LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed" -ForegroundColor Red
    exit 1
}

# Show deployment outputs
Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
Write-Host "`nDeployment outputs:" -ForegroundColor Cyan
az deployment group show ``
  --resource-group `$ResourceGroup ``
  --name `$DeploymentName ``
  --query "properties.outputs" ``
  --output json

Write-Host "`nCreated resources:" -ForegroundColor Green
az resource list --resource-group `$ResourceGroup --output table

Write-Host "`nExample usage for different environments:" -ForegroundColor Yellow
Write-Host "Development: .\deploy.ps1 -Environment dev" -ForegroundColor White
Write-Host "Production:  .\deploy.ps1 -Environment prod -ResourceGroup 'rg-bicep-prod'" -ForegroundColor White
"@ | Out-File -FilePath "examples\02-parameters-variables\deploy.ps1" -Encoding UTF8

Write-Host "Creating Bash deployment script..." -ForegroundColor Yellow

# Create Bash deployment script for compatibility
@"
#!/bin/bash

# deploy.sh - Example 2 Bash deployment script

# Set default values
RESOURCE_GROUP="rg-bicep-tutorial"
LOCATION="East US"
ENVIRONMENT="dev"

# Parse command line arguments
while [[ `$# -gt 0 ]]; do
  case `$1 in
    -g|--resource-group)
      RESOURCE_GROUP="`$2"
      shift 2
      ;;
    -l|--location)
      LOCATION="`$2"
      shift 2
      ;;
    -e|--environment)
      ENVIRONMENT="`$2"
      shift 2
      ;;
    *)
      echo "Unknown option `$1"
      exit 1
      ;;
  esac
done

DEPLOYMENT_NAME="params-deployment-`$(date +%Y%m%d-%H%M%S)"

echo "Deploying Bicep template with parameters and variables..."
echo "Resource Group: `$RESOURCE_GROUP"
echo "Location: `$LOCATION"
echo "Environment: `$ENVIRONMENT"
echo "Deployment Name: `$DEPLOYMENT_NAME"

# Determine parameter file based on environment
if [ "`$ENVIRONMENT" = "prod" ]; then
    PARAMETER_FILE="storage.prod.parameters.json"
else
    PARAMETER_FILE="storage.parameters.json"
fi

echo "Using parameter file: `$PARAMETER_FILE"

# Create resource group if it doesn't exist
echo ""
echo "Creating resource group..."
az group create --name `$RESOURCE_GROUP --location "`$LOCATION"

# Deploy template with parameters
echo "Deploying template..."
az deployment group create \
  --resource-group `$RESOURCE_GROUP \
  --template-file storage-with-params.bicep \
  --parameters "@`$PARAMETER_FILE" \
  --name `$DEPLOYMENT_NAME

# Show deployment outputs
echo ""
echo "Deployment outputs:"
az deployment group show \
  --resource-group `$RESOURCE_GROUP \
  --name `$DEPLOYMENT_NAME \
  --query "properties.outputs" \
  --output json

echo ""
echo "Created resources:"
az resource list --resource-group `$RESOURCE_GROUP --output table

echo ""
echo "Example usage for different environments:"
echo "Development: ./deploy.sh -e dev"
echo "Production:  ./deploy.sh -e prod -g rg-bicep-prod"
"@ | Out-File -FilePath "examples\02-parameters-variables\deploy.sh" -Encoding UTF8

Write-Host "Creating comprehensive README..." -ForegroundColor Yellow

# Create comprehensive README
@"
# Example 2: Parameters and Variables

This example demonstrates how to use parameters and variables to make your Bicep templates reusable and flexible.

## What You'll Learn

- **Parameters**: How to accept inputs to make templates reusable
- **Parameter Decorators**: Adding validation and documentation
- **Variables**: Computing values and reducing repetition  
- **Parameter Files**: Providing values without modifying templates
- **Environment-Specific Deployments**: Using different parameter files for dev/prod

## Files

- ``storage-with-params.bicep`` - Main template with parameters and variables
- ``storage.parameters.json`` - Development parameter file
- ``storage.prod.parameters.json`` - Production parameter file
- ``deploy.ps1`` - PowerShell deployment script with environment support
- ``deploy.sh`` - Bash deployment script with environment support

## Key Concepts Demonstrated

### Parameters
- **String parameters** with validation (``@minLength``, ``@maxLength``)
- **Allowed values** for controlled inputs (``@allowed``)
- **Boolean parameters** for feature flags
- **Default values** for optional parameters
- **Parameter descriptions** for documentation

### Variables
- **Simple variables** for repeated values
- **Computed variables** using string interpolation
- **Conditional variables** based on parameters
- **Complex objects** for structured data

### Advanced Features
- **Environment-specific logic** (different configs for dev/prod)
- **Conditional resource creation** (container only in non-prod)
- **Resource tagging** using variables
- **Multiple parameter files** for different environments

## How to Deploy

### PowerShell

Development environment:
``````powershell
.\deploy.ps1
``````

Production environment:
``````powershell
.\deploy.ps1 -Environment prod -ResourceGroup "rg-bicep-prod"
``````

Custom configuration:
``````powershell
.\deploy.ps1 -ResourceGroup "my-rg" -Location "West US" -Environment "test"
``````

### Bash/Git Bash

Development environment:
``````bash
./deploy.sh
``````

Production environment:
``````bash
./deploy.sh -e prod -g rg-bicep-prod
``````

Custom configuration:
``````bash
./deploy.sh -g my-rg -l "West US" -e test
``````

## What Gets Created

### Development Environment
- Storage account with "Cool" access tier
- Sample container for testing
- Development-specific tags

### Production Environment  
- Storage account with "Hot" access tier and geo-redundancy
- No sample container (production-ready)
- Production-specific tags

## Parameter File Comparison

| Parameter | Development | Production |
|-----------|-------------|------------|
| Storage SKU | Standard_LRS | Standard_GRS |
| Access Tier | Cool | Hot |
| Sample Container | Created | Not Created |
| Naming | bicepstoragedev001 | bicepmainprod001 |

## Outputs Provided

The template returns several outputs to demonstrate different concepts:
- ``storageAccountId`` - Resource ID
- ``storageAccountName`` - Actual name used
- ``primaryEndpoint`` - Blob storage endpoint
- ``environmentUsed`` - Which environment was deployed
- ``tagsApplied`` - Tags that were applied
- ``computedName`` - Shows computed naming logic
- ``containerCreated`` - Whether sample container was created

## Best Practices Demonstrated

1. **Use descriptive parameter names** and add descriptions
2. **Validate parameter inputs** with decorators
3. **Provide sensible defaults** where appropriate
4. **Use variables** to avoid repetition and improve readability
5. **Implement environment-specific logic** for real-world scenarios
6. **Tag resources consistently** using variables
7. **Use parameter files** to avoid modifying templates
8. **Document outputs** to help consumers understand what's returned

## Common Parameter Patterns

```bicep
// String with validation
@description('Application name for resource naming')
@minLength(2)
@maxLength(10)
param applicationName string

// Controlled choices
@allowed(['dev', 'test', 'prod'])
param environmentType string = 'dev'

// Feature flags
@description('Enable advanced monitoring features')
param enableMonitoring bool = false

// Location with default
param location string = resourceGroup().location

// Secure values
@secure()
param adminPassword string
```

## Variable Patterns

```bicep
// Simple computed values
var uniqueId = uniqueString(resourceGroup().id)
var resourceName = '`${applicationName}-`${environmentType}-storage'

// Environment-specific configurations
var environmentConfig = {
  dev: { sku: 'Standard_LRS', tier: 'Cool' }
  prod: { sku: 'Standard_GRS', tier: 'Hot' }
}

// Complex objects
var commonTags = {
  Environment: environmentType
  Project: 'BicepTutorial'
  ManagedBy: 'Infrastructure Team'
}
```

## Next Steps

Go to [Example 3](../03-dependencies/) to learn about resource dependencies.

## Troubleshooting

### Common Issues

1. **Storage name already exists**: The storage account name must be globally unique. Try changing the name in the parameter file.

2. **Invalid parameter value**: Check that your parameter values match the allowed values and constraints.

3. **Resource group not found**: Make sure the resource group exists or let the script create it.

### Validation Commands

```bash
# Validate template syntax
az bicep build --file storage-with-params.bicep

# Validate deployment (what-if)
az deployment group what-if \
  --resource-group rg-bicep-tutorial \
  --template-file storage-with-params.bicep \
  --parameters @storage.parameters.json
```
"@ | Out-File -FilePath "examples\02-parameters-variables\README.md" -Encoding UTF8

Write-Host ""
Write-Host "Complete Example 2 created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Created files:" -ForegroundColor Cyan
Write-Host "  📄 storage-with-params.bicep - Main template with comprehensive parameters/variables" -ForegroundColor White
Write-Host "  📄 storage.parameters.json - Development parameter file" -ForegroundColor White  
Write-Host "  📄 storage.prod.parameters.json - Production parameter file" -ForegroundColor White
Write-Host "  📄 deploy.ps1 - PowerShell deployment script with environment support" -ForegroundColor White
Write-Host "  📄 deploy.sh - Bash deployment script with environment support" -ForegroundColor White
Write-Host "  📄 README.md - Comprehensive documentation" -ForegroundColor White
Write-Host ""
Write-Host "Example 2 is now complete and demonstrates:" -ForegroundColor Yellow
Write-Host "  ✅ Parameter validation and documentation" -ForegroundColor Green
Write-Host "  ✅ Variable computation and reuse" -ForegroundColor Green
Write-Host "  ✅ Environment-specific configurations" -ForegroundColor Green
Write-Host "  ✅ Multiple parameter files" -ForegroundColor Green
Write-Host "  ✅ Conditional resource creation" -ForegroundColor Green
Write-Host "  ✅ Both PowerShell and Bash deployment scripts" -ForegroundColor Green
Write-Host ""
Write-Host "Test it with:" -ForegroundColor Cyan
Write-Host "  cd examples\02-parameters-variables" -ForegroundColor White
Write-Host "  .\deploy.ps1" -ForegroundColor White