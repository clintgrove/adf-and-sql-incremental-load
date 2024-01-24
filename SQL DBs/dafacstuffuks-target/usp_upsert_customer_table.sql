CREATE PROCEDURE [dbo].[usp_upsert_customer_table] 
AS

BEGIN
	IF OBJECT_ID('tempdb..#tempcustomer', 'U') IS NOT NULL
		DROP TABLE #tempcustomer;

	CREATE TABLE #tempcustomer (
		PersonID INT,
		[Name] VARCHAR(255),
		LastModifytime datetime
	);

	INSERT INTO #tempcustomer
	SELECT DISTINCT * FROM staging.customer_table;

  MERGE customer_table AS target
  USING #tempcustomer AS source
  ON (target.PersonID = source.PersonID)
  WHEN MATCHED THEN
      UPDATE SET Name = source.Name,LastModifytime = source.LastModifytime
  WHEN NOT MATCHED THEN
      INSERT (PersonID, Name, LastModifytime)
      VALUES (source.PersonID, source.Name, source.LastModifytime);
END