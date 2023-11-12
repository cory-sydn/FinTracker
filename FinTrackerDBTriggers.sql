--Trigger For Update Dates (ModificationDate and ExecUpdateDate)

CREATE TRIGGER trg_AssetItem_Update ON [dbo].[AssetItems] 
AFTER UPDATE
AS
BEGIN
	UPDATE [dbo].[AssetItems] SET [ModificationDate] = GETDATE()
	WHERE [ID] IN (SELECT [ID] FROM inserted)
END
GO


CREATE TRIGGER trg_RevenueItem_Update ON [dbo].[RevenueItems] 
AFTER UPDATE
AS
BEGIN
	UPDATE [dbo].[RevenueItems] SET [ModificationDate] = GETDATE()
	WHERE [ID] IN (SELECT [ID] FROM inserted)
END
GO


CREATE TRIGGER trg_PaymentItem_Update ON [dbo].[PaymentItems] 
AFTER UPDATE
AS
BEGIN
	UPDATE [dbo].[PaymentItems] SET [ModificationDate] = GETDATE()
	WHERE [ID] IN (SELECT [ID] FROM inserted)
END
GO


-- Update Requests always come with an UpdaterUserID,
-- Trigger Decides to populate UpdatederExecID for the sake of keeping approval records
ALTER TRIGGER trg_Payment_Update ON [dbo].[Payments] 
AFTER UPDATE
AS
BEGIN

	IF ((Select UpdaterUserID FROM inserted) IS NOT NULL) AND ((SELECT IsExecutive FROM [Users] WHERE ID = (Select UpdaterUserID FROM inserted)) = 1)
	BEGIN		
		UPDATE [dbo].[Payments] 
		SET [ExecUpdateDate] = GETDATE()			
		WHERE [ID] = (SELECT [ID] FROM inserted)	
	END

	-- Nonexecutive users update when it is paid
	ELSE IF ((Select UpdaterUserID FROM inserted) IS NOT NULL) AND ((SELECT ApprovalStatus FROM Payments WHERE ID = (SELECT [ID] FROM inserted)) = 'Approved') AND ((SELECT PaymentStatus FROM Payments WHERE ID = (SELECT [ID] FROM inserted)) = 1)
	BEGIN
		UPDATE [dbo].[Payments] SET [PaidDate] = GETDATE()
		WHERE [ID] = (SELECT [ID] FROM inserted)
	END
END
GO


CREATE TRIGGER trg_User_Update ON [dbo].[Users] 
AFTER UPDATE
AS
BEGIN
	UPDATE [dbo].[Users] SET [ModificationDate] = GETDATE()
	WHERE [ID] IN (SELECT [ID] FROM inserted)
END
GO
