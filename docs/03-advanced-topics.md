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

#### Example: Storage Module (`modules/storage.bicep`)
`icep
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
`

### Using Modules

`icep
// main.bicep
param applicationName string
param environmentType string = 'dev'
param location string = resourceGroup().location

var storageAccountName = '${applicationName}${environmentType}${uniqueString(resourceGroup().id)}'

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
`

## Advanced Patterns

### Environment Configuration Pattern

Create environment-specific configurations using objects:

`icep
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
`

### Conditional Deployment Pattern

Deploy resources based on conditions:

`icep
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
`

## Production Best Practices

### 1. Use Parameter Files for Environments

`ash
# Development
az deployment group create \
  --template-file main.bicep \
  --parameters @parameters.dev.json

# Production  
az deployment group create \
  --template-file main.bicep \
  --parameters @parameters.prod.json
`

### 2. Implement Proper Naming Conventions

`icep
param workloadName string
param environmentType string
param instanceNumber string = '001'

var namingConvention = {
  storageAccount: '${workloadName}${environmentType}${instanceNumber}'
  appServicePlan: '${workloadName}-${environmentType}-plan-${instanceNumber}'
  webApp: '${workloadName}-${environmentType}-app-${instanceNumber}'
  keyVault: '${workloadName}-${environmentType}-kv-${instanceNumber}'
}
`

### 3. Use Resource Locks

`icep
resource resourceLock 'Microsoft.Authorization/locks@2020-05-01' = {
  scope: storageAccount
  name: 'storage-account-lock'
  properties: {
    level: 'CanNotDelete'
    notes: 'Prevent accidental deletion of critical storage account'
  }
}
`

This comprehensive guide covers the advanced concepts you need to build production-ready infrastructure with Bicep. Practice these patterns and gradually incorporate them into your templates as you become more comfortable with the basics.
