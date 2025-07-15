// Storage account module

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

// Variables
var storageAccountType = environmentType == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
var accessTier = environmentType == 'prod' ? 'Hot' : 'Cool'

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
    allowBlobPublicAccess: false
  }
}

// Create blob service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

// Create container
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'data'
  properties: {
    publicAccess: 'None'
  }
}

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output storageAccountKey string = storageAccount.listKeys().keys[0].value
