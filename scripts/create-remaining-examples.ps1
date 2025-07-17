# create-remaining-examples.ps1
# PowerShell script to create examples 3-7

Write-Host "Creating remaining examples..." -ForegroundColor Green

Write-Host "Creating Example 3: Dependencies..." -ForegroundColor Yellow

# Example 3: Dependencies
@"
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
var appServicePlanName = '`${webAppName}-plan'
var storageAccountName = '`${webAppName}`${environmentType}`${uniqueString(resourceGroup().id)}'

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

output webAppUrl string = 'https://`${webApp.properties.defaultHostName}'
output storageAccountName string = storageAccount.name
"@ | Out-File -FilePath "examples\03-dependencies\web-app-with-storage.bicep" -Encoding UTF8

@"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "webAppName": {
      "value": "mybicepwebapp001"
    },
    "location": {
      "value": "East US"
    },
    "environmentType": {
      "value": "dev"
    }
  }
}
"@ | Out-File -FilePath "examples\03-dependencies\web-app.parameters.json" -Encoding UTF8

# PowerShell deploy script for Example 3
@"
# deploy.ps1 - Example 3 deployment script

param(
    [string]`$ResourceGroup = "rg-bicep-tutorial",
    [string]`$Location = "East US"
)

`$DeploymentName = "dependencies-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "Deploying web app with dependencies..." -ForegroundColor Green

# Create resource group if it doesn't exist
az group create --name `$ResourceGroup --location "`$Location"

# Deploy template
Write-Host "Deploying template..." -ForegroundColor Yellow
az deployment group create ``
  --resource-group `$ResourceGroup ``
  --template-file web-app-with-storage.bicep ``
  --parameters "@web-app.parameters.json" ``
  --name `$DeploymentName

# Show deployment status
Write-Host "`nDeployment completed:" -ForegroundColor Green
az deployment group show ``
  --resource-group `$ResourceGroup ``
  --name `$DeploymentName ``
  --query "properties.{Status:provisioningState, Duration:duration}" ``
  --output table

# Show created resources
Write-Host "`nCreated resources:" -ForegroundColor Green
az resource list --resource-group `$ResourceGroup --output table
"@ | Out-File -FilePath "examples\03-dependencies\deploy.ps1" -Encoding UTF8

Write-Host "Creating Example 4: Outputs..." -ForegroundColor Yellow

# Example 4: Outputs
@"
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
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=`${storageAccount.name};AccountKey=`${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

@description('Complete storage account information')
output storageAccountInfo object = {
  name: storageAccount.name
  id: storageAccount.id
  location: storageAccount.location
  sku: storageAccount.sku.name
  endpoints: storageAccount.properties.primaryEndpoints
}
"@ | Out-File -FilePath "examples\04-outputs\storage-with-outputs.bicep" -Encoding UTF8

@"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountName": {
      "value": "mybicepstorageout001"
    },
    "location": {
      "value": "East US"
    },
    "storageAccountType": {
      "value": "Standard_LRS"
    }
  }
}
"@ | Out-File -FilePath "examples\04-outputs\storage.parameters.json" -Encoding UTF8

Write-Host "Creating Example 5: Modules..." -ForegroundColor Yellow

# Example 5: Main template
@"
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
var storageAccountName = '`${namePrefix}`${environmentType}`${uniqueString(resourceGroup().id)}'
var webAppName = '`${namePrefix}-`${environmentType}-app'

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
"@ | Out-File -FilePath "examples\05-modules\main.bicep" -Encoding UTF8

# Storage module
@"
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
"@ | Out-File -FilePath "examples\05-modules\modules\storage.bicep" -Encoding UTF8

# Web app module
@"
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
var appServicePlanName = '`${webAppName}-plan'
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
output webAppUrl string = 'https://`${webApp.properties.defaultHostName}'
output appServicePlanId string = appServicePlan.id
"@ | Out-File -FilePath "examples\05-modules\modules\web-app.bicep" -Encoding UTF8

@"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "namePrefix": {
      "value": "bicepmod"
    },
    "location": {
      "value": "East US"
    },
    "environmentType": {
      "value": "dev"
    }
  }
}
"@ | Out-File -FilePath "examples\05-modules\main.parameters.json" -Encoding UTF8

Write-Host "Creating Example 6: Common Patterns..." -ForegroundColor Yellow

# Example 6: Conditional deployment
@"
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
var storageAccountName = '`${namePrefix}`${environmentType}`${uniqueString(resourceGroup().id)}'
var appServicePlanName = '`${namePrefix}-`${environmentType}-plan'
var webAppName = '`${namePrefix}-`${environmentType}-app'
var sqlServerName = '`${namePrefix}-`${environmentType}-sql'
var databaseName = '`${namePrefix}-`${environmentType}-db'

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
  name: '`${namePrefix}-`${environmentType}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environmentType == 'prod' ? 90 : 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (deployMonitoring) {
  name: '`${namePrefix}-`${environmentType}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Outputs (conditional outputs)
output webAppUrl string = 'https://`${webApp.properties.defaultHostName}'
output storageAccountName string = storageAccount.name
output databaseConnectionString string = deployDatabase ? 'Server=tcp:`${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=`${database.name};' : 'No database deployed'
output appInsightsKey string = deployMonitoring ? appInsights.properties.InstrumentationKey : 'Monitoring not deployed'
"@ | Out-File -FilePath "examples\06-common-patterns\conditional-deployment.bicep" -Encoding UTF8

Write-Host "Creating README files for examples..." -ForegroundColor Yellow

# Create README for Example 3
@"
# Example 3: Dependencies

This example demonstrates how Bicep handles resource dependencies automatically and explicitly.

## What You'll Learn
- Implicit dependencies (automatic)
- Explicit dependencies (manual)
- Resource references
- Multi-resource deployments

## Files
- ``web-app-with-storage.bicep`` - Template with dependent resources
- ``web-app.parameters.json`` - Parameter file
- ``deploy.ps1`` - Deployment script

## Key Concepts
- **Implicit Dependencies**: When you reference one resource from another (e.g., ``appServicePlan.id``), Bicep automatically creates the dependency
- **Resource References**: Use the symbolic name to reference properties of other resources
- **Deployment Order**: Bicep ensures resources are deployed in the correct order

## How to Deploy

### PowerShell
``````powershell
.\deploy.ps1
``````

### Bash
``````bash
./deploy.sh
``````

## What Gets Created
- App Service Plan
- Storage Account
- Web App (connected to both above resources)

## Next Steps
Go to [Example 4](../04-outputs/) to learn about outputs.
"@ | Out-File -FilePath "examples\03-dependencies\README.md" -Encoding UTF8

# Create README for Example 4
@"
# Example 4: Outputs

This example demonstrates how to return values from your Bicep deployments using outputs.

## What You'll Learn
- Different types of outputs (strings, objects, secure values)
- How to use outputs in other templates
- Best practices for output naming and descriptions

## Files
- ``storage-with-outputs.bicep`` - Template with comprehensive outputs
- ``storage.parameters.json`` - Parameter file
- ``deploy.ps1`` - Deployment script

## Key Concepts
- **Simple Outputs**: Return basic values like resource IDs and names
- **Secure Outputs**: Use ``@secure()`` decorator for sensitive data
- **Complex Outputs**: Return objects with multiple properties
- **Output Descriptions**: Document what each output provides

## How to Deploy

### PowerShell
``````powershell
.\deploy.ps1
``````

After deployment, view outputs:
``````powershell
az deployment group show --resource-group rg-bicep-tutorial --name <deployment-name> --query "properties.outputs"
``````

## What Gets Created
- Storage Account with comprehensive outputs

## Outputs Provided
- Storage account ID and name
- Blob endpoint
- Storage account key (secure)
- Connection string (secure)
- Complete storage account information object

## Next Steps
Go to [Example 5](../05-modules/) to learn about modules.
"@ | Out-File -FilePath "examples\04-outputs\README.md" -Encoding UTF8

Write-Host ""
Write-Host "Additional examples created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Created examples:" -ForegroundColor Cyan
Write-Host "  📁 examples\03-dependencies - Web app with storage dependencies" -ForegroundColor White
Write-Host "  📁 examples\04-outputs - Storage account with comprehensive outputs" -ForegroundColor White
Write-Host "  📁 examples\05-modules - Modular architecture with storage and web app modules" -ForegroundColor White
Write-Host "  📁 examples\06-common-patterns - Conditional deployment patterns" -ForegroundColor White
Write-Host ""
Write-Host "Your tutorial now has 6 complete examples! 🎉" -ForegroundColor Green