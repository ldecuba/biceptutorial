# Example 3: Dependencies

This example demonstrates how Bicep handles resource dependencies automatically and explicitly.

## What You'll Learn
- Implicit dependencies (automatic)
- Explicit dependencies (manual)
- Resource references
- Multi-resource deployments

## Files
- `web-app-with-storage.bicep` - Template with dependent resources
- `web-app.parameters.json` - Parameter file
- `deploy.ps1` - Deployment script

## Key Concepts
- **Implicit Dependencies**: When you reference one resource from another (e.g., `appServicePlan.id`), Bicep automatically creates the dependency
- **Resource References**: Use the symbolic name to reference properties of other resources
- **Deployment Order**: Bicep ensures resources are deployed in the correct order

## How to Deploy

### PowerShell
```powershell
.\deploy.ps1
```

### Bash
```bash
./deploy.sh
```

## What Gets Created
- App Service Plan
- Storage Account
- Web App (connected to both above resources)

## Next Steps
Go to [Example 4](../04-outputs/) to learn about outputs.
