// Web app with storage account showing dependencies

@description('The name of the web app')
param webAppName string

@description('The location for all resources')
param location string = resourceGroup().location

@description('The environment type')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string = 'dev'

// Variables
var appServicePlanName = '${webAppName}-plan'
var storageAccountName = '${webAppName}${environmentType}${uniqueString(resourceGroup().id)}'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: environmentType == 'prod' ? 'P1v3' : 'B1'
    tier: environmentType == 'prod' ? 'PremiumV3' : 'Basic'
  }
  kind: 'app'
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
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

// Web App (depends on App Service Plan)
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: storageAccount.name
        }
        {
          name: 'STORAGE_ACCOUNT_KEY'
          value: storageAccount.listKeys().keys[0].value
        }
      ]
    }
  }
}

output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output storageAccountName string = storageAccount.name
