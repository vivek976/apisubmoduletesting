USE [piHIRE1.0_DEV]
GO
ALTER PROCEDURE [dbo].[sp_customScheduler_hireUsr_birthday]
	@currentDate datetime,
	@puIds nvarchar(max), @buIds nvarchar(max), @gndr nvarchar(1), @cntrIds nvarchar(max)
AS
BEGIN
	declare @curMnth int,@curDay int;
	set @curMnth = datepart(month, @currentDate);
	set @curDay = datepart(DAY, @currentDate);
	select distinct hireUsrs.ID from [piHIRE1.0_DEV].[dbo].[PI_HIRE_USERS] as hireUsrs 
					left outer join [gateway_uat].[dbo].[PI_APP_USERS] as gtAppUsr  on gtAppUsr.applicationId=2 and hireUsrs.UserID =gtAppUsr.ID
					left outer join [gateway_uat].[dbo].[tbl_param_employee_master] as gtEmpMstr on gtAppUsr.EmployID=gtEmpMstr.ID
					left outer join [gateway_uat].[dbo].[tbl_param_pu_office_locations] as gtOffLoc on gtEmpMstr.office_location_id= gtOffLoc.ID

	where hireUsrs.DOB is not null and datepart(month, hireUsrs.DOB)=@curMnth and datepart(DAY, hireUsrs.DOB)=@curDay /*CONVERT(date, gtEmpMstr.date_birth)*/ and 
	(len(@puIds)=0 or @puIds='0' or gtAppUsr.PUID in (select cast(value as int) val from string_split(@puIds,','))) and
	(len(@buIds)=0 or @buIds='0' or gtAppUsr.BUID in (select cast(value as int) val from string_split(@buIds,','))) and
	(len(@gndr)=0 or @gndr='A' or gtEmpMstr.Gender=@gndr) and
	 (len(@cntrIds)=0 or @cntrIds='0' or gtOffLoc.country in (select cast(value as int) val from string_split(@cntrIds,',')))
 END