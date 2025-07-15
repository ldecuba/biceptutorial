// API Version Management Example
// This template demonstrates best practices for API version management

metadata apiVersionInfo = {
  description: 'Template demonstrating API version management best practices'
  lastReviewed: '2025-01-15'
  updateSchedule: 'Quarterly'
  maintainer: 'Infrastructure Team'
}

@description('The application name')
param applicationName string

@description('The environment type')
@allowed(['dev', 'test', 'prod'])
param environmentType string = 'dev'

@description('The location for all resources')
param location string = resourceGroup().location

@description('Use preview API versions (dev/test only)')
param usePreviewAPIs bool = false

// API Version Management Strategy
// Define all API versions in one place for easy maintenance
var apiVersions = (environmentType == 'prod' || !usePreviewAPIs) ? {
  // Stable API versions for production
  storage: '2023-01-01'
  webSites: '2023-01-01'
  appServicePlans: '2023-01-01'
} : {
  // Preview API versions for dev/test (when enabled)
  storage: '2023-05-01-preview'
  webSites: '2023-12-01-preview'  
  appServicePlans: '2023-12-01-preview'
}

// Variables for consistent naming
var namePrefix = '${applicationName}-${environmentType}'
var storageAccountName = '${applicationName}${environmentType}${uniqueString(resourceGroup().id)}'

// Storage Account - demonstrates feature availability by API version
resource storageAccount 'Microsoft.Storage/storageAccounts@${apiVersions.storage}' = {
  name: storageAccountName
  location: location
  sku: {
    name: environmentType == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    // These properties require specific API versions:
    minimumTlsVersion: 'TLS1_2'           // Requires 2019-06-01+
    allowBlobPublicAccess: false           // Requires 2019-04-01+  
    supportsHttpsTrafficOnly: true         // Available since 2016-01-01
    allowCrossTenantReplication: false     // Requires 2021-02-01+
  }
  tags: {
    Environment: environmentType
    ApiVersion: apiVersions.storage
    LastUpdated: utcNow()
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@${apiVersions.appServicePlans}' = {
  name: '${namePrefix}-plan'
  location: location
  sku: {
    name: environmentType == 'prod' ? 'P1v3' : 'B1'
    tier: environmentType == 'prod' ? 'PremiumV3' : 'Basic'
  }
  properties: {
    reserved: false  // Windows App Service Plan
  }
  tags: {
    Environment: environmentType
    ApiVersion: apiVersions.appServicePlans
  }
}

// Web App - shows conditional features based on API version
resource webApp 'Microsoft.Web/sites@${apiVersions.webSites}' = {
  name: '${namePrefix}-app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      // These settings may require specific API versions
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: [
        {
          name: 'STORAGE_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'ENVIRONMENT_TYPE'
          value: environmentType
        }
        {
          name: 'API_VERSION_STRATEGY'
          value: usePreviewAPIs ? 'preview' : 'stable'
        }
      ]
    }
  }
  tags: {
    Environment: environmentType
    ApiVersion: apiVersions.webSites
  }
}

// Outputs that show API version information
output deploymentInfo object = {
  environmentType: environmentType
  usePreviewAPIs: usePreviewAPIs
  apiVersionsUsed: apiVersions
  resourcesDeployed: {
    storageAccount: {
      name: storageAccount.name
      apiVersion: apiVersions.storage
    }
    appServicePlan: {
      name: appServicePlan.name  
      apiVersion: apiVersions.appServicePlans
    }
    webApp: {
      name: webApp.name
      apiVersion: apiVersions.webSites
      url: 'https://${webApp.properties.defaultHostName}'
    }
  }
}

output apiVersionAudit object = {
  templateLastUpdated: '2025-01-15'
  nextReviewDate: '2025-04-15'
  apiVersionStrategy: usePreviewAPIs ? 'Using preview versions for testing' : 'Using stable versions for production'
  upgradeRecommendations: [
    'Review API versions quarterly'
    'Test new API versions in dev environment first'
    'Monitor Azure announcements for deprecations'
    'Use automation to check for outdated versions'
  ]
}
