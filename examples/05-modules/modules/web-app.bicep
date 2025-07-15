// Web app module

@description('The name of the web app')
param webAppName string

@description('The location for the web app')
param location string

@description('The environment type')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string

@description('The name of the storage account')
param storageAccountName string

@description('The storage account key')
@secure()
param storageAccountKey string

// Variables
var appServicePlanName = '${webAppName}-plan'
var appServicePlanSku = environmentType == 'prod' ? 'P1v3' : 'B1'
var appServicePlanTier = environmentType == 'prod' ? 'PremiumV3' : 'Basic'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku
    tier: appServicePlanTier
  }
  kind: 'app'
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: storageAccountName
        }
        {
          name: 'STORAGE_ACCOUNT_KEY'
          value: storageAccountKey
        }
        {
          name: 'ENVIRONMENT'
          value: environmentType
        }
      ]
      netFrameworkVersion: 'v8.0'
    }
  }
}

// Outputs
output webAppId string = webApp.id
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output appServicePlanId string = appServicePlan.id
