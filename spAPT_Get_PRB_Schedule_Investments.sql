USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[spAPT_Get_PRB_Schedule_Investments]    Script Date: 01/06/2014 10:14:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spAPT_Get_PRB_Schedule_Investments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spAPT_Get_PRB_Schedule_Investments]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[spAPT_Get_PRB_Schedule_Investments]    Script Date: 01/06/2014 10:14:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spAPT_Get_PRB_Schedule_Investments]
(
	@MemberID INT
)
AS
BEGIN

DECLARE @Amt MONEY

SELECT 
	@Amt=SUM(Amount) 
FROM 
	Contribution C		
WHERE 
	MemberId=@MemberID


SELECT 
	FundId,
	CASE 
		WHEN CHARINDEX('(',[Description]) > 0 
			THEN LEFT([Description], CHARINDEX('(',[Description]) -1)
		ELSE 
			[Description]
		END AS FundDesc,		
		SIU.TotalContributions as TotalContributionsInv,
		@Amt as TotalContributions
		
FROM 
	MemberBenefit MB 	
		INNER JOIN Investmentunits I 
		ON MB.Id =  I.MemberBenefitId 
		
		INNER JOIN Fund FD 
		ON I.FundId=FD.Id  
		
		INNER JOIN
		(
			SELECT SUM(AmountInvested) as TotalContributions,MemberBenefitId
			FROM InvestmentUnits 
			GROUP BY MemberBenefitId
		) AS SIU ON MB.Id = SIU.MemberBenefitId 
		
WHERE 
	MB.MemberId=@MemberID
	
GROUP BY 
	Fundid,[Description],SIU.TotalContributions 
	
HAVING 
	SUM(AmountInvested) > 0
	
ORDER BY	
	FundId 
	
END	



GO


