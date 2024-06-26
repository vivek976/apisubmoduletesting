USE [piHIRE1.0_QA]
GO

ALTER PROCEDURE [dbo].[Sp_Candidate_List_Count]

	@SearchKey nvarchar(max),
	@Rating nvarchar(256),--Array
	@ApplicationStatus nvarchar(256),--Array
	@Gender nvarchar(256),--Array
	@Nationality nvarchar(max),--Array
	@CurrentLocation nvarchar(max),--Array
	@Recruiter nvarchar(max),
	@Source nvarchar(256),--Array,
	@MaritalStatus nvarchar(256),--Array,

	@Currency nvarchar(256),
	@Availability int,
	@MinAge int,
	@MaxAge int,
	
	@SalaryMinRange int,
	@SalaryMaxRange int

AS
begin
	SELECT Count(CandJobId)  as CandidateCount  FROM [dbo].[tmpAllCandidates] WHERE (1 = 1)

	and (@ApplicationStatus is null or CandProfStatus in (SELECT value from string_split(@ApplicationStatus, ','))) 
	and (@Gender is null or Gender in (SELECT value from string_split(@Gender, ','))) 
	and (@Source is null or SourceID in (SELECT value from string_split(@Source, ','))) 
	and (@CurrentLocation is null or CountryID in (SELECT value from string_split(@CurrentLocation, ','))) 
	and (@Recruiter is null or RecruiterId in (SELECT value from string_split(@Recruiter, ','))) 
	and (@Nationality is null or Nationality in (SELECT value from string_split(@Nationality, ','))) 
	and (@Availability is null or NoticePeriod <= @Availability) 
	and (@SearchKey is null or (CandProfID like '%'+@SearchKey+'%' 
	or ContactNo like '%'+@SearchKey+'%' or EmailID like '%'+@SearchKey+'%' or CandName like '%'+@SearchKey+'%' 
	or TagWords like '%'+@SearchKey+'%' 
	))
	and (@Currency is null or OpCurrency like '%'+@Currency+'%') 
	and (@SalaryMinRange is null or OpTakeHomePerMonth BETWEEN @SalaryMinRange and @SalaryMaxRange) 
	and (@MinAge is null or datediff(year, DOB, getdate()) BETWEEN @MinAge and @MaxAge) 
	and (@MaritalStatus is null or MaritalStatus in (SELECT value from string_split(@MaritalStatus, ','))) 
	and (@Rating is null or CAST(SelfRating AS integer) in (SELECT CAST(value as integer) from string_split(@Rating, ',')))
end


