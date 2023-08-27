targetScope = 'subscription'
@description('Will get pre- and suffixed to create names of the Resources.')
param applicationName string = 'FuncApp'

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
var hostingPlanName = 'plan-${applicationName}-${environment}'
var uniqueSiteName = '${applicationName}-${environment}-${uniqueString(rg.id)}'
var uniqueStorageAccountName = 'stg${toLower(substring(applicationName, 0, 5))}${uniqueString(rg.id)}'

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