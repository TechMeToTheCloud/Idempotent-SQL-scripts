/* table */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[<table_name>]') AND type in (N'U'))
    DROP TABLE [dbo].[<table_name>]
GO

/* table constraint */
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[<constraint_name>]') AND type = 'D')
    ALTER TABLE [dbo].[<table_name>] DROP CONSTRAINT [<constraint_name>]
GO

/* function */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[<function_name>]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[<function_name>]
GO

/* stored procedure */
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[<stored proc name>]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[<stored proc name>]
GO

/* indices */
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[<table_name>]') AND name = N'<index name>')
	DROP INDEX [<Index_Name>] ON [dbo].[<table_name>] WITH ( ONLINE = OFF )
GO

/* queues */
IF  EXISTS (SELECT * FROM sys.service_queues WHERE name = N'<queue_name>')
	DROP QUEUE [dbo].[<queue_name>]
GO

/****** Object:  ServiceQueue [dbo].[General]    Script Date: 01/12/2015 14:30:17 ******/
IF NOT EXISTS(SELECT * FROM sys.service_queues WHERE [Name] = '<queue_name>')
	CREATE QUEUE [dbo].[<queue_name>] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)  ON [PRIMARY] 
GO

/* Primary Key */
DECLARE @SQL NVARCHAR(MAX)
DECLARE @PK_Name varchar(512)

SET @PK_NAME = ''
SELECT @PK_NAME = NAME FROM SYS.INDEXES WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[<table_name>]') AND IS_PRIMARY_KEY = 1

SET @SQL = 'ALTER TABLE [dbo].[<table_name>] DROP CONSTRAINT ' + @PK_NAME 
EXEC SP_EXECUTESQL @SQL

ALTER TABLE [dbo].[<table_name>] ADD CONSTRAINT [<PK_Name>] PRIMARY KEY CLUSTERED 
(
    Col1, Col2 etc
)

/* COLUMN */
IF NOT EXISTS(SELECT * FROM   INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = '<table_name>' AND COLUMN_NAME = '<column_name>') 
	ALTER TABLE <table_name> ADD <Column_Name> <Definition>


/* Default constraint on column*/

IF NOT EXISTS (SELECT name FROM SYS.DEFAULT_CONSTRAINTS WHERE PARENT_OBJECT_ID = OBJECT_ID('<table_name>') AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns WHERE NAME = N'<column_name>' AND object_id = OBJECT_ID(N'<table_name>')))
BEGIN
ALTER TABLE <table_name> ADD  DEFAULT ('value_default') FOR [Column_Name]
END

/* UNIQUE CONSTRAINT*/
DECLARE @SQL NVARCHAR(MAX)
DECLARE @AK_Name varchar(512)

SET @AK_NAME = ''
SELECT @AK_NAME = TC.Constraint_Name from information_schema.table_constraints TC
inner join information_schema.constraint_column_usage CC on TC.Constraint_Name = CC.Constraint_Name
where TC.constraint_type = 'Unique' and COLUMN_NAME = 'COLUMN_NAME'
order by TC.Constraint_Name


SET @SQL = 'ALTER TABLE [dbo].[TABLE_NAME] DROP CONSTRAINT ' + @AK_NAME 
EXEC SP_EXECUTESQL @SQL

ALTER TABLE [dbo].[TABLE_NAME] ADD CONSTRAINT CONSTRAINT_NAME UNIQUE (COLUMN_NAME)

