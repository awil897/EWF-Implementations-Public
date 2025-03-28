
;WITH records AS (
	SELECT [Id],[SurrogateInstanceId],[ComplexDataProperties],[MetadataProperties],[DataEncodingOption],[MetadataEncodingOption],[Version],[PendingTimer],[CreationTime],[LastUpdated],[WorkflowHostType],[ServiceDeploymentId],[SuspensionExceptionName],[SuspensionReason],[BlockingBookmarks],[LastMachineRunOn],[ExecutionStatus],[IsInitialized],[IsSuspended],[IsReadyToRun],[IsCompleted],[SurrogateIdentityId] 
	FROM [JX-AppFab-Persistence].[System.Activities.DurableInstancing].[InstancesTable] 
	WHERE CreationTime >= '2022-10-09' and Id <> '14173D1E-9E8F-4118-A32B-4A467F08BC45'
)

--SELECT * from records;

INSERT INTO [Persistence-36534-PROD].[System.Activities.DurableInstancing].[InstancesTable] ([Id],[ComplexDataProperties],[MetadataProperties],[DataEncodingOption],[MetadataEncodingOption],[Version],[PendingTimer],[CreationTime],[LastUpdated],[WorkflowHostType],[ServiceDeploymentId],[SuspensionExceptionName],[SuspensionReason],[BlockingBookmarks],[LastMachineRunOn],[ExecutionStatus],[IsInitialized],[IsSuspended],[IsReadyToRun],[IsCompleted],[SurrogateIdentityId])
SELECT [Id],[ComplexDataProperties],[MetadataProperties],[DataEncodingOption],[MetadataEncodingOption],[Version],[PendingTimer],[CreationTime],[LastUpdated],[WorkflowHostType],[ServiceDeploymentId],[SuspensionExceptionName],[SuspensionReason],[BlockingBookmarks],[LastMachineRunOn],[ExecutionStatus],[IsInitialized],[IsSuspended],[IsReadyToRun],[IsCompleted],[SurrogateIdentityId]
FROM records;
-------------------------------------------------------------------
--------------------------------------------------------------------



WITH records AS (
	SELECT [Id],[SurrogateInstanceId],[ComplexDataProperties],[MetadataProperties],[DataEncodingOption],[MetadataEncodingOption],[Version],[PendingTimer],[CreationTime],[LastUpdated],[WorkflowHostType],[ServiceDeploymentId],[SuspensionExceptionName],[SuspensionReason],[BlockingBookmarks],[LastMachineRunOn],[ExecutionStatus],[IsInitialized],[IsSuspended],[IsReadyToRun],[IsCompleted],[SurrogateIdentityId] 
	FROM [JX-AppFab-Persistence].[System.Activities.DurableInstancing].[InstancesTable] 
	WHERE CreationTime >= '2022-10-09' and Id <> '14173D1E-9E8F-4118-A32B-4A467F08BC45'
),
keys AS (
	SELECT r.Id as recordId,k.Id,k.EncodingOption,k.IsAssociated
	FROM [JX-AppFab-Persistence].[System.Activities.DurableInstancing].[KeysTable] k
	Inner Join records r
	ON k.SurrogateInstanceId = r.SurrogateInstanceId
),
newkeys AS (
	SELECT i.Id as recordId,k.Id,i.SurrogateInstanceId,k.EncodingOption,k.IsAssociated
	FROM keys k
	Inner Join [Persistence-36534-PROD].[System.Activities.DurableInstancing].[InstancesTable] i
	ON k.recordId = i.Id
)

INSERT INTO [Persistence-36534-PROD].[System.Activities.DurableInstancing].[KeysTable] (Id,SurrogateInstanceId,EncodingOption,IsAssociated)
SELECT Id,SurrogateInstanceId,EncodingOption,IsAssociated
FROM newkeys










