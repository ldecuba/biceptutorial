# add-azure-powershell-docs.ps1
# Script to add Azure PowerShell deployment options to existing documentation

Write-Host "Adding Azure PowerShell deployment options to documentation..." -ForegroundColor Green

# Function to add Azure PowerShell examples after Azure CLI examples
function Add-AzurePowerShellExamples {
    param(
        [string]$FilePath,
        [string]$BackupPath = $null
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath" -ForegroundColor Yellow
        return
    }
    
    # Create backup if specified
    if ($BackupPath) {
        Copy-Item $FilePath $BackupPath
    }
    
    $content = Get-Content $FilePath -Raw
    
    # Add Azure PowerShell examples after Azure CLI examples
    $content = $content -replace '(```bash\r?\n# Login interactively\r?\naz login)', @"
`$1

# List available subscriptions
az account list --output table

# Set active subscription
az account set --subscription "Your Subscription Name"

# Verify current subscription
az account show --output table
```

#### Azure PowerShell
```powershell
# Login interactively
Connect-AzAccount

# List available subscriptions
Get-AzSubscription | Format-Table

# Set active subscription
Set-AzContext -SubscriptionName "Your Subscription Name"

# Verify current subscription
Get-AzContext | Format-Table
"@
    
    # Add PowerShell deployment examples
    $content = $content -replace '(```bash\r?\n# Create a resource group\r?\naz group create --name rg-bicep-tutorial --location "East US"\r?\n\r?\n# Deploy the template\r?\naz deployment group create \\\r?\n  --resource-group rg-bicep-tutorial \\\r?\n  --template-file storage\.bicep \\\r?\n  --name first-deployment\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Create a resource group
New-AzResourceGroup -Name "rg-bicep-tutorial" -Location "East US"

# Deploy the template
New-AzResourceGroupDeployment `
  -ResourceGroupName "rg-bicep-tutorial" `
  -TemplateFile "storage.bicep" `
  -Name "first-deployment"
```
"@

    # Add PowerShell verification examples
    $content = $content -replace '(```bash\r?\n# Check deployment status\r?\naz deployment group show \\\r?\n  --resource-group rg-bicep-tutorial \\\r?\n  --name first-deployment \\\r?\n  --query properties\.provisioningState\r?\n\r?\n# List resources in the group\r?\naz resource list --resource-group rg-bicep-tutorial --output table\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Check deployment status
Get-AzResourceGroupDeployment `
  -ResourceGroupName "rg-bicep-tutorial" `
  -Name "first-deployment" | 
  Select-Object ProvisioningState, Timestamp

# List resources in the group
Get-AzResource -ResourceGroupName "rg-bicep-tutorial" | Format-Table
```
"@

    # Add PowerShell template validation examples
    $content = $content -replace '(```bash\r?\n# Install/update Bicep\r?\naz bicep install\r?\naz bicep upgrade\r?\n\r?\n# Create resource group\r?\naz group create --name <n> --location <location>\r?\n\r?\n# Deploy template\r?\naz deployment group create \\\r?\n  --resource-group <rg-name> \\\r?\n  --template-file <template\.bicep> \\\r?\n  --parameters <params\.json>\r?\n\r?\n# Validate template\r?\naz deployment group validate \\\r?\n  --resource-group <rg-name> \\\r?\n  --template-file <template\.bicep>\r?\n\r?\n# Preview changes\r?\naz deployment group what-if \\\r?\n  --resource-group <rg-name> \\\r?\n  --template-file <template\.bicep>\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Install/update Bicep (via Azure CLI - recommended)
az bicep install
az bicep upgrade

# Create resource group
New-AzResourceGroup -Name <rg-name> -Location <location>

# Deploy template
New-AzResourceGroupDeployment `
  -ResourceGroupName <rg-name> `
  -TemplateFile <template.bicep> `
  -TemplateParameterFile <params.json>

# Validate template
Test-AzResourceGroupDeployment `
  -ResourceGroupName <rg-name> `
  -TemplateFile <template.bicep>

# Preview changes (what-if)
New-AzResourceGroupDeployment `
  -ResourceGroupName <rg-name> `
  -TemplateFile <template.bicep> `
  -WhatIf
```
"@

    # Save the updated content
    $content | Out-File -FilePath $FilePath -Encoding UTF8
    
    Write-Host "Updated: $FilePath" -ForegroundColor Green
}

# Function to add Azure PowerShell API version checking
function Add-AzurePowerShellAPIVersionExamples {
    param(
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath" -ForegroundColor Yellow
        return
    }
    
    $content = Get-Content $FilePath -Raw
    
    # Add Azure PowerShell API version examples after Azure CLI examples
    $content = $content -replace '(### 2\. Using PowerShell\r?\n\r?\n```powershell\r?\n# Get API versions for a resource type.*?\r?\n\r?\n`\$latestStable = `\$apiVersions \| Where-Object \{ `\$_ -notlike "\*preview\*" \} \| Select-Object -First 1\r?\n```)', @"
`$1

### 3. Using Azure PowerShell (Alternative)

```powershell
# Get API versions for a resource type
`$resourceProvider = Get-AzResourceProvider -ProviderNamespace Microsoft.Storage
`$storageAccountType = `$resourceProvider.ResourceTypes | Where-Object ResourceTypeName -eq "storageAccounts"
`$apiVersions = `$storageAccountType.ApiVersions

# Display all versions
`$apiVersions | Format-Table

# Get latest stable API version (non-preview)
`$latestStable = `$apiVersions | Where-Object { `$_ -notlike "*preview*" } | Select-Object -First 1
Write-Host "Latest stable API version: `$latestStable"

# Get all resource types and their latest API versions
Get-AzResourceProvider -ProviderNamespace Microsoft.Web | 
  ForEach-Object { 
    `$_.ResourceTypes | Select-Object ResourceTypeName, @{Name="LatestAPI";Expression={`$_.ApiVersions[0]}} 
  } | Format-Table
```
"@

    # Add deployment examples with Azure PowerShell
    $content = $content -replace '(```bash\r?\n# Development\r?\naz deployment group create \\\r?\n  --template-file main\.bicep \\\r?\n  --parameters @parameters\.dev\.json\r?\n\r?\n# Production  \r?\naz deployment group create \\\r?\n  --template-file main\.bicep \\\r?\n  --parameters @parameters\.prod\.json\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Development
New-AzResourceGroupDeployment `
  -ResourceGroupName `$resourceGroupName `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "parameters.dev.json"

# Production
New-AzResourceGroupDeployment `
  -ResourceGroupName `$resourceGroupName `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "parameters.prod.json"
```
"@

    # Add troubleshooting examples
    $content = $content -replace '(```bash\r?\n# Check supported versions\r?\naz provider show --namespace Microsoft\.Storage \\\r?\n  --query "resourceTypes\[.*?\]\.apiVersions\[0:5\]"\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Check supported versions
`$provider = Get-AzResourceProvider -ProviderNamespace Microsoft.Storage
`$storageType = `$provider.ResourceTypes | Where-Object ResourceTypeName -eq "storageAccounts"
`$storageType.ApiVersions | Select-Object -First 5
```
"@

    $content | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host "Updated API version examples in: $FilePath" -ForegroundColor Green
}

# Function to add Azure PowerShell deployment scripts to examples
function Add-AzurePowerShellDeploymentScripts {
    param(
        [string]$ExamplePath,
        [string]$TemplateName,
        [string]$ResourceGroupName = "rg-bicep-tutorial",
        [string]$ParameterFile = $null
    )
    
    if (-not (Test-Path $ExamplePath)) {
        Write-Host "Example path not found: $ExamplePath" -ForegroundColor Yellow
        return
    }
    
    $deployScriptPath = Join-Path $ExamplePath "deploy-azpowershell.ps1"
    
    $parameterSection = if ($ParameterFile) {
        "  -TemplateParameterFile `"$ParameterFile`""
    } else {
        ""
    }
    
    $scriptContent = @"
# deploy-azpowershell.ps1
# Azure PowerShell deployment script

param(
    [string]`$ResourceGroupName = "$ResourceGroupName",
    [string]`$Location = "East US"
)

`$DeploymentName = "$($TemplateName.Replace('.bicep', ''))-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "Deploying Bicep template using Azure PowerShell..." -ForegroundColor Green
Write-Host "Resource Group: `$ResourceGroupName" -ForegroundColor Cyan
Write-Host "Location: `$Location" -ForegroundColor Cyan
Write-Host "Deployment Name: `$DeploymentName" -ForegroundColor Cyan

# Ensure you're logged in to Azure
`$context = Get-AzContext
if (-not `$context) {
    Write-Host "Please login to Azure first..." -ForegroundColor Yellow
    Connect-AzAccount
}

# Create resource group if it doesn't exist
`$resourceGroup = Get-AzResourceGroup -Name `$ResourceGroupName -ErrorAction SilentlyContinue
if (-not `$resourceGroup) {
    Write-Host "Creating resource group..." -ForegroundColor Yellow
    New-AzResourceGroup -Name `$ResourceGroupName -Location `$Location
} else {
    Write-Host "Resource group already exists" -ForegroundColor Green
}

# Deploy template
Write-Host "Deploying template..." -ForegroundColor Yellow
try {
    `$deployment = New-AzResourceGroupDeployment ``
        -ResourceGroupName `$ResourceGroupName ``
        -TemplateFile "$TemplateName" ``$parameterSection ``
        -Name `$DeploymentName ``
        -Verbose

    if (`$deployment.ProvisioningState -eq "Succeeded") {
        Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
        
        # Show deployment details
        Write-Host "`nDeployment details:" -ForegroundColor Cyan
        `$deployment | Select-Object DeploymentName, ProvisioningState, Timestamp, Mode | Format-Table
        
        # Show outputs if any
        if (`$deployment.Outputs) {
            Write-Host "Deployment outputs:" -ForegroundColor Cyan
            `$deployment.Outputs | ConvertTo-Json -Depth 3
        }
        
        # Show created resources
        Write-Host "`nCreated resources:" -ForegroundColor Green
        Get-AzResource -ResourceGroupName `$ResourceGroupName | Format-Table Name, ResourceType, Location
    } else {
        Write-Host "Deployment failed with state: `$(`$deployment.ProvisioningState)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Deployment failed: `$(`$_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nDeployment completed successfully! 🎉" -ForegroundColor Green
"@
    
    $scriptContent | Out-File -FilePath $deployScriptPath -Encoding UTF8
    Write-Host "Created Azure PowerShell deployment script: $deployScriptPath" -ForegroundColor Green
}

# Function to update README files with Azure PowerShell examples
function Add-AzurePowerShellToReadme {
    param(
        [string]$ReadmePath
    )
    
    if (-not (Test-Path $ReadmePath)) {
        Write-Host "README not found: $ReadmePath" -ForegroundColor Yellow
        return
    }
    
    $content = Get-Content $ReadmePath -Raw
    
    # Add Azure PowerShell deployment instructions
    $content = $content -replace '(### PowerShell\r?\n```powershell\r?\n\\\.deploy\.ps1\r?\n```)', @"
### PowerShell (Azure CLI-based)
```powershell
.\deploy.ps1
```

### Azure PowerShell
```powershell
.\deploy-azpowershell.ps1
```
"@

    # Add Azure PowerShell validation examples
    $content = $content -replace '(```bash\r?\n# Validate template syntax\r?\naz bicep build --file main\.bicep\r?\n\r?\n# Validate deployment \(what-if\)\r?\naz deployment group what-if \\\r?\n  --resource-group myResourceGroup \\\r?\n  --template-file main\.bicep \\\r?\n  --parameters @parameters\.json\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Validate template syntax (via Azure CLI)
az bicep build --file main.bicep

# Validate deployment
Test-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "parameters.json"

# Preview changes (what-if)
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "parameters.json" `
  -WhatIf
```
"@

    $content | Out-File -FilePath $ReadmePath -Encoding UTF8
    Write-Host "Updated README with Azure PowerShell examples: $ReadmePath" -ForegroundColor Green
}

# Start updating documentation
Write-Host "Starting documentation updates..." -ForegroundColor Yellow

# Update main documentation files
Write-Host "Updating main documentation files..." -ForegroundColor Yellow

# Update getting started guide
if (Test-Path "docs\01-getting-started.md") {
    Add-AzurePowerShellExamples -FilePath "docs\01-getting-started.md"
}

# Update API version management guide
if (Test-Path "docs\04-api-version-management.md") {
    Add-AzurePowerShellAPIVersionExamples -FilePath "docs\04-api-version-management.md"
}

# Update troubleshooting guide
if (Test-Path "docs\troubleshooting.md") {
    $troubleshootingContent = Get-Content "docs\troubleshooting.md" -Raw
    
    # Add Azure PowerShell troubleshooting examples
    $troubleshootingContent = $troubleshootingContent -replace '(```bash\r?\n# Check current permissions\r?\naz role assignment list --assignee \$\(az account show --query user\.name -o tsv\)\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Check current permissions
Get-AzRoleAssignment | Where-Object { `$_.SignInName -eq (Get-AzContext).Account.Id } | Format-Table
```
"@

    $troubleshootingContent = $troubleshootingContent -replace '(```bash\r?\n# Register the resource provider\r?\naz provider register --namespace Microsoft\.Web\r?\n\r?\n# Check registration status\r?\naz provider show --namespace Microsoft\.Web --query "registrationState"\r?\n```)', @"
`$1

#### Azure PowerShell
```powershell
# Register the resource provider
Register-AzResourceProvider -ProviderNamespace Microsoft.Web

# Check registration status
Get-AzResourceProvider -ProviderNamespace Microsoft.Web | Select-Object RegistrationState
```
"@

    $troubleshootingContent | Out-File -FilePath "docs\troubleshooting.md" -Encoding UTF8
    Write-Host "Updated troubleshooting guide with Azure PowerShell examples" -ForegroundColor Green
}

# Update example deployment scripts
Write-Host "Adding Azure PowerShell deployment scripts to examples..." -ForegroundColor Yellow

# Add Azure PowerShell scripts to examples
if (Test-Path "examples\01-first-template") {
    Add-AzurePowerShellDeploymentScripts -ExamplePath "examples\01-first-template" -TemplateName "storage.bicep"
    Add-AzurePowerShellToReadme -ReadmePath "examples\01-first-template\README.md"
}

if (Test-Path "examples\02-parameters-variables") {
    Add-AzurePowerShellDeploymentScripts -ExamplePath "examples\02-parameters-variables" -TemplateName "storage-with-params.bicep" -ParameterFile "storage.parameters.json"
    Add-AzurePowerShellToReadme -ReadmePath "examples\02-parameters-variables\README.md"
}

if (Test-Path "examples\03-dependencies") {
    Add-AzurePowerShellDeploymentScripts -ExamplePath "examples\03-dependencies" -TemplateName "web-app-with-storage.bicep" -ParameterFile "web-app.parameters.json"
    Add-AzurePowerShellToReadme -ReadmePath "examples\03-dependencies\README.md"
}

if (Test-Path "examples\04-outputs") {
    Add-AzurePowerShellDeploymentScripts -ExamplePath "examples\04-outputs" -TemplateName "storage-with-outputs.bicep" -ParameterFile "storage.parameters.json"
    Add-AzurePowerShellToReadme -ReadmePath "examples\04-outputs\README.md"
}

if (Test-Path "examples\05-modules") {
    Add-AzurePowerShellDeploymentScripts -ExamplePath "examples\05-modules" -TemplateName "main.bicep" -ParameterFile "main.parameters.json"
    Add-AzurePowerShellToReadme -ReadmePath "examples\05-modules\README.md"
}

if (Test-Path "examples\api-version-example") {
    Add-AzurePowerShellDeploymentScripts -ExamplePath "examples\api-version-example" -TemplateName "api-version-demo.bicep" -ParameterFile "api-version-demo.parameters.json"
    Add-AzurePowerShellToReadme -ReadmePath "examples\api-version-example\README.md"
}

# Update main README
Write-Host "Updating main README..." -ForegroundColor Yellow
if (Test-Path "README.md") {
    $readmeContent = Get-Content "README.md" -Raw
    
    # Add Azure PowerShell note to quick start
    $readmeContent = $readmeContent -replace '(Run the deployment script:\r?\n   ```bash\r?\n   \\\.deploy\.sh\r?\n   ```)', @"
Run the deployment script:
   
   **Azure CLI (Bash):**
   ```bash
   ./deploy.sh
   ```
   
   **Azure CLI (PowerShell):**
   ```powershell
   .\deploy.ps1
   ```
   
   **Azure PowerShell:**
   ```powershell
   .\deploy-azpowershell.ps1
   ```
"@

    # Add Azure PowerShell to prerequisites
    $readmeContent = $readmeContent -replace '(### Prerequisites\r?\n\r?\n- Azure CLI installed\r?\n- Bicep CLI installed\r?\n- VS Code with Bicep extension \(recommended\)\r?\n- Azure subscription with appropriate permissions)', @"
### Prerequisites

**Choose one deployment method:**

**Option 1: Azure CLI (Recommended)**
- Azure CLI installed
- Bicep CLI installed (via Azure CLI)
- VS Code with Bicep extension (recommended)
- Azure subscription with appropriate permissions

**Option 2: Azure PowerShell**
- Azure PowerShell module installed
- Bicep CLI installed (via Azure CLI)
- VS Code with Bicep extension (recommended)
- Azure subscription with appropriate permissions
"@

    $readmeContent | Out-File -FilePath "README.md" -Encoding UTF8
    Write-Host "Updated main README with Azure PowerShell options" -ForegroundColor Green
}

# Create Azure PowerShell setup script
Write-Host "Creating Azure PowerShell setup script..." -ForegroundColor Yellow
if (Test-Path "scripts") {
    @"
# setup-azure-powershell.ps1
# Setup script for Azure PowerShell environment

Write-Host "Setting up Azure PowerShell environment for Bicep..." -ForegroundColor Green

# Check if Azure PowerShell is installed
try {
    Get-Module -Name Az -ListAvailable | Out-Null
    Write-Host "✓ Azure PowerShell module is installed" -ForegroundColor Green
} catch {
    Write-Host "Azure PowerShell module is not installed. Installing..." -ForegroundColor Yellow
    Install-Module -Name Az -AllowClobber -Force
    Write-Host "✓ Azure PowerShell module installed" -ForegroundColor Green
}

# Check if Azure CLI is installed (needed for Bicep)
try {
    az --version | Out-Null
    Write-Host "✓ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "Azure CLI is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Install/upgrade Bicep CLI (via Azure CLI)
Write-Host "Installing/upgrading Bicep CLI..." -ForegroundColor Yellow
az bicep install
az bicep upgrade
Write-Host "✓ Bicep CLI installed/upgraded" -ForegroundColor Green

# Check versions
Write-Host ""
Write-Host "Installed versions:" -ForegroundColor Cyan
Write-Host "Azure CLI: " -NoNewline
az --version | Select-String "azure-cli" | ForEach-Object { Write-Host `$_.ToString().Split()[1] -ForegroundColor White }
Write-Host "Bicep: " -NoNewline
az --version | Select-String "bicep" | ForEach-Object { Write-Host `$_.ToString().Split()[1] -ForegroundColor White }
Write-Host "Azure PowerShell: " -NoNewline
(Get-Module -Name Az -ListAvailable | Select-Object -First 1).Version | ForEach-Object { Write-Host `$_.ToString() -ForegroundColor White }

# Login check
Write-Host ""
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    `$context = Get-AzContext
    if (`$context) {
        Write-Host "✓ Already logged in to Azure PowerShell" -ForegroundColor Green
        Write-Host "Account: `$(`$context.Account.Id)" -ForegroundColor Cyan
        Write-Host "Subscription: `$(`$context.Subscription.Name)" -ForegroundColor Cyan
    } else {
        Write-Host "Please log in to Azure PowerShell:" -ForegroundColor Yellow
        Connect-AzAccount
    }
} catch {
    Write-Host "Please log in to Azure PowerShell:" -ForegroundColor Yellow
    Connect-AzAccount
}

Write-Host ""
Write-Host "Setup complete! You can now use Azure PowerShell for Bicep deployments." -ForegroundColor Green
Write-Host ""
Write-Host "Available deployment options:" -ForegroundColor Cyan
Write-Host "- Azure CLI (Bash): ./deploy.sh" -ForegroundColor White
Write-Host "- Azure CLI (PowerShell): .\deploy.ps1" -ForegroundColor White
Write-Host "- Azure PowerShell: .\deploy-azpowershell.ps1" -ForegroundColor White
"@ | Out-File -FilePath "scripts\setup-azure-powershell.ps1" -Encoding UTF8
    
    Write-Host "Created Azure PowerShell setup script: scripts\setup-azure-powershell.ps1" -ForegroundColor Green
}

Write-Host ""
Write-Host "Azure PowerShell documentation additions completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Added features:" -ForegroundColor Cyan
Write-Host "  ✅ Azure PowerShell examples added to all documentation" -ForegroundColor Green
Write-Host "  ✅ Azure PowerShell deployment scripts for all examples" -ForegroundColor Green
Write-Host "  ✅ Updated README files with PowerShell options" -ForegroundColor Green
Write-Host "  ✅ Azure PowerShell setup script created" -ForegroundColor Green
Write-Host "  ✅ API version management with PowerShell examples" -ForegroundColor Green
Write-Host ""
Write-Host "Your tutorial now supports both Azure CLI and Azure PowerShell! 🎉" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  Setup: .\scripts\setup-azure-powershell.ps1" -ForegroundColor White
Write-Host "  Deploy: .\examples\01-first-template\deploy-azpowershell.ps1" -ForegroundColor White