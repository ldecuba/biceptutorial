# Bicep Infrastructure as Code Tutorial

A comprehensive tutorial for learning Azure Bicep Infrastructure as Code from beginner to advanced level.

## 🚀 Getting Started

This tutorial will take you from complete beginner to confident Bicep developer. Each section builds upon the previous one, so it's recommended to follow them in order.

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
2. Navigate to examples/01-first-template
3. Update the parameters file with your values
4. Run the deployment script:
   
   ./deploy.sh
   

## 🧪 Testing

Validate all templates:

./scripts/validate-all.sh


## 🧹 Cleanup

Clean up all resources created during the tutorial:

./scripts/cleanup.sh


## 🤝 Contributing

Feel free to contribute improvements, additional examples, or corrections!

## 📖 Additional Resources

- [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Bicep Examples](https://github.com/Azure/bicep/tree/main/docs/examples)
- [Azure Quickstart Templates](https://azure.microsoft.com/en-us/resources/templates/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

