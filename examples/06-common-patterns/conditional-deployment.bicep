// Conditional deployment patterns

@description('The name prefix for resources')
param namePrefix string

@description('The location for all resources')
param location string = resourceGroup().location

@description('Whether to deploy the database')
param deployDatabase bool = false

@description('Whether to deploy monitoring')
param deployMonitoring bool = true

@description('The environment type')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentType string = 'dev'

// Variables
var storageAccountName = '${namePrefix}${environmentType}${uniqueString(resourceGroup().id)}'
var appServicePlanName = '${namePrefix}-${environmentType}-plan'
var webAppName = '${namePrefix}-${environmentType}-app'
var sqlServerName = '${namePrefix}-${environmentType}-sql'
var databaseName = '${namePrefix}-${environmentType}-db'

// Always deploy storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Always deploy app service plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: environmentType == 'prod' ? 'P1v3' : 'B1'
    tier: environmentType == 'prod' ? 'PremiumV3' : 'Basic'
  }
}

// Always deploy web app
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

// Conditionally deploy SQL Server and Database
resource sqlServer 'Microsoft.Sql/servers@2023-02-01-preview' = if (deployDatabase) {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'Password123!'
  }
}

resource database 'Microsoft.Sql/servers/databases@2023-02-01-preview' = if (deployDatabase) {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: environmentType == 'prod' ? 'S2' : 'S0'
    tier: 'Standard'
  }
}

// Conditionally deploy Application Insights for monitoring
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (deployMonitoring) {
  name: '${namePrefix}-${environmentType}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environmentType == 'prod' ? 90 : 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (deployMonitoring) {
  name: '${namePrefix}-${environmentType}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Outputs (conditional outputs)
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output storageAccountName string = storageAccount.name
output databaseConnectionString string = deployDatabase ? 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${database.name};' : 'No database deployed'
output appInsightsKey string = deployMonitoring ? appInsights.properties.InstrumentationKey : 'Monitoring not deployed'
