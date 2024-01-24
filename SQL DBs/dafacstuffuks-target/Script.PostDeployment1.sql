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

INSERT INTO loadInfo_Watermark
VALUES ('1999-01-01', 'customer_table', 'customer_table'),
       ('1999-01-01', 'project_table', 'project_table');

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

BEGIN TRY 
GRANT EXECUTE TO ADFReadWriteToTables
END TRY

BEGIN CATCH
SELECT 'ALREADY THERE'
END CATCH