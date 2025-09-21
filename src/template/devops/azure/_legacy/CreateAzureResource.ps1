# Login to Azure using Azure cli
az login

# Variables
$resourceGroupName = "RG-Genocs"
$location = "westus"

# https://docs.microsoft.com/en-us/azure/developer/javascript/tutorial/tutorial-vscode-azure-cli-node/tutorial-vscode-azure-cli-node-03

az configure --defaults group=$resourceGroupName location=$location


az webapp up --name miotest.giovanni --logs --launch-browser