/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

INSERT INTO [customer_table]
VALUES(1,'Joe Reegsblog','2024-01-01')
  
INSERT INTO project_table 
VALUES ('Amazing project','2024-01-01')

BEGIN TRY 
CREATE ROLE ADFReadWriteToTables
GRANT SELECT ON DATABASE::[$(DatabaseName)] to SynapseReadWriteToTables
GRANT INSERT ON DATABASE::[$(DatabaseName)] to SynapseReadWriteToTables
GRANT UPDATE ON DATABASE::[$(DatabaseName)] to SynapseReadWriteToTables
GRANT DELETE ON DATABASE::[$(DatabaseName)] to SynapseReadWriteToTables
GRANT CREATE TABLE TO SynapseReadWriteToTables
GRANT CREATE VIEW TO SynapseReadWriteToTables
GRANT ALTER ANY SCHEMA TO SynapseReadWriteToTables
END TRY

BEGIN CATCH
SELECT 'ALREADY THERE'
END CATCH
