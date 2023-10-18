CREATE TABLE [dbo].[loadInfo_Watermark](
	[rowNum] [int] IDENTITY(1,1) NOT NULL,
	[dateofload] [datetime] NULL,
	[sourceinfo] [varchar](50) NULL,
	[targetinfo] [varchar](50) NULL
) 