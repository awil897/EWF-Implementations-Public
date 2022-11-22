Function Get-EWFReportUrl {
    param
    (
    [String]
    [Parameter(Mandatory)]
    $WFGUID,
    
    [String]
    [Parameter(Mandatory)]
    $WFURL,
    
    [Parameter(Mandatory)]
    [ValidateSet("CategoryPermissions","QueuePermissions","InstitutionPermissions")]
    $Type
    )

    $outLink = "https:\\$wfurl\Reports\$type.$wfguid.html"
    return $outlink
}