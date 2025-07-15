// Main template using modules

@description('The name prefix for all resources')
param namePrefix string

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
var storageAccountName = '${namePrefix}${environmentType}${uniqueString(resourceGroup().id)}'
var webAppName = '${namePrefix}-${environmentType}-app'

// Deploy storage account using module
module storageModule 'modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    storageAccountName: storageAccountName
    location: location
    environmentType: environmentType
  }
}

// Deploy web app using module
module webAppModule 'modules/web-app.bicep' = {
  name: 'webAppDeployment'
  params: {
    webAppName: webAppName
    location: location
    environmentType: environmentType
    storageAccountName: storageModule.outputs.storageAccountName
    storageAccountKey: storageModule.outputs.storageAccountKey
  }
}

// Outputs
output storageAccountEndpoint string = storageModule.outputs.blobEndpoint
output webAppUrl string = webAppModule.outputs.webAppUrl
output webAppName string = webAppModule.outputs.webAppName
