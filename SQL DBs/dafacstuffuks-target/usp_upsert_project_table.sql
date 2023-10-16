CREATE PROCEDURE [dbo].[usp_upsert_project_table]
AS

BEGIN
  MERGE project_table AS target
  USING staging.project_table AS source
  ON (target.Project = source.Project)
  WHEN MATCHED THEN
      UPDATE SET Creationtime = source.Creationtime
  WHEN NOT MATCHED THEN
      INSERT (Project, Creationtime)
      VALUES (source.Project, source.Creationtime);
END