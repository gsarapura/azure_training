using 'main.bicep'

param appServicePlanSku = {
  name: 'F1'
  tier: 'Free'
}

param sqlDatabaseSku = {
  name: 'Standard'
  tier: 'Standard'
}

param sqlServerAdministratorLogin = getSecret('b9ebcbb3-c2e4-47cb-9828-832a3ce1dff8', 
                                              'learn-24849841-909c-4b6c-bfa6-446fdd889d7a', 
                                              'TESTO4', 
                                              'sqlServerAdministratorLogin')

param sqlServerAdministratorPassword = getSecret('b9ebcbb3-c2e4-47cb-9828-832a3ce1dff8', 
                                                 'learn-24849841-909c-4b6c-bfa6-446fdd889d7a', 
                                                 'TESTO4', 
                                                 'sqlServerAdministratorPassword')
