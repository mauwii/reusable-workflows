using './main.bicep'

param applicationName = 'sampleApp'
param environment = 'dev'
param location = 'westeurope'
param appServicePlanSkuName = 'F1'
param deployCdn = false
