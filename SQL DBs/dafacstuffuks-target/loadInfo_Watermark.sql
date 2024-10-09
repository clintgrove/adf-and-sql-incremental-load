CREATE TABLE [dbo].[loadInfo_Watermark](
	[rowNum] [int] IDENTITY(1,1) NOT NULL,
	[dateofload] [datetime] NOT NULL,
	[sourceinfo] [varchar](50) NOT NULL,
	[targetinfo] [varchar](50) NULL
) 