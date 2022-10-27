/*
The database must have a MEMORY_OPTIMIZED_DATA filegroup
before the memory optimized object can be created.

The bucket count should be set to about two times the 
maximum expected number of distinct values in the 
index key, rounded up to the nearest power of two.
*/

CREATE TABLE [dbo].[Customer]
(
	[Id] INT NOT NULL PRIMARY KEY NONCLUSTERED,
	[Name] varchar(100),
	[Surname] varchar(100),
	[Occupation] varchar(100)
) 