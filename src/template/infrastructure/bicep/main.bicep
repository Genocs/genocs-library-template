@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The environment to deploy to.')
param env string


module customConnector 'modules/custom-connector.bicep' = {
  name: 'customConnector'
  params: {
    location: location
    env: env
  }
}

