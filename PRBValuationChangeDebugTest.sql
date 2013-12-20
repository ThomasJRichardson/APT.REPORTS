use APT2012
go


exec [dbo].[spAPT_Get_PRB_Schedule_RetirementsOptions_Fraction_Final] @MemberID = 17157565
exec [dbo].[spTomR] @MemberID = 17157565

exec [dbo].[spAPT_Get_PRB_Schedule_RetirementsOptions_Fraction_Final] @MemberID = 88589521
exec [dbo].[spTomR] @MemberID = 88589521

/*
declare @MemberID integer
select @MemberID = 17157565
select @MemberID = 88589521

	select		count(1),max(DH.EffDate),min(DH.EffDate)
	from		dbo.Member M
	inner join	dbo.Employment E
		on		E.MemberId = M.ID
	inner join	dbo.DecimalHistory DH
		on		DH.ParentUID = E.ID
		and		DH.CATID = 1300
	where	M.ID = @MemberID

	select	PUD.PRSAEmployer
	from		dbo.Member M
	inner join	dbo.Employment E
		on		E.MemberId = M.ID
	inner join	dbo.EmploymentUserData PUD
		on		PUD.EmploymentID = E.ID
	where	M.ID = @MEmberID
	*/