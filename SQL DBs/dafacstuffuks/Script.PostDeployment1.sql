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

IF NOT EXISTS (SELECT * FROM [customer_table] WHERE PersonID = 1)
BEGIN
    INSERT INTO [customer_table] VALUES(1,'Joe Reegsblog','2024-01-01')
END


IF NOT EXISTS (SELECT * FROM project_table WHERE Project = 'Amazing project')
BEGIN
    INSERT INTO project_table VALUES ('Amazing project','2024-01-01')
END

BEGIN TRY 
CREATE ROLE ADFReadWriteToTables
GRANT SELECT ON DATABASE::[$(DatabaseName)] to ADFReadWriteToTables
GRANT INSERT ON DATABASE::[$(DatabaseName)] to ADFReadWriteToTables
GRANT UPDATE ON DATABASE::[$(DatabaseName)] to ADFReadWriteToTables
GRANT DELETE ON DATABASE::[$(DatabaseName)] to ADFReadWriteToTables
GRANT CREATE TABLE TO ADFReadWriteToTables
GRANT CREATE VIEW TO ADFReadWriteToTables
GRANT ALTER ANY SCHEMA TO ADFReadWriteToTables
END TRY

BEGIN CATCH
SELECT 'ALREADY THERE'
END CATCH
