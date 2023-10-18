CREATE PROCEDURE [dbo].[usp_write_watermark] @LastModifiedtime datetime, @TableName varchar(50)
AS

BEGIN

UPDATE [dbo].[loadInfo_Watermark]
SET dateofload = @LastModifiedtime 
WHERE sourceinfo = @TableName

END