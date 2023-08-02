# Management Group Hierarchy Template

Deploys the Management Group Hierarchy in an Azure tenant.

This template deploys the Management Group Hierarchy in an Azure tenant. It is used to create all child management groups under the tier-1 management group 'ABCD'.

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
environmentName | No       | The name of the environment. This must be dev, test, or prod.
solutionName   | No       | The unique name of the solution. This is used to ensure that resource names are unique.
appServicePlanInstanceCount | No       | The number of App Service plan instances.
appServicePlanSku | Yes      | The name and tier of the App Service plan SKU.
location       | No       | The Azure region into which the resources should be deployed.
sqlServerAdministratorLogin | Yes      | The administrator login username for Azure SQL DB
sqlServerAdministratorPassword | Yes      | The administrator login username for Azure SQL DB
sqlDatabaseSku | Yes      | The name and tier of the Azure SQL DB

### environmentName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The name of the environment. This must be dev, test, or prod.

- Default value: `dev`

- Allowed values: `dev`, `test`, `prod`

### solutionName

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The unique name of the solution. This is used to ensure that resource names are unique.

- Default value: `[format('toyhr{0}', uniqueString(resourceGroup().id))]`

### appServicePlanInstanceCount

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The number of App Service plan instances.

- Default value: `1`

### appServicePlanSku

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The name and tier of the App Service plan SKU.

### location

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The Azure region into which the resources should be deployed.

- Default value: `[resourceGroup().location]`

### sqlServerAdministratorLogin

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The administrator login username for Azure SQL DB

### sqlServerAdministratorPassword

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The administrator login username for Azure SQL DB

### sqlDatabaseSku

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The name and tier of the Azure SQL DB

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "main.json"
    },
    "parameters": {
        "environmentName": {
            "value": "dev"
        },
        "solutionName": {
            "value": "[format('toyhr{0}', uniqueString(resourceGroup().id))]"
        },
        "appServicePlanInstanceCount": {
            "value": 1
        },
        "appServicePlanSku": {
            "value": {}
        },
        "location": {
            "value": "[resourceGroup().location]"
        },
        "sqlServerAdministratorLogin": {
            "reference": {
                "keyVault": {
                    "id": ""
                },
                "secretName": ""
            }
        },
        "sqlServerAdministratorPassword": {
            "reference": {
                "keyVault": {
                    "id": ""
                },
                "secretName": ""
            }
        },
        "sqlDatabaseSku": {
            "value": {}
        }
    }
}
```

