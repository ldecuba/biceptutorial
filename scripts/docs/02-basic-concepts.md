# Basic Concepts: Parameters, Variables, and Resources

This section covers the fundamental building blocks of Bicep templates: parameters, variables, and resources.

## Parameters

Parameters are inputs to your Bicep template that make your templates reusable across different environments and scenarios.

### Basic Parameter Syntax

`icep
param <parameter-name> <data-type> = <default-value>
`

### Parameter Data Types

#### String Parameters
`icep
param applicationName string
param location string = 'East US'  // With default value
param description string = ''       // Empty string default
`

#### Numeric Parameters
`icep
param instanceCount int = 1
param maxUsers int
`

#### Boolean Parameters
`icep
param enableHttps bool = true
param deployToProduction bool
`

#### Array Parameters
`icep
param allowedLocations array = [
  'East US'
  'West US'
  'North Europe'
]

param vmSizes array
`

#### Object Parameters
`icep
param networkConfig object = {
  addressPrefix: '10.0.0.0/16'
  subnets: [
    {
      name: 'frontend'
      addressPrefix: '10.0.1.0/24'
    }
    {
      name: 'backend'
      addressPrefix: '10.0.2.0/24'
    }
  ]
}
`

### Parameter Decorators

Decorators provide metadata and validation for parameters:

#### Description Decorator
`icep
@description('The name of the storage account')
param storageAccountName string
`

#### Allowed Values
`icep
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'
`

#### String Length Constraints
`icep
@minLength(3)
@maxLength(24)
param storageAccountName string
`

#### Numeric Range Constraints
`icep
@minValue(1)
@maxValue(100)
param instanceCount int = 1
`

#### Secure Parameters
`icep
@secure()
param adminPassword string

@secure()
param connectionString string
`

### Parameter Files

Parameter files allow you to provide values for parameters without modifying the template:

`json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountName": {
      "value": "myuniquestorageaccount"
    },
    "location": {
      "value": "West US"
    },
    "storageAccountType": {
      "value": "Standard_GRS"
    }
  }
}
`

## Variables

Variables are used to store computed values and reduce repetition in your templates.

### Basic Variable Syntax

`icep
var <variable-name> = <value-expression>
`

### Simple Variables
`icep
var location = 'East US'
var storageAccountName = 'mystorage001'
var resourceGroupName = resourceGroup().name
`

### Computed Variables
`icep
param applicationName string
param environment string

var namePrefix = '${applicationName}-${environment}'
var storageAccountName = '${namePrefix}-storage-${uniqueString(resourceGroup().id)}'
var tags = {
  Environment: environment
  Application: applicationName
  CreatedBy: 'Bicep'
}
`

## Resources

Resources are the Azure services you want to deploy and manage.

### Basic Resource Syntax

`icep
resource <symbolic-name> '<resource-type>@<api-version>' = {
  name: '<resource-name>'
  location: '<location>'
  properties: {
    // Resource-specific properties
  }
}
`

### Storage Account Example
`icep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount001'
  location: 'East US'
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
`

## Best Practices

### 1. Use Descriptive Names
`icep
// Good
param webAppName string
var storageAccountName = '${webAppName}storage${uniqueString(resourceGroup().id)}'

// Avoid
param name string
var sa = '${name}${uniqueString(resourceGroup().id)}'
`

### 2. Provide Defaults Where Appropriate
`icep
param location string = resourceGroup().location
param environmentType string = 'dev'
param enableMonitoring bool = false
`

This covers the essential concepts you need to build effective Bicep templates. Practice these patterns and gradually build more complex infrastructure as you become comfortable with the basics.
