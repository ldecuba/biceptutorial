# API Version Management Example

This example demonstrates best practices for managing API versions in Bicep templates.

## What You'll Learn

- **Centralized API version management** using variables
- **Environment-specific API version strategies**
- **Feature availability** based on API versions
- **API version documentation** and tracking
- **Automated API version checking**

## Files

- `api-version-demo.bicep` - Template demonstrating API version best practices
- `api-version-demo.parameters.json` - Parameter file for deployment

## How to Deploy

### Development with Stable APIs
```powershell
az deployment group create \
  --resource-group rg-api-demo \
  --template-file api-version-demo.bicep \
  --parameters @api-version-demo.parameters.json
```

### Testing with Preview APIs
```powershell
az deployment group create \
  --resource-group rg-api-demo \
  --template-file api-version-demo.bicep \
  --parameters @api-version-demo.parameters.json \
  --parameters usePreviewAPIs=true
```

## API Version Checking

Use the included script to check API versions:

```powershell
# Check all templates
.\scripts\check-api-versions.ps1

# Check with details
.\scripts\check-api-versions.ps1 -Detailed

# Check for latest available versions
.\scripts\check-api-versions.ps1 -ShowLatest
```

## Best Practices Demonstrated

1. ✅ **Centralized management** - All API versions in one place
2. ✅ **Documentation** - Metadata explains API version strategy
3. ✅ **Environment awareness** - Different strategies for different environments
4. ✅ **Feature tracking** - Comments explain API version requirements
5. ✅ **Automation ready** - Structure supports automated checking

## Next Steps

- Review the [API Version Management Guide](../../docs/04-api-version-management.md)
- Set up automated API version checking in your CI/CD pipeline
- Establish a regular review schedule for API versions
