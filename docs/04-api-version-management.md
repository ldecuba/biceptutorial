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

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
//                      Resource Type ──────────┘        └── API Version
```

API versions follow the format: `YYYY-MM-DD` or `YYYY-MM-DD-preview`

## API Version Lifecycle

### 1. Preview Versions
- **Format**: `2023-01-01-preview`
- **Purpose**: Early access to new features
- **Stability**: May change or be removed
- **Use Case**: Testing and development only

### 2. Stable Versions
- **Format**: `2023-01-01`
- **Purpose**: Production-ready functionality
- **Stability**: Guaranteed backward compatibility
- **Use Case**: Production deployments

### 3. Deprecated Versions
- **Status**: Still functional but marked for removal
- **Timeline**: Usually supported for 2-3 years after deprecation
- **Migration**: Should be updated to newer versions

## Best Practices for API Version Management

### 1. Use Stable Versions in Production

```bicep
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
```

### 2. Use Variables for API Version Management

```bicep
// Define API versions as variables for easier maintenance
var apiVersions = {
  storage: '2023-01-01'
  webSites: '2023-01-01'
  appServicePlans: '2023-01-01'
  keyVault: '2023-02-01'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@${apiVersions.storage}' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
```

### 3. Document API Version Choices

```bicep
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
```

## Finding and Updating API Versions

### Using Azure CLI

```bash
# List all API versions for a resource type
az provider show --namespace Microsoft.Storage \
  --query "resourceTypes[?resourceType=='storageAccounts'].apiVersions"

# Get the latest API version
az provider show --namespace Microsoft.Storage \
  --query "resourceTypes[?resourceType=='storageAccounts'].apiVersions[0]" \
  --output tsv
```

### Using PowerShell

```powershell
# Get API versions for a resource type
(Get-AzResourceProvider -ProviderNamespace Microsoft.Storage).ResourceTypes | 
  Where-Object ResourceTypeName -eq storageAccounts | 
  Select-Object -ExpandProperty ApiVersions

# Get latest stable API version (non-preview)
$apiVersions = (Get-AzResourceProvider -ProviderNamespace Microsoft.Storage).ResourceTypes | 
  Where-Object ResourceTypeName -eq storageAccounts | 
  Select-Object -ExpandProperty ApiVersions

$latestStable = $apiVersions | Where-Object { $_ -notlike "*preview*" } | Select-Object -First 1
```

## Summary

Effective API version management in Bicep templates requires:

1. **Use stable versions** in production environments
2. **Keep versions consistent** across related resources
3. **Document your choices** and update strategy
4. **Automate checking** for outdated versions
5. **Test updates** in non-production environments first

By following these practices, you'll ensure your Bicep templates remain maintainable, secure, and up-to-date with the latest Azure capabilities.

