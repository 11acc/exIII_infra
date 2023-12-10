
param c_RegistryName string
param c_RegistryImageName string
param c_RegistryImageVersion string
param loc string
param appservplan_Name string
param wapp_Name string

param DOCKER_REGISTRY_SERVER_URL string
param DOCKER_REGISTRY_SERVER_USERNAME string

@secure()
param DOCKER_REGISTRY_SERVER_PASSWORD string

module c_Registry './ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  name: c_RegistryName
  params: {
    name: c_RegistryName
    loc: loc
    acrAdminUserEnabled: true
  }
}

module servicePlan './ResourceModules-main/modules/web/serverfarm/main.bicep' = {
  name: appservplan_Name
  params: {
    name: appservplan_Name
    loc: loc
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

module webApp './ResourceModules-main/modules/web/site/main.bicep' = {
  name: wapp_Name
  params: {
    name: wapp_Name
    loc: loc
    kind: 'app'
    serverFarmResourceId: servicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${c_RegistryImageName}:${c_RegistryImageVersion}'
      appCommandLine: ''
    }
    
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://11a-containers.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: '11aContainers'
      DOCKER_REGISTRY_SERVER_PASSWORD: DOCKER_REGISTRY_SERVER_PASSWORD
    }
  }
}
