# create-repository.ps1
# PowerShell script to create the complete Bicep tutorial repository structure
# Run this script in an empty directory to create all files

Write-Host "Creating Bicep Tutorial Repository Structure..." -ForegroundColor Green

# Create directory structure
$directories = @(
    "docs",
    "examples\01-first-template",
    "examples\02-parameters-variables", 
    "examples\03-dependencies",
    "examples\04-outputs",
    "examples\05-modules\modules",
    "examples\06-common-patterns",
    "examples\07-real-world\three-tier-app\modules",
    "scripts",
    ".github\workflows"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

Write-Host "Creating documentation files..." -ForegroundColor Yellow

# Create README.md
@"
# Bicep Infrastructure as Code Tutorial

A comprehensive tutorial for learning Azure Bicep Infrastructure as Code from beginner to advanced level.

## 🚀 Getting Started

This tutorial will take you from complete beginner to confident Bicep developer. Each section builds upon the previous one, so it's recommended to follow them in order.

### Prerequisites

- Azure CLI installed
- Bicep CLI installed
- VS Code with Bicep extension (recommended)
- Azure subscription with appropriate permissions

### Quick Setup

Run the setup script to install all prerequisites:
```bash
./scripts/setup-environment.sh
```

## 📚 Tutorial Structure

### Part 1: Foundation
- [Getting Started](docs/01-getting-started.md) - What is IaC and Bicep basics
- [Basic Concepts](docs/02-basic-concepts.md) - Syntax, parameters, variables, resources

### Part 2: Intermediate
- [Advanced Topics](docs/03-advanced-topics.md) - Modules, patterns, best practices

### Part 3: Reference
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions

## 🔧 Examples

Each example includes:
- Complete Bicep template
- Parameter files
- Deployment script
- README with explanation

### Available Examples:
1. **First Template** - Simple storage account
2. **Parameters & Variables** - Reusable templates
3. **Dependencies** - Multi-resource deployments
4. **Outputs** - Returning values from deployments
5. **Modules** - Reusable components
6. **Common Patterns** - Conditional deployment, loops, environment configs
7. **Real-world Scenarios** - Complete application deployments

## 🏃‍♂️ Quick Start

1. Clone this repository
2. Navigate to ``examples/01-first-template``
3. Update the parameters file with your values
4. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

## 🧪 Testing

Validate all templates:
```bash
./scripts/validate-all.sh
```

## 🧹 Cleanup

Clean up all resources created during the tutorial:
```bash
./scripts/cleanup.sh
```

## 🤝 Contributing

Feel free to contribute improvements, additional examples, or corrections!

## 📖 Additional Resources

- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Bicep Examples](https://github.com/Azure/bicep/tree/main/docs/examples)
- [Azure Quickstart Templates](https://azure.microsoft.com/en-us/resources/templates/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
"@ | Out-File -FilePath "README.md" -Encoding UTF8

# Create .gitignore
@"
# Bicep build outputs
*.json
!*.parameters.json
!*.bicepparam.json

# Azure CLI
.azure/

# VS Code
.vscode/
!.vscode/extensions.json
!.vscode/settings.json

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Temporary files
temp/
tmp/
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# Create LICENSE
@"
MIT License

Copyright (c) 2025 Bicep Tutorial

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@ | Out-File -FilePath "LICENSE" -Encoding UTF8

Write-Host "Creating setup script..." -ForegroundColor Yellow

# Create setup script (PowerShell version)
@"
# setup-environment.ps1
# PowerShell script to set up Bicep development environment

Write-Host "Setting up Bicep development environment..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    az --version | Out-Null
    Write-Host "✓ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "Azure CLI is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows" -ForegroundColor Yellow
    exit 1
}

# Install/upgrade Bicep CLI
Write-Host "Installing/upgrading Bicep CLI..." -ForegroundColor Yellow
az bicep install
az bicep upgrade

Write-Host "✓ Bicep CLI installed/upgraded" -ForegroundColor Green

# Check versions
Write-Host ""
Write-Host "Installed versions:" -ForegroundColor Cyan
az --version | Select-String -Pattern "(azure-cli|bicep)"

# Login check
Write-Host ""
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    az account show | Out-Null
    Write-Host "✓ Already logged in to Azure" -ForegroundColor Green
    az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" --output table
} catch {
    Write-Host "Please log in to Azure:" -ForegroundColor Yellow
    az login
}

Write-Host ""
Write-Host "Setup complete! You can now run the Bicep examples." -ForegroundColor Green
Write-Host ""
Write-Host "Recommended VS Code extensions:" -ForegroundColor Cyan
Write-Host "- Bicep" -ForegroundColor White
Write-Host "- Azure Account" -ForegroundColor White
Write-Host "- Azure Resources" -ForegroundColor White
"@ | Out-File -FilePath "scripts\setup-environment.ps1" -Encoding UTF8

Write-Host "Creating example 1: First Template..." -ForegroundColor Yellow

# Example 1: First Template
@"
// Simple storage account - your first Bicep template

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount001'
  location: 'East US'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
"@ | Out-File -FilePath "examples\01-first-template\storage.bicep" -Encoding UTF8

@"
{
  "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {}
}
"@ | Out-File -FilePath "examples\01-first-template\storage.parameters.json" -Encoding UTF8

# PowerShell deployment script
@"
# deploy.ps1
# PowerShell deployment script for first Bicep template

# Set variables
`$RESOURCE_GROUP = "rg-bicep-tutorial"
`$LOCATION = "East US"
`$DEPLOYMENT_NAME = "first-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "Deploying first Bicep template..." -ForegroundColor Green
Write-Host "Resource Group: `$RESOURCE_GROUP" -ForegroundColor Cyan
Write-Host "Location: `$LOCATION" -ForegroundColor Cyan
Write-Host "Deployment Name: `$DEPLOYMENT_NAME" -ForegroundColor Cyan

# Create resource group
Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create --name `$RESOURCE_GROUP --location "`$LOCATION"

# Deploy template
Write-Host "Deploying template..." -ForegroundColor Yellow
az deployment group create ``
  --resource-group `$RESOURCE_GROUP ``
  --template-file storage.bicep ``
  --name `$DEPLOYMENT_NAME

# Check deployment status
Write-Host "Deployment completed. Checking status..." -ForegroundColor Green
az deployment group show ``
  --resource-group `$RESOURCE_GROUP ``
  --name `$DEPLOYMENT_NAME ``
  --query "properties.{Status:provisioningState, Timestamp:timestamp}" ``
  --output table

Write-Host "Resources created:" -ForegroundColor Green
az resource list --resource-group `$RESOURCE_GROUP --output table
"@ | Out-File -FilePath "examples\01-first-template\deploy.ps1" -Encoding UTF8

@"
# Example 1: Your First Bicep Template

This example demonstrates the basics of creating and deploying a simple Bicep template.

## What You'll Learn
- Basic Bicep syntax
- Resource declaration
- Deploying your first template

## Files
- ``storage.bicep`` - The main template file
- ``storage.parameters.json`` - Parameter file (empty for this example)
- ``deploy.ps1`` - PowerShell deployment script

## How to Deploy

1. Make sure you're logged into Azure: ``az login``
2. Run the deployment script: ``.\deploy.ps1``

## What Gets Created
- One storage account with basic configuration

## Next Steps
Go to [Example 2](../02-parameters-variables/) to learn about parameters and variables.
"@ | Out-File -FilePath "examples\01-first-template\README.md" -Encoding UTF8

Write-Host ""
Write-Host "Repository structure created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Initialize git: git init" -ForegroundColor White
Write-Host "2. Add files: git add ." -ForegroundColor White
Write-Host "3. Commit: git commit -m 'Initial commit'" -ForegroundColor White
Write-Host "4. Create GitHub repository and add remote" -ForegroundColor White
Write-Host "5. Push: git push -u origin main" -ForegroundColor White
Write-Host ""
Write-Host "To get started with the tutorial:" -ForegroundColor Cyan
Write-Host "1. Run: .\scripts\setup-environment.ps1" -ForegroundColor White
Write-Host "2. Navigate to: examples\01-first-template" -ForegroundColor White
Write-Host "3. Run: .\deploy.ps1" -ForegroundColor White