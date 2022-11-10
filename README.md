# adf-and-sql-incremental-load
 Build a data factory and SQL database. The below code adds new rows to the Source DB and then you run the ADF pipeline to get Target to update or insert new rows
 
 
 /****** dba-fac-st-source
load new rows of data into the source tables and run the ADF cgr-dev-uks-adf-01
******/

--INSERT INTO project_table VALUES  ('project7','2020-09-03');
--INSERT INTO customer_table VALUES ('8','Jamie Matthews','2020-08-16');

--UPDATE customer_table SET LastModifytime = '2022-08-18' , [Name] = 'Paul Wilks' WHERE PersonID = 7

SELECT * FROM project_table
Select * from customer_table


/****** Now see the results of the update in the target - Script for dba-facstuff-target database  ******/
SELECT *
  FROM [dbo].[project_table]

  select * from customer_table

  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT *   FROM [dbo].[loadInfo_Watermark]


