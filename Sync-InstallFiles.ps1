$repoOwner = 'JHAEISIS'
$repoName  = 'EWF-Implementations-Install'
$branch    = 'main'
$localPath = 'C:\JX\Install Files\EWF_2023.0_Upgrade'
$token     = $key

$ProgressPreference = 'SilentlyContinue'

function Get-LFSDownloadInfo($oid, $size) {
    $body = @{
        operation = 'download'
        transfer  = @('basic')
        objects   = @(@{ oid = $oid; size = [int64]$size })
    } | ConvertTo-Json

    $headers = @{
        Authorization  = "Bearer $token"
        Accept         = 'application/vnd.git-lfs+json'
        'Content-Type' = 'application/json'
    }

    $lfsApiUrl = "https://github.com/$repoOwner/$repoName.git/info/lfs/objects/batch"
    $response = Invoke-RestMethod -Uri $lfsApiUrl -Method POST -Headers $headers -Body $body

    return $response.objects[0]
}

function Download-FileWithProgress($url, $destPath, $token, $acceptHeader = "application/octet-stream", $authType = "Bearer") {
    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
    $request.Headers.Add("Authorization", "$authType $token")
    $request.Accept = $acceptHeader
    $request.UserAgent = "PowerShell"  # <-- GitHub API explicitly requires this

    try {
        $response = $request.GetResponse()
    }
    catch {
        Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    $totalLength = $response.ContentLength
    $responseStream = $response.GetResponseStream()
    $fileStream = [System.IO.File]::Create($destPath)

    $buffer = New-Object byte[] 1MB
    [int]$readBytes = 0
    [long]$totalRead = 0
    $lastPercent = -1

    do {
        $readBytes = $responseStream.Read($buffer, 0, $buffer.Length)
        $fileStream.Write($buffer, 0, $readBytes)
        $totalRead += $readBytes

        if ($totalLength -gt 0) {
            $percent = [Math]::Floor(($totalRead / $totalLength) * 100)
            if ($percent -ne $lastPercent -and $percent % 10 -eq 0) {
                Write-Host "$percent% complete"
                $lastPercent = $percent
            }
        }
    } while ($readBytes -gt 0)

    $fileStream.Close()
    $responseStream.Close()
    $response.Close()
}
function Sync-GitHubRepoContents($repoPath, $localDestination) {
    $apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/$repoPath`?ref=$branch"
    $headers = @{ Authorization = "bearer $token" }

    try {
        $items = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    } catch {
        Write-Host "Failed to retrieve: $repoPath" -ForegroundColor Red
        return
    }

    foreach ($item in $items) {
        if ($item.name.StartsWith('.') -or $item.name.EndsWith('.log')) { continue }

        $localItemPath = Join-Path $localDestination $item.name

        if ($item.type -eq 'dir') {
            if (-not (Test-Path $localItemPath)) {
                New-Item -ItemType Directory -Path $localItemPath | Out-Null
            }
            Sync-GitHubRepoContents $item.path $localItemPath
        } elseif ($item.type -eq 'file') {
            $isLfs = $false
            $remoteSize = [int64]$item.size
            $downloadUrl = $null

            if ($item.size -lt 200) {
                $pointerContent = Invoke-RestMethod -Uri $item.download_url -Headers $headers
                if ($pointerContent -match 'oid sha256:(\w+)\s+size (\d+)') {
                    $isLfs = $true
                    $oid = $Matches[1]
                    $lfsSize = [int64]$Matches[2]

                    $lfsInfo = Get-LFSDownloadInfo $oid $lfsSize
                    $remoteSize = [int64]$lfsInfo.size
                    $downloadUrl = $lfsInfo.actions.download.href
                }
            }

            $downloadFile = $false
            if (Test-Path $localItemPath) {
                $localSize = (Get-Item $localItemPath).Length
                if ($localSize -ne $remoteSize) { 
                    $downloadFile = $true 
                }
            } else {
                $downloadFile = $true
            }
            if ($downloadFile) {
                Write-Host "Downloading $($item.path)..."

                if ($isLfs) {
                    # LFS files (Bearer token, octet-stream)
                    Download-FileWithProgress $downloadUrl $localItemPath $token "application/octet-stream" "Bearer"
                }
                else {
                    if ($item.size -gt 1000000 -or $item.encoding -eq 'none') {
                        # Large file: Use Blob API explicitly
                        $blobUrl = "https://api.github.com/repos/$repoOwner/$repoName/git/blobs/$($item.sha)"
                        #$response = Invoke-WebRequest -Uri $blobUrl -Headers @{
                        #    Authorization = "Bearer $token"
                        #    Accept        = 'application/vnd.github.v3.raw'
                        #} -UseBasicParsing
                        Download-FileWithProgress $blobUrl $localItemPath $token "application/vnd.github.v3.raw" "Bearer"
                        Write-Host "100% complete (Blob API)"
                    }
                    else {
                        # Small files via base64 content API
                        $fileContent = Invoke-RestMethod -Uri $item.url -Headers @{ Authorization = "Bearer $token" }
                        [IO.File]::WriteAllBytes($localItemPath, [Convert]::FromBase64String($fileContent.content))
                        Write-Host "100% complete (Content API)"
                    }
                }
            }            
            else {
                Write-Host "Skipping existing file: $($item.path)" -ForegroundColor Cyan
            }
        }
    }
}

Sync-GitHubRepoContents '' $localPath
