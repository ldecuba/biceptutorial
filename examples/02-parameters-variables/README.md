# Example 2: Parameters and Variables

This example demonstrates how to use parameters and variables to make your Bicep templates reusable and flexible.

## What You'll Learn

- **Parameters**: How to accept inputs to make templates reusable
- **Parameter Decorators**: Adding validation and documentation
- **Variables**: Computing values and reducing repetition  
- **Parameter Files**: Providing values without modifying templates
- **Environment-Specific Deployments**: Using different parameter files for dev/prod

## Files

- `storage-with-params.bicep` - Main template with parameters and variables
- `storage.parameters.json` - Development parameter file
- `storage.prod.parameters.json` - Production parameter file
- `deploy.ps1` - PowerShell deployment script with environment support
- `deploy.sh` - Bash deployment script with environment support

## Key Concepts Demonstrated

### Parameters
- **String parameters** with validation (`@minLength`, `@maxLength`)
- **Allowed values** for controlled inputs (`@allowed`)
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
```powershell
.\deploy.ps1
```

Production environment:
```powershell
.\deploy.ps1 -Environment prod -ResourceGroup "rg-bicep-prod"
```

Custom configuration:
```powershell
.\deploy.ps1 -ResourceGroup "my-rg" -Location "West US" -Environment "test"
```

### Bash/Git Bash

Development environment:
```bash
./deploy.sh
```

Production environment:
```bash
./deploy.sh -e prod -g rg-bicep-prod
```

Custom configuration:
```bash
./deploy.sh -g my-rg -l "West US" -e test
```

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
- `storageAccountId` - Resource ID
- `storageAccountName` - Actual name used
- `primaryEndpoint` - Blob storage endpoint
- `environmentUsed` - Which environment was deployed
- `tagsApplied` - Tags that were applied
- `computedName` - Shows computed naming logic
- `containerCreated` - Whether sample container was created

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

`icep
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
`

## Variable Patterns

`icep
// Simple computed values
var uniqueId = uniqueString(resourceGroup().id)
var resourceName = '${applicationName}-${environmentType}-storage'

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
`

## Next Steps

Go to [Example 3](../03-dependencies/) to learn about resource dependencies.

## Troubleshooting

### Common Issues

1. **Storage name already exists**: The storage account name must be globally unique. Try changing the name in the parameter file.

2. **Invalid parameter value**: Check that your parameter values match the allowed values and constraints.

3. **Resource group not found**: Make sure the resource group exists or let the script create it.

### Validation Commands

`ash
# Validate template syntax
az bicep build --file storage-with-params.bicep

# Validate deployment (what-if)
az deployment group what-if \
  --resource-group rg-bicep-tutorial \
  --template-file storage-with-params.bicep \
  --parameters @storage.parameters.json
`

