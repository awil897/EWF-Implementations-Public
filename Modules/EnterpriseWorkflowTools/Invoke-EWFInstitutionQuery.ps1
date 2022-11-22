Function Invoke-EWFInstitutionQuery {
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
    DECLARE @tenantName NVARCHAR(128)

    SET @tenantName = cast(SUSER_SNAME() as varchar(128));

    SELECT f.FieldValue [User]
    , d.Description [Permission]
    , c.PermissionState [Allowed]
    INTO #GroupInstitutionPermissions
    FROM dbo.[Group] a
    INNER JOIN dbo.GeneralPermission b
    ON a.Id=b.GroupId AND a.TenantId=b.TenantId AND a.TenantId IN (SELECT TenantId FROM dbo.SystemUser WHERE (UserName = cast(SUSER_SNAME() as varchar(128))))
    INNER JOIN dbo.Tenant e
    ON e.Id=a.TenantId
    INNER JOIN dbo.PermissionItem c
    ON b.PermissionSetId=c.PermissionSetId AND b.TenantId=c.TenantId
    INNER JOIN dbo.PermissionDefinition d
    ON c.PermissionDefinitionKey=d.PermissionDefinitionKey
    INNER JOIN dbo.[GroupMembership] f
    ON f.GroupId=a.Id;

    SELECT * 
    INTO #InstitutionPivot
    FROM (
    SELECT [User], [Permission], [Allowed]
    FROM #GroupInstitutionPermissions) Records
    PIVOT (
     MAX([Allowed])
     FOR [PERMISSION] IN ([Manage Extensibility Packages],[Manage My Status],[Manage Predefined Queries],[Manage User Status],[Preview Attachments],[Preview Comments],[Preview Variables]))
     AS InstitutionPivotTable;

    SELECT [User]
    , CASE [Manage Extensibility Packages] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Manage Extensibility Packages]
    , CASE [Manage My Status] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Manage My Status]
    , CASE [Manage Predefined Queries] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Manage Predefined Queries]
    , CASE [Manage User Status] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Manage User Status]
    , CASE [Preview Attachments] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Preview Attachments]
    , CASE [Preview Comments] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Preview Comments]
    , CASE [Preview Variables] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Preview Variables]
    INTO #InstitutionData
    FROM #InstitutionPivot;

    SELECT * From #InstitutionData;

    DROP TABLE #InstitutionData;
    DROP TABLE #GroupInstitutionPermissions
    DROP TABLE #InstitutionPivot;
    '
    $return = (Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;"  -Query "$Query") | Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors
    return $return
}