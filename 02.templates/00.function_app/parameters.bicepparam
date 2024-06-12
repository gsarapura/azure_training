using 'main.bicep'

param azureWebStorageQ3Restinsite = getSecret('ac8acb17-0021-4aed-b377-119bc6c7494c', 
                                              'demoResourceGroup', 
                                              'q3testdeployment', 
                                              'AzureWebJobsStorage')

param webContentQ3Rentinsite = getSecret('ac8acb17-0021-4aed-b377-119bc6c7494c', 
                                                 'demoResourceGroup', 
                                                 'q3testdeployment', 
                                                 'WebsiteContentAzureFileConnectionString')
