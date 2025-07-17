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


Bicep Template → Bicep CLI → ARM Template → Azure Resource Manager → Azure Resources


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

az bicep install


#### 3. Install VS Code Extensions
- Bicep Extension
- Azure Account Extension
- Azure Resources Extension

#### 4. Verify Installation

az --version
az bicep version


Expected output:

azure-cli                         2.54.0
bicep                            0.23.1


### Login to Azure


# Login interactively
az login

# List available subscriptions
az account list --output table

# Set active subscription
az account set --subscription "Your Subscription Name"

# Verify current subscription
az account show --output table


## Your First Bicep Template

Let's create a simple storage account to understand the basics.

### Create Your First Template

Create a file called storage.bicep:

icep
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


### Understanding the Template

Let's break down each part:

icep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
//  ↑            ↑                       ↑
//  |            |                       |
//  |            |                       └── API Version
//  |            └─────────────────────────── Resource Type
//  └──────────────────────────────────────── Symbolic Name


- **resource**: Keyword that declares a resource
- **storageAccount**: Symbolic name used within the template
- **Microsoft.Storage/storageAccounts@2023-01-01**: Resource type and API version
- **Properties**: Configuration for the resource

### Deploy Your First Template


# Create a resource group
az group create --name rg-bicep-tutorial --location "East US"

# Deploy the template
az deployment group create \
  --resource-group rg-bicep-tutorial \
  --template-file storage.bicep \
  --name first-deployment


### Verify the Deployment


# Check deployment status
az deployment group show \
  --resource-group rg-bicep-tutorial \
  --name first-deployment \
  --query properties.provisioningState

# List resources in the group
az resource list --resource-group rg-bicep-tutorial --output table


## Understanding Bicep Syntax

### Basic Structure

Every Bicep template has this general structure:

icep
// 1. Target scope (optional)
targetScope = 'resourceGroup'

// 2. Parameters (inputs)
param location string = 'East US'
param environment string

// 3. Variables (computed values)
var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'

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


### Data Types

Bicep supports several data types:

icep
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


### String Interpolation

Bicep supports string interpolation using  syntax (where xpression is a variable or value):

icep
param applicationName string = 'myapp'
param environment string = 'dev'

var resourceName = '${applicationName}-${environment}'
var greeting = 'Hello ${applicationName}!'
var storageAccountName = '${applicationName}${environment}${uniqueString(resourceGroup().id)}'


### Comments

icep
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


## Common Functions

Bicep provides many built-in functions:

icep
// Generate unique string based on resource group
var uniqueName = 'storage${uniqueString(resourceGroup().id)}'

// Get resource group location
var location = resourceGroup().location

// Concatenate strings
var fullName = concat('prefix', 'suffix')

// String interpolation (preferred)
var fullName2 = '${prefix}${suffix}'

// Array functions
var firstItem = first(myArray)
var lastItem = last(myArray)
var arrayLength = length(myArray)

// Object functions
var objectKeys = keys(myObject)
var hasProperty = contains(myObject, 'propertyName')


## Best Practices for Beginners

### 1. Use Descriptive Names
icep
// Good
resource primaryStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'primarystorage${uniqueString(resourceGroup().id)}'
  // ...
}

// Avoid
resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'storage1'
  // ...
}


### 2. Use Variables for Repeated Values
icep
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


### 3. Add Comments
icep
// Storage account for application data
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'
  location: 'East US'
  sku: {
    name: 'Standard_LRS' // Locally redundant storage for cost optimization
  }
  kind: 'StorageV2'
}


### 4. Use Consistent Naming Conventions
icep
// Establish a pattern and stick to it
var namingPrefix = '${applicationName}-${environment}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${namingPrefix}-storage'
  // ...
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${namingPrefix}-plan'
  // ...
}


## Next Steps

Now that you understand the basics, you're ready to move on to:

1. **[Basic Concepts](02-basic-concepts.md)** - Parameters, variables, and resources
2. **[Advanced Topics](03-advanced-topics.md)** - Modules, patterns, and best practices
3. **[Examples](../examples/)** - Hands-on practice with real templates

## Quick Reference

### Essential Commands

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


### Resource Declaration Syntax
icep
resource <symbolic-name> '<resource-type>@<api-version>' = {
  name: 'actual-resource-name'
  location: 'resource-location'
  properties: {
    // Resource-specific properties
  }
}


You're now ready to start building more complex templates!

