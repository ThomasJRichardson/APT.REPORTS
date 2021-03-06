USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[spAPT_Get_PRB_Schedule_RetirementsOptions_Fraction_Final]    Script Date: 11/06/2013 15:19:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spAPT_Get_PRB_Schedule_RetirementsOptions_Fraction_Final]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spAPT_Get_PRB_Schedule_RetirementsOptions_Fraction_Final]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[spAPT_Get_PRB_Schedule_RetirementsOptions_Fraction_Final]    Script Date: 11/06/2013 15:19:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spAPT_Get_PRB_Schedule_RetirementsOptions_Fraction_Final]
(
	@MemberID INT
)
AS
BEGIN

DECLARE @TotalValue  DECIMAL(16,2),@Salary MONEY,@Yrs FLOAT

SELECT 
	@TotalValue= Sum(Inv.Units_Held * vw.OfferPrice)
FROM
	dbo.vw_UnitPrice_MaxDates vw
	INNER JOIN 
		(SELECT SUM(UnitsQuantity) AS Units_Held,SUM(AmountInvested) as Value,FundID  
		FROM dbo.InvestmentUnits IU
			INNER JOIN MemberBenefit MB ON IU.MemberbenefitID = MB.Id 				
		WHERE MB.MemberId = @MemberID
		GROUP BY FundID
		HAVING SUM(AmountInvested) > 0) AS Inv
		ON vw.FundID=Inv.FundID	 
		
SELECT TOP 1
	@Salary = ES1.Salary,
	--@Yrs=datediff(yyyy,TI.QualifyingServiceStartDate,TI.QualifyingServiceEndDate) 
	@Yrs = round(CAST(DATEDIFF(MONTH,TI.QualifyingServiceStartDate,TI.QualifyingServiceEndDate) AS FLOAT)/12,3)
FROM
	Member M
			
		LEFT OUTER JOIN (SELECT 
				MAX(EffectiveDate) as EffectiveDate,EmploymentID,MemberID
			 FROM 
				EmploymentSalaryHistory ES 
					INNER JOIN Employment E 
					ON ES.EmploymentID = E.ID
			 WHERE		
				SalaryType=201
			 GROUP BY 
				EmploymentID,MemberID) As EmpSalary 
				ON M.ID = EmpSalary.MemberID
				
		LEFT OUTER JOIN	EmploymentSalaryHistory ES1				
				ON EmpSalary.EmploymentID = ES1.EmploymentID
				AND DATEDIFF(D,EmpSalary.EffectiveDate, ES1.EffectiveDate)=0
		
		INNER JOIN dbo.MemberBenefit MB 
			ON 	M.ID = 	MB.MemberID
			
		INNER JOIN TransferIn TI
			ON MB.ID = TI.MemberBenefitID
				
WHERE 				
	M.ID=@MemberID
	
DECLARE @FractionFinalRem AS DECIMAL(14,2),
@ReducedAnnuity	AS DECIMAL(14,2)
SET	@FractionFinalRem=0.037500 * @Salary * @Yrs
SET @ReducedAnnuity = round(cast((@TotalValue-@FractionFinalRem) * 4.5/100 as float),2)

PRINT @Salary
PRINT @FractionFinalRem
PRINT @TotalValue
PRINT @TotalValue-@FractionFinalRem

IF (@FractionFinalRem >  @TotalValue)
BEGIN
	SET @FractionFinalRem = @TotalValue
	SET @ReducedAnnuity = 0.00
END

SELECT
	@TotalValue as SumTotalValue,
	@Salary as EmpSalary,
	@FractionFinalRem AS FractionFinalRem,
	@ReducedAnnuity AS ReducedAnnuity,
	@Yrs as Years
	
	
END




GO


