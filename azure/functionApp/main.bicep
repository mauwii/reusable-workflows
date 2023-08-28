targetScope = 'subscription'

@description('Will get pre- and suffixed to create names of the Resources.')
param applicationName string = 'FuncApp-Sample'

@description('Environment name used to suffix resource names.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Location for all resources.')
param location string = 'westeurope'

var resourceGroupName = '${applicationName}-${environment}-rg'
var hostingPlanName = 'asp-${applicationName}-${environment}'
var uniqueSiteName = '${applicationName}-${environment}-${shortRgId}'
var uniqueStorageAccountName = 'st${toLower(replace(substring(applicationName, 0, 8),'-',''))}${environment}${shortRgId}'
var shortRgId = substring(uniqueString(rg.id), 0, 3)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module functionApp 'modules/function.bicep' = {
  name: 'function'
  scope: rg
  params: {
    siteName: uniqueSiteName
    hostingPlanName: hostingPlanName
    storageAccountName: uniqueStorageAccountName
    location: location
  }
}
