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
var computedStorageName = '${namingPrefix}${environmentType}${uniqueSuffix}'

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
