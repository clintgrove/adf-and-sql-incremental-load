@secure()
param factstuff_linkedServTarget_connectionString string = ''

@secure()
param factstuff_linkedServSource_connectionString string = ''

@description('Location of the data factory.')
param location string = resourceGroup().location

@description('is this in test, dev or prod')
param az_environment string = 'test'
param gitConfigureLater bool = true
param gitRepoType string = 'FactoryVSTSConfiguration'
param gitAccountName string = ''
param gitProjectName string = ''
param gitRepositoryName string = ''
param gitCollaborationBranch string = 'main'
param gitRootFolder string = '/'

var dataFactoryName = 'adf-${uniqueString('adf-', resourceGroup().location, '-', resourceGroup().id)}-${resourceGroup().location}-${az_environment}'
var dataFactoryLinkedServiceNameSource = 'facstuff_DatabaseSOURCE'
var dataFactoryLinkedServiceNameTarget = 'facstuff_DatabaseTARGET'
var dataFactoryDataSetSourceName = 'dba_fac_a1_source'
var dataFactoryDataSetTargetName = 'dba_fac_a1_target'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: {
    tagName1: 'clint adf'
    tagName2: 'boss'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    repoConfiguration: (bool(gitConfigureLater) ? json('null') : json('{"type": "${gitRepoType}","accountName": "${gitAccountName}","repositoryName": "${gitRepositoryName}",${((gitRepoType == 'FactoryVSTSConfiguration') ? '"projectName": "${gitProjectName}",' : '')}"collaborationBranch": "${gitCollaborationBranch}","rootFolder": "${gitRootFolder}"}'))
  }
}

resource dataFactoryName_dataFactoryLinkedServiceNameTarget 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: dataFactory
  name: '${dataFactoryLinkedServiceNameTarget}'
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: factstuff_linkedServTarget_connectionString
      authenticationType: 'ManagedIdentity'
    }
  }
}

resource dataFactoryName_dataFactoryLinkedServiceNameSource 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' = {
  parent: dataFactory
  name: '${dataFactoryLinkedServiceNameSource}'
  properties: {
    annotations: []
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: factstuff_linkedServSource_connectionString
      authenticationType: 'ManagedIdentity'
    }
  }
}

resource dataFactoryName_dataFactoryDataSetTarget 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: '${dataFactoryDataSetTargetName}'
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceNameTarget
      type: 'LinkedServiceReference'
    }
    parameters: {
      schema_tgt: {
        type: 'string'
      }
      tblname_tgt: {
        type: 'string'
      }
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      schema: {
        value: '@dataset().schema_tgt'
        type: 'Expression'
      }
      table: {
        value: '@dataset().tblname_tgt'
        type: 'Expression'
      }
    }
  }
  dependsOn: [

    dataFactoryName_dataFactoryLinkedServiceNameTarget
  ]
}

resource dataFactoryName_dataFactoryDataSetSource 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: '${dataFactoryDataSetSourceName}'
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceNameSource
      type: 'LinkedServiceReference'
    }
    parameters: {
      schema: {
        type: 'string'
      }
      tblname: {
        type: 'string'
      }
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      schema: {
        value: '@dataset().schema'
        type: 'Expression'
      }
      table: {
        value: '@dataset().tblname'
        type: 'Expression'
      }
    }
  }
  dependsOn: [

    dataFactoryName_dataFactoryLinkedServiceNameSource
  ]
}

resource dataFactoryName_Incremental_load_unique_id_exists_in_both 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: 'Incremental load - unique id exists in both'
  properties: {
    activities: [
      {
        name: 'For Table From Source'
        description: 'Copy to staging and then do merge update'
        type: 'ForEach'
        dependsOn: []
        userProperties: []
        typeProperties: {
          items: {
            value: '@pipeline().parameters.tableList'
            type: 'Expression'
          }
          isSequential: false
          activities: [
            {
              name: 'Lookup Source watermark'
              type: 'Lookup'
              dependsOn: [
                {
                  activity: 'Lookup Target watermark'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                source: {
                  type: 'AzureSqlSource'
                  sqlReaderQuery: {
                    value: 'select MAX(@{item().WaterMark_Column}) as NewWatermarkvalue from @{item().TABLE_NAME}'
                    type: 'Expression'
                  }
                  queryTimeout: '02:00:00'
                  partitionOption: 'None'
                }
                dataset: {
                  referenceName: dataFactoryDataSetSourceName
                  type: 'DatasetReference'
                  parameters: {
                    schema: 'not set because use query is set to Query'
                    tblname: 'not set because use query is set to Query'
                  }
                }
              }
            }
            {
              name: 'Lookup Target watermark'
              type: 'Lookup'
              dependsOn: []
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                source: {
                  type: 'AzureSqlSource'
                  sqlReaderQuery: {
                    value: 'select * from [loadInfo_Watermark] where sourceinfo  =  \'@{item().TABLE_NAME}\''
                    type: 'Expression'
                  }
                  queryTimeout: '02:00:00'
                  partitionOption: 'None'
                }
                dataset: {
                  referenceName: dataFactoryDataSetTargetName
                  type: 'DatasetReference'
                  parameters: {
                    schema_tgt: 'not set because use query is set to Query'
                    tblname_tgt: 'not set because use query is set to Query'
                  }
                }
              }
            }
            {
              name: 'Copy data to staging'
              type: 'Copy'
              dependsOn: [
                {
                  activity: 'Lookup Source watermark'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                source: {
                  type: 'AzureSqlSource'
                  sqlReaderQuery: {
                    value: 'select * from @{item().TABLE_NAME} where @{item().WaterMark_Column} > \'@{activity(\'Lookup Target watermark\').output.firstRow.dateofload}\' and @{item().WaterMark_Column} <= \'@{activity(\'Lookup Source watermark\').output.firstRow.NewWatermarkvalue}\''
                    type: 'Expression'
                  }
                  queryTimeout: '02:00:00'
                  partitionOption: 'None'
                }
                sink: {
                  type: 'AzureSqlSink'
                  preCopyScript: {
                    value: 'TRUNCATE TABLE staging.@{item().TABLE_NAME}'
                    type: 'Expression'
                  }
                  writeBehavior: 'insert'
                  sqlWriterUseTableLock: false
                  disableMetricsCollection: false
                }
                enableStaging: false
                translator: {
                  type: 'TabularTranslator'
                  typeConversion: true
                  typeConversionSettings: {
                    allowDataTruncation: true
                    treatBooleanAsNumber: false
                  }
                }
              }
              inputs: [
                {
                  referenceName: dataFactoryDataSetSourceName
                  type: 'DatasetReference'
                  parameters: {
                    schema: 'not set - dynamic query used'
                    tblname: 'not set - dynamic query - see below'
                  }
                }
              ]
              outputs: [
                {
                  referenceName: dataFactoryDataSetTargetName
                  type: 'DatasetReference'
                  parameters: {
                    schema_tgt: 'staging'
                    tblname_tgt: {
                      value: '@item().TABLE_NAME'
                      type: 'Expression'
                    }
                  }
                }
              ]
            }
            {
              name: 'Sproc update watermark'
              type: 'SqlServerStoredProcedure'
              dependsOn: [
                {
                  activity: 'Copy data to staging'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                storedProcedureName: '[dbo].[usp_write_watermark]'
                storedProcedureParameters: {
                  LastModifiedtime: {
                    value: {
                      value: '@{activity(\'Lookup Source watermark\').output.firstRow.NewWatermarkvalue}'
                      type: 'Expression'
                    }
                    type: 'DateTime'
                  }
                  TableName: {
                    value: {
                      value: '@item().TABLE_NAME'
                      type: 'Expression'
                    }
                    type: 'String'
                  }
                }
              }
              linkedServiceName: {
                referenceName: dataFactoryLinkedServiceNameTarget
                type: 'LinkedServiceReference'
              }
            }
            {
              name: 'Sproc to copy new rows from staging'
              description: 'copy news rows only to main live table'
              type: 'SqlServerStoredProcedure'
              dependsOn: [
                {
                  activity: 'Sproc update watermark'
                  dependencyConditions: [
                    'Succeeded'
                  ]
                }
              ]
              policy: {
                timeout: '0.12:00:00'
                retry: 0
                retryIntervalInSeconds: 30
                secureOutput: false
                secureInput: false
              }
              userProperties: []
              typeProperties: {
                storedProcedureName: {
                  value: 'usp_upsert_@{item().TABLE_NAME}'
                  type: 'Expression'
                }
              }
              linkedServiceName: {
                referenceName: dataFactoryLinkedServiceNameTarget
                type: 'LinkedServiceReference'
              }
            }
          ]
        }
      }
    ]
    policy: {
      elapsedTimeMetric: {}
    }
    parameters: {
      tableList: {
        type: 'array'
        defaultValue: [
          {
            TABLE_NAME: 'customer_table'
            WaterMark_Column: 'LastModifytime'
            StoredProcedureNameForMergeOperation: 'usp_upsert_customer_table'
          }
          {
            TABLE_NAME: 'project_table'
            WaterMark_Column: 'Creationtime'
            StoredProcedureNameForMergeOperation: 'usp_upsert_project_table'
          }
        ]
      }
    }
    folder: {
      name: 'ETL Demo'
    }
    annotations: []
    lastPublishTime: '2023-10-09T08:17:57Z'
  }
  dependsOn: [

    dataFactoryName_dataFactoryDataSetSource
    dataFactoryName_dataFactoryDataSetTarget
  ]
}

output adfNameOutput string = dataFactoryName
output adfResourceId string = dataFactory.id