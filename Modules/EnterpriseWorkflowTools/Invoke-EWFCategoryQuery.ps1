Function Invoke-EWFCategoryQuery {
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
    $Query = '
    USE WFServer

    DECLARE @xml NVARCHAR(MAX)
    DECLARE @body NVARCHAR(MAX)

    SELECT f.FieldValue [User]
    , e.Name [Category]
    , d.Description [Permission]
    , c.PermissionState [Allowed]
    INTO #GroupCategoryPermissions
    FROM dbo.[Group] a
    INNER JOIN dbo.CategoryPermission b
    ON a.Id=b.GroupId AND a.TenantId=b.TenantId AND a.TenantId = 1
    INNER JOIN dbo.[Category] e
    ON e.Id=b.CategoryId
    INNER JOIN dbo.PermissionItem c
    ON b.PermissionSetId=c.PermissionSetId AND b.TenantId=c.TenantId
    INNER JOIN dbo.PermissionDefinition d
    ON c.PermissionDefinitionKey=d.PermissionDefinitionKey
    INNER JOIN dbo.[GroupMembership] f
    ON f.GroupId=a.Id;

    SELECT * 
    INTO #CategoryPivot
    FROM (
    SELECT [User], [Category], [Permission], [Allowed]
    FROM #GroupCategoryPermissions) Records
    PIVOT (
     MAX([Allowed])
     FOR [PERMISSION] IN ([Add Attachments],[Add Comments],[Author Definition],[Change Priority],[Delete Definition],[Edit Variable Value],[Export Definition],[Faulted Workflow Notification],[Monitor Workflows],[Publish Definition],[Release Held Activities],[Remove Attachments],[Retry Faulted Workflows],[Search Workflows],[Start a Workflow],[Terminate Workflow],[Unpublish Definition],[View Attachments],[View Comments],[View Variables],[Workflow History]))
     AS CategoryPivotTable;

    SELECT [User], [Category]
    , CASE [Add Attachments] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Add Attachments]
    , CASE [Add Comments] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Add Comments]
    , CASE [Author Definition] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Author Definition]
    , CASE [Change Priority] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Change Priority]
    , CASE [Delete Definition] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Delete Definition]
    , CASE [Edit Variable Value] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Edit Variable Value]
    , CASE [Export Definition] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Export Definition]
    , CASE [Faulted Workflow Notification] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Faulted Workflow Notification]
    , CASE [Monitor Workflows] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Monitor Workflows]
    , CASE [Publish Definition] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Publish Definition]
    , CASE [Release Held Activities] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Release Held Activities]
    , CASE [Remove Attachments] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Remove Attachments]
    , CASE [Retry Faulted Workflows] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Retry Faulted Workflows]
    , CASE [Search Workflows] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Search Workflows]
    , CASE [Start a Workflow] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Start a Workflow]
    , CASE [Terminate Workflow] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Terminate Workflow]
    , CASE [Unpublish Definition] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Unpublish Definition]
    , CASE [View Attachments] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [View Attachments]
    , CASE [View Comments] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [View Comments]
    , CASE [View Variables] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [View Variables]
    , CASE [Workflow History] WHEN 0 THEN ''Unassigned'' WHEN 1 THEN ''Allowed'' ELSE ''Denied'' END [Workflow History]
    INTO #CategoryData
    FROM #CategoryPivot;

    SELECT * From #CategoryData;

    DROP TABLE #CategoryData;
    DROP TABLE #GroupCategoryPermissions
    DROP TABLE #CategoryPivot;

    '
    $return = (Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;"  -Query "$Query") | Select-Object * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors
    return $return
}