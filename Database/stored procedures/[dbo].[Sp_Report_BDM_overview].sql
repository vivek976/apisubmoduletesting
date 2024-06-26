
CREATE OR ALTER PROCEDURE [dbo].[Sp_Report_BDM_overview]
	@FromDate datetime,
	@Todate datetime,
	@puId int,
	@StatusCode nvarchar(10),
	@userId int,
	@userType int,
	@bdmId int
AS
begin 

	SET NOCOUNT ON;  

	--CREATE TABLE #BDMResults (JobId int,CandProfId int,CandName varchar(150),
	--CandProfilePhoto varchar(150),JoiningDate datetime,StatusCode nvarchar(10),ActivityDate Datetime,
	--JobTitle varchar(500),JobStatus varchar(150),ClientID int,ClientName varchar(150),BroughtBy int,
	--BroughtByName varchar(150),BroughtbyProfilePhoto varchar(150),RecruiterId int,
	--RecruiterName varchar(150),RecruiterProfilePhoto varchar(150),CurrentStatusId int,
	--CurrentStatusName varchar(50),UpdateStatusId int,UpdateStatuName varchar(150),CreatedDate datetime,AgeBetweenDates varchar(100))	

	IF(@userType != 3)
	BEGIN

		-- ;WITH CandCTE AS
		--( 
		--	Select 
		--		statusHistroy.JobId,statusHistroy.CandProfId,statusHistroy.CandName,
		--		(select Top 1 FileName from [dbo].[PH_CANDIDATE_DOCS] as canDoc where statusHistroy.jobId = canDoc.joid and statusHistroy.CandProfId = canDoc.CandProfId and canDoc.DocType = 'Profile Photo' and Status = 1 order by canDoc.CreatedDate) as CandProfilePhoto,
		--		(select Top 1 JoiningDate from [dbo].[PH_JOB_OFFER_LETTERS] as OffLet where statusHistroy.jobId = OffLet.joid 
		--		and statusHistroy.CandProfId = OffLet.CandProfId and Status = 1 order by OffLet.CreatedDate) as JoiningDate,
		--		statusHistroy.StatusCode,statusHistroy.ActivityDate,
		--		statusHistroy.JobTitle,JobStats.Title as JobStatus,statusHistroy.ClientID,statusHistroy.ClientName,
		--		statusHistroy.BroughtBy,CONCAT(BdmUser.FirstName,' ',BdmUser.LastName) as BroughtByName,
		--		(BdmUser.ProfilePhoto) as BroughtbyProfilePhoto,
		--		statusHistroy.RecruiterId,CONCAT(RecUser.FirstName,' ',RecUser.LastName) as RecruiterName,
		--		(RecUser.ProfilePhoto) as RecruiterProfilePhoto,
		--		statusHistroy.CurrentStatusId,CurrentStatus.Title as CurrentStatusName,
		--		statusHistroy.UpdateStatusId,UpdateStatus.Title as UpdateStatuName,
		--		statusHistroy.CreatedDate,
		--		CAST(DATEDIFF(DAY, statusHistroy.CreatedDate, GETDATE()) AS VARCHAR(10)) AS AgeBetweenDates,
		--		ROW_NUMBER() OVER (PARTITION BY statusHistroy.CandProfId,statusHistroy.StatusCode ORDER BY statusHistroy.CandProfId DESC) AS RowNumber
		--	from 
		--		dbo.vwJobCandidateStatusHistory as statusHistroy
		--		join dbo.PI_HIRE_USERS as RecUser on statusHistroy.RecruiterId = RecUser.Id
		--		join dbo.PI_HIRE_USERS as BdmUser on statusHistroy.BroughtBy = BdmUser.Id
		--		left join dbo.PH_CAND_STATUS_S as CurrentStatus on statusHistroy.CurrentStatusId = CurrentStatus.id
		--		join dbo.PH_CAND_STATUS_S as UpdateStatus on statusHistroy.UpdateStatusId = UpdateStatus.id
		--		join dbo.PH_JOB_STATUS_S as JobStats on statusHistroy.JobOpeningStatus = JobStats.id
		--	where 
		--		statusHistroy.ActivityDate BETWEEN @FromDate and @ToDate and statusHistroy.StatusCode = @StatusCode
		--		   and (@puId is null or statusHistroy.PUID = @puId)
		--		   and (@bdmId is null or statusHistroy.BroughtBy = @bdmId)
		--)
		----INSERT INTO #BDMResults
		--SELECT 
		--	JobId,CandProfId,CandName,CandProfilePhoto,JoiningDate,StatusCode,ActivityDate,
		--	JobTitle,JobStatus,ClientID,ClientName,BroughtBy,BroughtByName,BroughtbyProfilePhoto,
		--	RecruiterId, RecruiterName,RecruiterProfilePhoto,
		--	CurrentStatusId,CurrentStatusName,UpdateStatusId,UpdateStatuName,CreatedDate,AgeBetweenDates  
		--FROM 
		--	CandCTE 
		--WHERE RowNumber = 1
		;WITH CandCTE AS (select * from
		( 
			Select 
				statusHistroy.JobId,statusHistroy.CandProfId,statusHistroy.CandName,
				statusHistroy.StatusCode,statusHistroy.ActivityDate,
				statusHistroy.JobTitle,statusHistroy.ClientID,statusHistroy.ClientName,
				statusHistroy.BroughtBy,				
				statusHistroy.RecruiterId,
				statusHistroy.CurrentStatusId,
				statusHistroy.UpdateStatusId,
				statusHistroy.CreatedDate,
				statusHistroy.JobOpeningStatus,
				(ROW_NUMBER() OVER (PARTITION BY statusHistroy.CandProfId,statusHistroy.StatusCode ORDER BY statusHistroy.CandProfId DESC)) AS RowNumber
			from 
				dbo.vwJobCandidateStatusHistory as statusHistroy				
			where 
				statusHistroy.ActivityDate BETWEEN @FromDate and @ToDate and statusHistroy.StatusCode = @StatusCode
				and (@puId is null or statusHistroy.PUID = @puId)
				and (@bdmId is null or statusHistroy.BroughtBy = @bdmId)
		) a where RowNumber =1)
		--INSERT INTO #BDMResults
		SELECT 
			statusHistroy.JobId, statusHistroy.CandProfId, statusHistroy.CandName,
			(select Top 1 FileName from [dbo].[PH_CANDIDATE_DOCS] as canDoc where statusHistroy.jobId = canDoc.joid and statusHistroy.CandProfId = canDoc.CandProfId and canDoc.DocType = 'Profile Photo' and Status = 1 order by canDoc.CreatedDate) as CandProfilePhoto,
			(select Top 1 JoiningDate from [dbo].[PH_JOB_OFFER_LETTERS] as OffLet where statusHistroy.jobId = OffLet.joid and statusHistroy.CandProfId = OffLet.CandProfId and Status = 1 order by OffLet.CreatedDate) as JoiningDate,
			statusHistroy.StatusCode, statusHistroy.ActivityDate,
			statusHistroy.JobTitle,
			JobStats.Title as JobStatus,
			statusHistroy.ClientID, statusHistroy.ClientName, 
			statusHistroy.BroughtBy, CONCAT(BdmUser.FirstName,' ',BdmUser.LastName) as BroughtByName,(BdmUser.ProfilePhoto) as BroughtbyProfilePhoto,
			statusHistroy.RecruiterId, CONCAT(RecUser.FirstName,' ',RecUser.LastName) as RecruiterName,(RecUser.ProfilePhoto) as RecruiterProfilePhoto,
			statusHistroy.CurrentStatusId, CurrentStatus.Title as CurrentStatusName, 
			statusHistroy.UpdateStatusId, UpdateStatus.Title as UpdateStatuName,
			statusHistroy.CreatedDate, CAST(DATEDIFF(DAY, statusHistroy.CreatedDate, GETDATE()) AS VARCHAR(10)) AS AgeBetweenDates

		FROM 
			CandCTE statusHistroy
			join dbo.PI_HIRE_USERS as RecUser on statusHistroy.RecruiterId = RecUser.Id
			join dbo.PI_HIRE_USERS as BdmUser on statusHistroy.BroughtBy = BdmUser.Id
			left join dbo.PH_CAND_STATUS_S as CurrentStatus on statusHistroy.CurrentStatusId = CurrentStatus.id
			join dbo.PH_CAND_STATUS_S as UpdateStatus on statusHistroy.UpdateStatusId = UpdateStatus.id
			join dbo.PH_JOB_STATUS_S as JobStats on statusHistroy.JobOpeningStatus = JobStats.id

	END
	ELSE 
	BEGIN 

	--	 ;WITH CandCTE AS
	--	( 
	--	Select statusHistroy.JobId,statusHistroy.CandProfId,statusHistroy.CandName,
	--	(select Top 1 FileName from [dbo].[PH_CANDIDATE_DOCS] as canDoc where statusHistroy.jobId = canDoc.joid 
	--	and statusHistroy.CandProfId = canDoc.CandProfId and canDoc.DocType = 'Profile Photo' and Status = 1 order by canDoc.CreatedDate) as CandProfilePhoto,
	--	(select Top 1 JoiningDate from [dbo].[PH_JOB_OFFER_LETTERS] as OffLet where statusHistroy.jobId = OffLet.joid 
	--	and statusHistroy.CandProfId = OffLet.CandProfId and Status = 1 order by OffLet.CreatedDate) as JoiningDate,
	--	statusHistroy.StatusCode,statusHistroy.ActivityDate,
	--	statusHistroy.JobTitle,JobStats.Title as JobStatus,statusHistroy.ClientID,statusHistroy.ClientName,
	--	statusHistroy.BroughtBy,CONCAT(BdmUser.FirstName,' ',BdmUser.LastName) as BroughtByName,
	--	(BdmUser.ProfilePhoto) as BroughtbyProfilePhoto,
	--	statusHistroy.RecruiterId,CONCAT(RecUser.FirstName,' ',RecUser.LastName) as RecruiterName,
	--	(RecUser.ProfilePhoto) as RecruiterProfilePhoto,
	--	statusHistroy.CurrentStatusId,CurrentStatus.Title as CurrentStatusName,
	--	statusHistroy.UpdateStatusId,UpdateStatus.Title as UpdateStatuName,
	--	statusHistroy.CreatedDate,
	--	CAST(DATEDIFF(DAY, statusHistroy.CreatedDate, GETDATE()) AS VARCHAR(10)) AS AgeBetweenDates,
	--	ROW_NUMBER() OVER (PARTITION BY statusHistroy.CandProfId,statusHistroy.StatusCode ORDER BY statusHistroy.CandProfId DESC) AS RowNumber
	--	 from dbo.vwJobCandidateStatusHistory as statusHistroy
	--		  join dbo.PI_HIRE_USERS as RecUser on statusHistroy.RecruiterId = RecUser.Id
	--		  join dbo.PI_HIRE_USERS as BdmUser on statusHistroy.BroughtBy = BdmUser.Id
	--		  left join dbo.PH_CAND_STATUS_S as CurrentStatus on statusHistroy.CurrentStatusId = CurrentStatus.id
	--		  join dbo.PH_CAND_STATUS_S as UpdateStatus on statusHistroy.UpdateStatusId = UpdateStatus.id
	--		  join dbo.PH_JOB_STATUS_S as JobStats on statusHistroy.JobOpeningStatus = JobStats.id
	--	WHERE statusHistroy.ActivityDate BETWEEN @FromDate and @ToDate and statusHistroy.StatusCode = @StatusCode
	--	   and (@puId is null or statusHistroy.PUID = @puId)
	--	   and statusHistroy.BroughtBy =  @userId 
	--	)

	----INSERT INTO #BDMResults
	--SELECT JobId,CandProfId,CandName,CandProfilePhoto,JoiningDate,StatusCode,ActivityDate,
	--JobTitle,JobStatus,ClientID,ClientName,BroughtBy,BroughtByName,BroughtbyProfilePhoto,
	--RecruiterId, RecruiterName,RecruiterProfilePhoto,CurrentStatusId,CurrentStatusName,
	--UpdateStatusId,UpdateStatuName,CreatedDate,AgeBetweenDates FROM CandCTE WHERE RowNumber = 1

		;WITH CandCTE AS  (select * from ( 
			Select 
				statusHistroy.JobId,statusHistroy.CandProfId,statusHistroy.CandName,
				statusHistroy.StatusCode, statusHistroy.ActivityDate,
				statusHistroy.JobTitle, statusHistroy.ClientID, statusHistroy.ClientName,
				statusHistroy.BroughtBy,
				statusHistroy.RecruiterId,
				statusHistroy.CurrentStatusId,
				statusHistroy.UpdateStatusId,
				statusHistroy.CreatedDate,
				statusHistroy.JobOpeningStatus,
				(ROW_NUMBER() OVER (PARTITION BY statusHistroy.CandProfId,statusHistroy.StatusCode ORDER BY statusHistroy.CandProfId DESC)) as RowNumber
				
			from 
				dbo.vwJobCandidateStatusHistory as statusHistroy
			WHERE 
				statusHistroy.ActivityDate BETWEEN @FromDate and @ToDate and statusHistroy.StatusCode = @StatusCode
				and (@puId is null or statusHistroy.PUID = @puId)
				and statusHistroy.BroughtBy =  @userId 				
		) a where RowNumber =1)

		SELECT 
			JobId,CandProfId,CandName,
			(select Top 1 FileName from [dbo].[PH_CANDIDATE_DOCS] as canDoc where statusHistroy.jobId = canDoc.joid and statusHistroy.CandProfId = canDoc.CandProfId and canDoc.DocType = 'Profile Photo' and Status = 1 order by canDoc.CreatedDate) as CandProfilePhoto,
			(select Top 1 JoiningDate from [dbo].[PH_JOB_OFFER_LETTERS] as OffLet where statusHistroy.jobId = OffLet.joid and statusHistroy.CandProfId = OffLet.CandProfId and Status = 1 order by OffLet.CreatedDate) as JoiningDate,
			StatusCode,ActivityDate,
			JobTitle,JobStats.Title as JobStatus,
			ClientID,ClientName,
			BroughtBy,CONCAT(BdmUser.FirstName,' ',BdmUser.LastName) as BroughtByName, (BdmUser.ProfilePhoto) as BroughtbyProfilePhoto,
			RecruiterId,CONCAT(RecUser.FirstName,' ',RecUser.LastName) as RecruiterName, (RecUser.ProfilePhoto) as RecruiterProfilePhoto, 
			CurrentStatusId,CurrentStatus.Title as CurrentStatusName,
			UpdateStatusId,UpdateStatus.Title as UpdateStatuName, statusHistroy.CreatedDate,
			CAST(DATEDIFF(DAY, statusHistroy.CreatedDate, GETDATE()) AS VARCHAR(10)) AS AgeBetweenDates 
		FROM 
			CandCTE as statusHistroy
			join dbo.PI_HIRE_USERS as RecUser on statusHistroy.RecruiterId = RecUser.Id 
			join dbo.PI_HIRE_USERS as BdmUser on statusHistroy.BroughtBy = BdmUser.Id
			left join dbo.PH_CAND_STATUS_S as CurrentStatus on statusHistroy.CurrentStatusId = CurrentStatus.id
			join dbo.PH_CAND_STATUS_S as UpdateStatus on statusHistroy.UpdateStatusId = UpdateStatus.id
			join dbo.PH_JOB_STATUS_S as JobStats on statusHistroy.JobOpeningStatus = JobStats.id

	END

	--select * from #BDMResults

	--drop table #BDMResults

END


