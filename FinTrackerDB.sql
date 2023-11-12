IF ('FinTrackDB' NOT IN (SELECT name FROM sys.databases))
CREATE DATABASE FinTrackDB
GO

USE FinTrackDB
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [dbo].[Users] (
	[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[FullName] [NVARCHAR](50) NOT NULL,
	[Password] [NVARCHAR](30) NOT NULL,
	[Title] [NVARCHAR](30) NULL,
	[Department] [NVARCHAR](30) NULL,
	[Education] [NVARCHAR](50) NULL,
	[Adress] [NVARCHAR](100) NULL,
	[PhoneNum] [NVARCHAR](15) NULL,
	[StartDate] DATE,
	[EndDate] Date,
	[IsExecutive] BIT NOT NULL DEFAULT (0),
	[IsActive] BIT NOT NULL DEFAULT (1),
	[InsertDate] DATETIME DEFAULT(GETDATE()),
	[ModificationDate] DATETIME
)
ALTER TABLE [dbo].[Users] ADD CONSTRAINT [CH_Users_EndDate] CHECK ([EndDate] >= [StartDate])
ALTER TABLE [dbo].[Users] ADD CONSTRAINT [CH_Users_ModificationDate] CHECK ([ModificationDate] >= [InsertDate])
GO


CREATE TABLE [dbo].[AssetItems](
	[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[AssetName] [NVARCHAR](100) NULL,
	[CurrencyCode] [NVARCHAR](3),
	[AssetType] [NVARCHAR](20) NULL,
	[CreatedByUserID] [INT] NULL,
	[InsertDate] DATETIME DEFAULT(GETDATE()),
	[ModificationDate] DATETIME,
	[Visibility] BIT DEFAULT(1)

	CONSTRAINT [FK_AssetItems_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Users] ([ID])
)
GO

CREATE TABLE [dbo].[RevenueItems](
	[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[RevenueName] [NVARCHAR](100) NULL,
	[CurrencyCode] [NVARCHAR](3),
	[CreatedByUserID] [INT] NULL,
	[InsertDate] DATETIME DEFAULT(GETDATE()),
	[ModificationDate] DATETIME,
	[Visibility] BIT DEFAULT(1),

	CONSTRAINT [FK_RevenueItems_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Users] ([ID])
)
GO

CREATE TABLE [dbo].[PaymentItems](
	[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[PaymentName] [NVARCHAR](100) NULL,
	[CurrencyCode] [NVARCHAR](3),
	[CreatedByUserID] [INT] NULL,
	[InsertDate] DATETIME DEFAULT(GETDATE()),
	[ModificationDate] DATETIME,
	[Visibility] BIT DEFAULT(1)

	CONSTRAINT [FK_PaymentItems_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Users] ([ID])
)
GO

CREATE TABLE [dbo].[Assets](
	[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,	
	[AssetItemID] [INT] Not NULL,	
	[CurrencyValue] DECIMAL(18,3) NOT NULL DEFAULT (1),
	[Amount] [DECIMAL](18,2) NOT NULL,
	[AmountLocal] [DECIMAL](18,2) NOT NULL,
	[CreatedByUserID] [INT] NULL,
	[InsertDate] DATETIME DEFAULT(GETDATE()),
	[Current] BIT DEFAULT(1),

	CONSTRAINT [FK_Assets_AssetClass] FOREIGN KEY ([AssetItemID]) REFERENCES [dbo].[AssetItems] ([ID]),
	CONSTRAINT [FK_Assets_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Users] ([ID]),
)
GO

CREATE TABLE [dbo].[Revenues](
	[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,	
	[RevenueItemID] [INT] Not NULL,	
	[CurrencyValue] DECIMAL(18,3) NOT NULL DEFAULT (1),
	[Amount] [DECIMAL](18,2) NOT NULL,
	[AmountLocal] [DECIMAL](18,2) NOT NULL,
	[CreatedByUserID] [INT] NULL,
	[InsertDate] DATETIME DEFAULT(GETDATE()),
	[Current] BIT DEFAULT(1),
	[ReceiveStatus ] [NVARCHAR](20) NULL,

	CONSTRAINT [FK_Revenues_RevenueItems] FOREIGN KEY ([RevenueItemID]) REFERENCES [dbo].[RevenueItems] ([ID]),
	CONSTRAINT [FK_Revenues_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Users] ([ID]),
)
GO

CREATE TABLE [dbo].[Payments](
	[ID] [INT] IDENTITY(1,1) NOT NULL PRIMARY KEY,	
	[PaymentItemID] [INT] Not NULL,	
	[CurrencyValue] DECIMAL(18,3) NOT NULL DEFAULT (1),
	[Amount] [DECIMAL](18,2) NOT NULL,
	[AmountLocal] [DECIMAL](18,2) NOT NULL,
	[ApprovalStatus] [NVARCHAR](20) NULL,
	[PaymentMethod] [NVARCHAR](20) NULL,
	[PartialPaymentAmt] [DECIMAL](18,2) NULL,
	[TotalPaymentAmt] [DECIMAL](18,2) NULL,
	[CreatedByUserID] [INT] NULL,
	[UpdaterUserID] [INT] NULL,
	[UpdatederExecID] [INT] NULL,
	[ExecUpdateDate] DATETIME,
	[InsertDate] DATETIME DEFAULT(GETDATE()),
	[PaymentStatus] BIT DEFAULT(0),
	[PaidDate] DATETIME NULL,
	[Current] BIT DEFAULT(1),

	CONSTRAINT [FK_Payment_RevenueItems] FOREIGN KEY ([PaymentItemID]) REFERENCES [dbo].[PaymentItems] ([ID]),
	CONSTRAINT [FK_PaymentUser_Users] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Users] ([ID]),
	CONSTRAINT [FK_PaymentExec_Users] FOREIGN KEY ([UpdatederExecID]) REFERENCES [dbo].[Users] ([ID]),
)
GO

ALTER TABLE [dbo].[Payments] ADD CONSTRAINT [CH_Payments_ExecUpdateTime] CHECK ([ExecUpdateDate] >= [InsertDate])
ALTER TABLE [dbo].[Payments] ADD CONSTRAINT [CH_Payments_PartialAmt] CHECK (([Amount] * [CurrencyValue])  >= [PartialPaymentAmt])
GO