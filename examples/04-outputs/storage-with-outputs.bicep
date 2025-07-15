// Storage account with comprehensive outputs

@description('The name of the storage account')
param storageAccountName string

@description('The location for the storage account')
param location string = resourceGroup().location

@description('The SKU for the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Outputs
@description('The resource ID of the storage account')
output storageAccountId string = storageAccount.id

@description('The name of the storage account')
output storageAccountName string = storageAccount.name

@description('The primary endpoint for blob storage')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('The primary access key for the storage account')
@secure()
output storageAccountKey string = storageAccount.listKeys().keys[0].value

@description('Connection string for the storage account')
@secure()
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

@description('Complete storage account information')
output storageAccountInfo object = {
  name: storageAccount.name
  id: storageAccount.id
  location: storageAccount.location
  sku: storageAccount.sku.name
  endpoints: storageAccount.properties.primaryEndpoints
}
