using './main.bicep'

param applicationName = 'sampleApp'
param environment = 'prod'
param location = 'westeurope'
param appServicePlanSkuName = 'F1'
param deployCdn = true
