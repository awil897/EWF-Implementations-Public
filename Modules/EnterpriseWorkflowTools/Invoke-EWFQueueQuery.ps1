Function Invoke-EWFQueueQuery {
    param
    (
    [String]
    [Parameter(Mandatory)]
    $WFGUID,
    
    [String]
    [Parameter(Mandatory)]
    $WFID,

    [String]
    [Parameter(Mandatory)]
    $SQLInstance
    )

    $SqlServer    = $sqlInstance  # SQL Server instance (HostName\InstanceName for named instance)
    $Database     = 'WFServer'          # SQL database to connect to 
    $Query = 'USE WFServer

    DECLARE @xml NVARCHAR(MAX)
    DECLARE @body NVARCHAR(MAX)

    SELECT f.FieldValue [User]
    , e.Name [Queue]
    , d.Description [Permission]
    , c.PermissionState [Allowed]
    INTO #GroupQueuePermissions
    FROM dbo.[Group] a
    INNER JOIN dbo.QueuePermission b
    ON a.Id=b.GroupId AND a.TenantId=b.TenantId
    INNER JOIN dbo.[Queue] e
    ON e.Id=b.QueueId
    INNER JOIN dbo.PermissionItem c
    ON b.PermissionSetId=c.PermissionSetId AND b.TenantId=c.TenantId
    INNER JOIN dbo.PermissionDefinition d
    ON c.PermissionDefinitionKey=d.PermissionDefinitionKey
    INNER JOIN dbo.[GroupMembership] f
    ON f.GroupId=a.Id;

    SELECT * 
    INTO #QueuePivot
    FROM (
    SELECT [User], [Queue], [Permission], [Allowed]
    FROM #GroupQueuePermissions) Records
    PIVOT (
      MAX([Allowed])
      FOR [PERMISSION] IN ([Lock Assignment],[Manage Queue Status],[Queue Manager Notification],[Reassign Work],[Receive Work],[Take Work]))
      AS QueuePivotTable;

    SELECT [User], [Queue]
    , CASE [Lock Assignment] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Lock Assignment]
    , CASE [Manage Queue Status] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Manage Queue Status]
    , CASE [Queue Manager Notification] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Queue Manager Notification]
    , CASE [Reassign Work] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Reassign Work]
    , CASE [Receive Work] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Receive Work]
    , CASE [Take Work] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Take Work]
    INTO #QueueData
    FROM #QueuePivot;
    
    SELECT * From #QueueData;
    
    DROP TABLE #GroupQueuePermissions;
    DROP TABLE #QueueData;
    DROP TABLE #QueuePivot;
    '
    $return = (Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;"  -Query "$Query") | Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors
    return $return
}