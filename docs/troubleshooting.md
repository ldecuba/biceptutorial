# Troubleshooting Guide

This guide covers common issues you might encounter when working with Bicep templates and their solutions.

## Common Deployment Errors

### 1. Resource Name Conflicts

**Error**: `The storage account name 'mystorageaccount' is already taken.`

**Cause**: Storage account names must be globally unique across all of Azure.

**Solution**:
`icep
// Problem: Hard-coded name
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'  // This will fail if name is taken
  location: location
  // ...
}

// Solution: Use unique naming
var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  // ...
}
`

### 2. Invalid Resource Names

**Error**: `The resource name 'my-storage-account' is invalid.`

**Cause**: Each Azure resource type has specific naming requirements.

**Common Naming Rules**:
- Storage accounts: 3-24 characters, lowercase letters and numbers only
- Web apps: 2-60 characters, alphanumeric and hyphens
- Key vaults: 3-24 characters, alphanumeric and hyphens

**Solution**:
`icep
// Problem: Invalid characters
var storageAccountName = 'my-storage-account'  // Contains hyphens

// Solution: Follow naming rules
var storageAccountName = replace('my-storage-account', '-', '')  // Remove hyphens
var webAppName = 'my-web-app'  // Valid for web apps
`

### 3. Missing Required Properties

**Error**: `The template is missing required property 'sku'.`

**Solution**:
`icep
// Problem: Missing required properties
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  // Missing sku and kind properties
}

// Solution: Include all required properties
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
`

## Debugging Strategies

### 1. Use What-If Deployments

Preview changes before deploying:
`ash
az deployment group what-if \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @parameters.json
`

### 2. Validate Templates

Check template syntax and logic:
`ash
# Validate syntax
az bicep build --file main.bicep

# Validate deployment
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @parameters.json
`

### 3. Use Deployment Outputs for Debugging

Add debug outputs to your templates:
`icep
// Debug outputs
output debugInfo object = {
  resourceGroupName: resourceGroup().name
  deploymentName: deployment().name
  timestamp: utcNow()
  computedValues: {
    storageAccountName: storageAccountName
    namePrefix: namePrefix
  }
}
`

## Troubleshooting Checklist

When encountering issues, work through this checklist:

### 1. Template Validation
- [ ] Template syntax is correct (`az bicep build`)
- [ ] All required parameters are provided
- [ ] Parameter values meet validation requirements
- [ ] All resource dependencies are satisfied

### 2. Resource Configuration
- [ ] Resource names follow Azure naming conventions
- [ ] API versions are current and supported
- [ ] Required properties are included
- [ ] Property values are valid for the resource type

### 3. Permissions and Authentication
- [ ] You have sufficient permissions for the subscription/resource group
- [ ] Required resource providers are registered
- [ ] Service principal (if used) has correct permissions

### 4. Environment Setup
- [ ] Target resource group exists
- [ ] Target location supports all resource types
- [ ] Subscription quotas are sufficient

### 5. Testing Strategy
- [ ] Use `what-if` to preview changes
- [ ] Deploy to dev/test environment first
- [ ] Test with minimal template before adding complexity

Remember: Most Bicep issues are due to syntax errors, missing dependencies, or permission problems. Working through the checklist systematically will help you identify and resolve issues quickly.

