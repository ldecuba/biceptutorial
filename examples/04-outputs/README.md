# Example 4: Outputs

This example demonstrates how to return values from your Bicep deployments using outputs.

## What You'll Learn
- Different types of outputs (strings, objects, secure values)
- How to use outputs in other templates
- Best practices for output naming and descriptions

## Files
- `storage-with-outputs.bicep` - Template with comprehensive outputs
- `storage.parameters.json` - Parameter file
- `deploy.ps1` - Deployment script

## Key Concepts
- **Simple Outputs**: Return basic values like resource IDs and names
- **Secure Outputs**: Use `@secure()` decorator for sensitive data
- **Complex Outputs**: Return objects with multiple properties
- **Output Descriptions**: Document what each output provides

## How to Deploy

### PowerShell
```powershell
.\deploy.ps1
```

After deployment, view outputs:
```powershell
az deployment group show --resource-group rg-bicep-tutorial --name <deployment-name> --query "properties.outputs"
```

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
