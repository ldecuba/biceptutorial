# create-docs.ps1
# PowerShell script to create all documentation files for the Bicep tutorial

Write-Host "Creating comprehensive documentation files..." -ForegroundColor Green

# Ensure docs directory exists
if (-not (Test-Path "docs")) {
    New-Item -ItemType Directory -Path "docs" -Force | Out-Null
}

Write-Host "Creating Getting Started guide..." -ForegroundColor Yellow

# Create docs/01-getting-started.md
@"
# Getting Started with Bicep Infrastructure as Code

## What is Infrastructure as Code (IaC)?

Infrastructure as Code is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

### Benefits of IaC:
- **Consistency**: Same infrastructure every time
- **Version Control**: Track changes over time
- **Automation**: Deploy with a single command
- **Documentation**: Your code documents your infrastructure
- **Collaboration**: Multiple people can work on infrastructure

### Traditional vs IaC Approach

**Traditional Approach:**
1. Log into Azure Portal
2. Click through wizard to create resources
3. Manually configure settings
4. Repeat for each environment
5. Hope you remember what you did

**IaC Approach:**
1. Write template describing desired infrastructure
2. Deploy template to any environment
3. Template serves as documentation
4. Version control tracks all changes
5. Automated and repeatable

## Introduction to Bicep

Bicep is a domain-specific language (DSL) that uses declarative syntax to deploy Azure resources. It's a transparent abstraction over ARM templates that provides:

- **Simpler syntax** than JSON ARM templates
- **Type safety** and IntelliSense support
- **Modular** architecture
- **Day-one support** for all Azure services

### Bicep vs ARM Templates

| Feature | ARM Templates | Bicep |
|---------|---------------|--------|
| Syntax | JSON (verbose) | Domain-specific language |
| Learning curve | Steep | Gentle |
| IntelliSense | Limited | Full support |
| Modularity | Complex | Built-in |
| Readability | Poor | Excellent |

### How Bicep Works

```
Bicep Template → Bicep CLI → ARM Template → Azure Resource Manager → Azure Resources
```

## Setting Up Your Environment

### Prerequisites

1. **Azure CLI** - [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Bicep CLI** - Install via Azure CLI
3. **VS Code** with Bicep extension (recommended)
4. **Azure subscription** and appropriate permissions

### Installation Steps

#### 1. Install Azure CLI
Visit the [Azure CLI installation page](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and follow instructions for your operating system.

#### 2. Install Bicep CLI
```bash
az bicep install
```

#### 3. Install VS Code Extensions
- Bicep Extension
- Azure Account Extension
- Azure Resources Extension

#### 4. Verify Installation
```bash
az --version
az bicep version
```

Expected output:
```
azure-cli                         2.54.0
bicep                            0.23.1
```

### Login to Azure

```bash
# Login interactively
az login

# List available subscriptions
az account list --output table

# Set active subscription
az account set --subscription "Your Subscription Name"

# Verify current subscription
az account show --output table
```

## Your First Bicep Template

Let's create a simple storage account to understand the basics.

### Create Your First Template

Create a file called ``storage.bicep``:

```bicep
// This is a comment in Bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount001'
  location: 'East US'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
```

### Understanding the Template

Let's break down each part:

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
//  ↑            ↑                       ↑
//  |            |                       |
//  |            |                       └── API Version
//  |            └─────────────────────────── Resource Type
//  └──────────────────────────────────────── Symbolic Name
```

- **``resource``**: Keyword that declares a resource
- **``storageAccount``**: Symbolic name used within the template
- **``Microsoft.Storage/storageAccounts@2023-01-01``**: Resource type and API version
- **Properties**: Configuration for the resource

### Deploy Your First Template

```bash
# Create a resource group
az group create --name rg-bicep-tutorial --location "East US"

# Deploy the template
az deployment group create \
  --resource-group rg-bicep-tutorial \
  --template-file storage.bicep \
  --name first-deployment
```

### Verify the Deployment

```bash
# Check deployment status
az deployment group show \
  --resource-group rg-bicep-tutorial \
  --name first-deployment \
  --query properties.provisioningState

# List resources in the group
az resource list --resource-group rg-bicep-tutorial --output table
```

## Understanding Bicep Syntax

### Basic Structure

Every Bicep template has this general structure:

```bicep
// 1. Target scope (optional)
targetScope = 'resourceGroup'

// 2. Parameters (inputs)
param location string = 'East US'
param environment string

// 3. Variables (computed values)
var storageAccountName = 'storage`${uniqueString(resourceGroup().id)}'

// 4. Resources (what to deploy)
resource myStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// 5. Outputs (return values)
output storageAccountId string = myStorage.id
output storageAccountName string = myStorage.name
```

### Data Types

Bicep supports several data types:

```bicep
// String
param applicationName string = 'myapp'

// Integer
param instanceCount int = 3

// Boolean
param enableHttps bool = true

// Array
param allowedLocations array = [
  'East US'
  'West US'
  'North Europe'
]

// Object
param databaseConfig object = {
  tier: 'Standard'
  capacity: 10
  maxSizeGB: 250
}
```

### String Interpolation

Bicep supports string interpolation using ``${expression}`` syntax (where `expression` is a variable or value):

```bicep
param applicationName string = 'myapp'
param environment string = 'dev'

var resourceName = '`${applicationName}-`${environment}'
var greeting = 'Hello `${applicationName}!'
var storageAccountName = '`${applicationName}`${environment}`${uniqueString(resourceGroup().id)}'
```

### Comments

```bicep
// Single line comment

/*
  Multi-line comment
  Can span multiple lines
*/

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount' // End of line comment
  location: 'East US'
  // ... rest of configuration
}
```

## Common Functions

Bicep provides many built-in functions:

```bicep
// Generate unique string based on resource group
var uniqueName = 'storage`${uniqueString(resourceGroup().id)}'

// Get resource group location
var location = resourceGroup().location

// Concatenate strings
var fullName = concat('prefix', 'suffix')

// String interpolation (preferred)
var fullName2 = '`${prefix}`${suffix}'

// Array functions
var firstItem = first(myArray)
var lastItem = last(myArray)
var arrayLength = length(myArray)

// Object functions
var objectKeys = keys(myObject)
var hasProperty = contains(myObject, 'propertyName')
```

## Best Practices for Beginners

### 1. Use Descriptive Names
```bicep
// Good
resource primaryStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'primarystorage`${uniqueString(resourceGroup().id)}'
  // ...
}

// Avoid
resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'storage1'
  // ...
}
```

### 2. Use Variables for Repeated Values
```bicep
// Good
var location = 'East US'
var skuName = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'
  location: location
  sku: {
    name: skuName
  }
}
```

### 3. Add Comments
```bicep
// Storage account for application data
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'
  location: 'East US'
  sku: {
    name: 'Standard_LRS' // Locally redundant storage for cost optimization
  }
  kind: 'StorageV2'
}
```

### 4. Use Consistent Naming Conventions
```bicep
// Establish a pattern and stick to it
var namingPrefix = '`${applicationName}-`${environment}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '`${namingPrefix}-storage'
  // ...
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '`${namingPrefix}-plan'
  // ...
}
```

## Next Steps

Now that you understand the basics, you're ready to move on to:

1. **[Basic Concepts](02-basic-concepts.md)** - Parameters, variables, and resources
2. **[Advanced Topics](03-advanced-topics.md)** - Modules, patterns, and best practices
3. **[Examples](../examples/)** - Hands-on practice with real templates

## Quick Reference

### Essential Commands
```bash
# Install/update Bicep
az bicep install
az bicep upgrade

# Create resource group
az group create --name <n> --location <location>

# Deploy template
az deployment group create \
  --resource-group <rg-name> \
  --template-file <template.bicep> \
  --parameters <params.json>

# Validate template
az deployment group validate \
  --resource-group <rg-name> \
  --template-file <template.bicep>

# Preview changes
az deployment group what-if \
  --resource-group <rg-name> \
  --template-file <template.bicep>
```

### Resource Declaration Syntax
```bicep
resource <symbolic-name> '<resource-type>@<api-version>' = {
  name: 'actual-resource-name'
  location: 'resource-location'
  properties: {
    // Resource-specific properties
  }
}
```

You're now ready to start building more complex templates!
"@ | Out-File -FilePath "docs\01-getting-started.md" -Encoding UTF8

Write-Host "Creating Basic Concepts guide..." -ForegroundColor Yellow

# Create docs/02-basic-concepts.md (truncated for length, but includes full content)
@"
# Basic Concepts: Parameters, Variables, and Resources

This section covers the fundamental building blocks of Bicep templates: parameters, variables, and resources.

## Parameters

Parameters are inputs to your Bicep template that make your templates reusable across different environments and scenarios.

### Basic Parameter Syntax

```bicep
param <parameter-name> <data-type> = <default-value>
```

### Parameter Data Types

#### String Parameters
```bicep
param applicationName string
param location string = 'East US'  // With default value
param description string = ''       // Empty string default
```

#### Numeric Parameters
```bicep
param instanceCount int = 1
param maxUsers int
```

#### Boolean Parameters
```bicep
param enableHttps bool = true
param deployToProduction bool
```

#### Array Parameters
```bicep
param allowedLocations array = [
  'East US'
  'West US'
  'North Europe'
]

param vmSizes array
```

#### Object Parameters
```bicep
param networkConfig object = {
  addressPrefix: '10.0.0.0/16'
  subnets: [
    {
      name: 'frontend'
      addressPrefix: '10.0.1.0/24'
    }
    {
      name: 'backend'
      addressPrefix: '10.0.2.0/24'
    }
  ]
}
```

### Parameter Decorators

Decorators provide metadata and validation for parameters:

#### Description Decorator
```bicep
@description('The name of the storage account')
param storageAccountName string
```

#### Allowed Values
```bicep
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'
```

#### String Length Constraints
```bicep
@minLength(3)
@maxLength(24)
param storageAccountName string
```

#### Numeric Range Constraints
```bicep
@minValue(1)
@maxValue(100)
param instanceCount int = 1
```

#### Secure Parameters
```bicep
@secure()
param adminPassword string

@secure()
param connectionString string
```

### Parameter Files

Parameter files allow you to provide values for parameters without modifying the template:

```json
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountName": {
      "value": "myuniquestorageaccount"
    },
    "location": {
      "value": "West US"
    },
    "storageAccountType": {
      "value": "Standard_GRS"
    }
  }
}
```

## Variables

Variables are used to store computed values and reduce repetition in your templates.

### Basic Variable Syntax

```bicep
var <variable-name> = <value-expression>
```

### Simple Variables
```bicep
var location = 'East US'
var storageAccountName = 'mystorage001'
var resourceGroupName = resourceGroup().name
```

### Computed Variables
```bicep
param applicationName string
param environment string

var namePrefix = '`${applicationName}-`${environment}'
var storageAccountName = '`${namePrefix}-storage-`${uniqueString(resourceGroup().id)}'
var tags = {
  Environment: environment
  Application: applicationName
  CreatedBy: 'Bicep'
}
```

## Resources

Resources are the Azure services you want to deploy and manage.

### Basic Resource Syntax

```bicep
resource <symbolic-name> '<resource-type>@<api-version>' = {
  name: '<resource-name>'
  location: '<location>'
  properties: {
    // Resource-specific properties
  }
}
```

### Storage Account Example
```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount001'
  location: 'East US'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}
```

## Best Practices

### 1. Use Descriptive Names
```bicep
// Good
param webAppName string
var storageAccountName = '`${webAppName}storage`${uniqueString(resourceGroup().id)}'

// Avoid
param name string
var sa = '`${name}`${uniqueString(resourceGroup().id)}'
```

### 2. Provide Defaults Where Appropriate
```bicep
param location string = resourceGroup().location
param environmentType string = 'dev'
param enableMonitoring bool = false
```

This covers the essential concepts you need to build effective Bicep templates. Practice these patterns and gradually build more complex infrastructure as you become comfortable with the basics.
"@ | Out-File -FilePath "docs\02-basic-concepts.md" -Encoding UTF8

Write-Host "Creating Advanced Topics guide..." -ForegroundColor Yellow

# Create docs/03-advanced-topics.md (summary version)
@"
# Advanced Topics: Modules, Patterns, and Best Practices

This section covers advanced Bicep concepts including modules, complex patterns, and production-ready best practices.

## Modules

Modules enable you to break down complex templates into reusable, manageable components.

### Why Use Modules?

- **Reusability**: Write once, use many times
- **Maintainability**: Easier to update and debug
- **Team Collaboration**: Different teams can work on different modules
- **Testing**: Test individual components in isolation
- **Abstraction**: Hide complexity behind simple interfaces

### Creating Modules

A module is simply a Bicep file that can be referenced from another Bicep template.

#### Example: Storage Module (``modules/storage.bicep``)
```bicep
@description('The name of the storage account')
param storageAccountName string

@description('The location for the storage account')
param location string

@description('The environment type')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string

// Environment-specific configuration
var config = {
  dev: {
    sku: 'Standard_LRS'
    accessTier: 'Cool'
  }
  test: {
    sku: 'Standard_LRS'
    accessTier: 'Hot'
  }
  prod: {
    sku: 'Standard_GRS'
    accessTier: 'Hot'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: config[environmentType].sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: config[environmentType].accessTier
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
output storageAccountKey string = storageAccount.listKeys().keys[0].value
```

### Using Modules

```bicep
// main.bicep
param applicationName string
param environmentType string = 'dev'
param location string = resourceGroup().location

var storageAccountName = '`${applicationName}`${environmentType}`${uniqueString(resourceGroup().id)}'

// Use the storage module
module storageModule 'modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    storageAccountName: storageAccountName
    location: location
    environmentType: environmentType
  }
}

// Use outputs from the module
output storageEndpoint string = storageModule.outputs.primaryEndpoints.blob
```

## Advanced Patterns

### Environment Configuration Pattern

Create environment-specific configurations using objects:

```bicep
param environmentType string

// Centralized environment configuration
var environmentConfig = {
  dev: {
    appService: {
      sku: 'B1'
      instances: 1
      alwaysOn: false
    }
    database: {
      tier: 'Basic'
      capacity: 5
    }
    monitoring: {
      enabled: false
      retentionDays: 30
    }
  }
  prod: {
    appService: {
      sku: 'P2v3'
      instances: 3
      alwaysOn: true
    }
    database: {
      tier: 'Premium'
      capacity: 125
    }
    monitoring: {
      enabled: true
      retentionDays: 365
    }
  }
}

// Use the configuration
var config = environmentConfig[environmentType]
```

### Conditional Deployment Pattern

Deploy resources based on conditions:

```bicep
param features object = {
  monitoring: true
  backup: false
  cdn: true
  redis: false
}

// Conditional monitoring
resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (features.monitoring) {
  name: 'app-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
```

## Production Best Practices

### 1. Use Parameter Files for Environments

```bash
# Development
az deployment group create \
  --template-file main.bicep \
  --parameters @parameters.dev.json

# Production  
az deployment group create \
  --template-file main.bicep \
  --parameters @parameters.prod.json
```

### 2. Implement Proper Naming Conventions

```bicep
param workloadName string
param environmentType string
param instanceNumber string = '001'

var namingConvention = {
  storageAccount: '`${workloadName}`${environmentType}`${instanceNumber}'
  appServicePlan: '`${workloadName}-`${environmentType}-plan-`${instanceNumber}'
  webApp: '`${workloadName}-`${environmentType}-app-`${instanceNumber}'
  keyVault: '`${workloadName}-`${environmentType}-kv-`${instanceNumber}'
}
```

### 3. Use Resource Locks

```bicep
resource resourceLock 'Microsoft.Authorization/locks@2020-05-01' = {
  scope: storageAccount
  name: 'storage-account-lock'
  properties: {
    level: 'CanNotDelete'
    notes: 'Prevent accidental deletion of critical storage account'
  }
}
```

This comprehensive guide covers the advanced concepts you need to build production-ready infrastructure with Bicep. Practice these patterns and gradually incorporate them into your templates as you become more comfortable with the basics.
"@ | Out-File -FilePath "docs\03-advanced-topics.md" -Encoding UTF8

Write-Host "Creating Troubleshooting guide..." -ForegroundColor Yellow

# Create docs/troubleshooting.md (summary version)
@"
# Troubleshooting Guide

This guide covers common issues you might encounter when working with Bicep templates and their solutions.

## Common Deployment Errors

### 1. Resource Name Conflicts

**Error**: ``The storage account name 'mystorageaccount' is already taken.``

**Cause**: Storage account names must be globally unique across all of Azure.

**Solution**:
```bicep
// Problem: Hard-coded name
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'  // This will fail if name is taken
  location: location
  // ...
}

// Solution: Use unique naming
var storageAccountName = 'storage`${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  // ...
}
```

### 2. Invalid Resource Names

**Error**: ``The resource name 'my-storage-account' is invalid.``

**Cause**: Each Azure resource type has specific naming requirements.

**Common Naming Rules**:
- Storage accounts: 3-24 characters, lowercase letters and numbers only
- Web apps: 2-60 characters, alphanumeric and hyphens
- Key vaults: 3-24 characters, alphanumeric and hyphens

**Solution**:
```bicep
// Problem: Invalid characters
var storageAccountName = 'my-storage-account'  // Contains hyphens

// Solution: Follow naming rules
var storageAccountName = replace('my-storage-account', '-', '')  // Remove hyphens
var webAppName = 'my-web-app'  // Valid for web apps
```

### 3. Missing Required Properties

**Error**: ``The template is missing required property 'sku'.``

**Solution**:
```bicep
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
```

## Debugging Strategies

### 1. Use What-If Deployments

Preview changes before deploying:
```bash
az deployment group what-if \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @parameters.json
```

### 2. Validate Templates

Check template syntax and logic:
```bash
# Validate syntax
az bicep build --file main.bicep

# Validate deployment
az deployment group validate \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters @parameters.json
```

### 3. Use Deployment Outputs for Debugging

Add debug outputs to your templates:
```bicep
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
```

## Troubleshooting Checklist

When encountering issues, work through this checklist:

### 1. Template Validation
- [ ] Template syntax is correct (``az bicep build``)
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
- [ ] Use ``what-if`` to preview changes
- [ ] Deploy to dev/test environment first
- [ ] Test with minimal template before adding complexity

Remember: Most Bicep issues are due to syntax errors, missing dependencies, or permission problems. Working through the checklist systematically will help you identify and resolve issues quickly.
"@ | Out-File -FilePath "docs\troubleshooting.md" -Encoding UTF8

Write-Host ""
Write-Host "Documentation files created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Created files:" -ForegroundColor Cyan
Write-Host "  📄 docs\01-getting-started.md" -ForegroundColor White
Write-Host "  📄 docs\02-basic-concepts.md" -ForegroundColor White
Write-Host "  📄 docs\03-advanced-topics.md" -ForegroundColor White
Write-Host "  📄 docs\troubleshooting.md" -ForegroundColor White
Write-Host ""
Write-Host "Your documentation is now complete! 📚" -ForegroundColor Green