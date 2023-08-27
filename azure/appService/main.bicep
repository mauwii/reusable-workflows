targetScope = 'subscription'

@description('Will get pre- and suffixed to create names of the Resources.')
param applicationName string = 'AppSvc-Sample'

@description('Environment name used to suffix resource names.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('The Azure region into which the resources should be deployed.')
param location string = 'westus3'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

@description('Indicates whether a CDN should be deployed.')
param deployCdn bool = true

var resourceGroupName = '${applicationName}-${environment}-rg'
var appServiceAppName = 'as-${applicationName}-${environment}'
var appServicePlanName = 'asp-${applicationName}-${environment}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module app 'modules/app.bicep' = {
  scope: rg
  name: 'myAppService'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

module cdn 'modules/cdn.bicep' = if (deployCdn) {
  scope: rg
  name: 'myCdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}

output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
