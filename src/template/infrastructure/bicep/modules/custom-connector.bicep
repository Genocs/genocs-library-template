// This is a Bicep file that defines an environment and a Log Analytics workspace

@description('The Azure region into which the resources should be deployed.')
param location string

@description('The enviroment postfix.')
param env string

resource customConnector 'Microsoft.Web/customApis@2016-06-01' = {
  location: location
  name: 'logic-sc-custom-connector-claim-${env}'
  properties: {
    apiType: 'Rest'
    backendService: {
      serviceUrl: 'htts://app-sc-reverse-proxy-${env}.azurewebsites.net'
    }
    description: 'Custom connector for BusinessLayer API'
    displayName: 'logic-sc-custom-connector-claim-${env}'

    swagger: openAPIDEfinition
  }
}

// Read Data from an external file
var openAPIDEfinition = loadJsonContent('../openapi-definition-file.json')
