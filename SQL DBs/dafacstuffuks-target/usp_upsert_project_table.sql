CREATE PROCEDURE [dbo].[usp_upsert_project_table]
AS

BEGIN
	IF OBJECT_ID('tempdb..#tempproject', 'U') IS NOT NULL
		DROP TABLE #tempproject;

	CREATE TABLE #tempproject (
		-- Define the columns of the temporary table
		Project VARCHAR(255),
		Creationtime datetime
	);

	INSERT INTO #tempproject
	SELECT DISTINCT * FROM staging.project_table;


  MERGE project_table AS target
  USING #tempproject AS source
  ON (target.Project = source.Project)
  WHEN MATCHED THEN
      UPDATE SET Creationtime = source.Creationtime
  WHEN NOT MATCHED THEN
      INSERT (Project, Creationtime)
      VALUES (source.Project, source.Creationtime);
END