function Get-Resource {
    param($Name)
    
    $ProcessName = (Get-Process -Id $PID).Name
    try 
    {
       $Stream = [System.Reflection.Assembly]::GetEntryAssembly().GetManifestResourceStream("$ProcessName.g.resources")
       $KV = [System.Resources.ResourceReader]::new($Stream) | Where-Object Key -EQ $Name
       $Stream = $KV.Value
    } catch {}

   if (-not $Stream)
   {
       $Stream = [IO.File]::OpenRead("$PSScriptRoot\favicon.ico")
   }

   $Stream
}

$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.StreamSource = Get-Resource -Name 'favicon.ico'
$bitmap.EndInit()
$bitmap.Freeze()

$ListUsers = {
	$richText.Clear()
	
	if (($clientIdBox.Text -like $null)){
		Append-ColoredLine $richText Crimson "ClientID is invalid or blank. Please re-enter"
		return
	}
	else {
		Append-ColoredLine $richText SlateGray "Getting API endpoint from Adobe"
		$bearer = $clientIdBox.Text
		$user = $emailBox.Text
		$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$headers.Add("Authorization", "Bearer $bearer")
		$baseUriRequest = 'https://api.echosign.com/api/rest/v6/baseUris'
		Try {
			$uris = Invoke-RestMethod -Method Get -UseBasicParsing -uri $baseUriRequest -Headers $headers
			$baseURI = $uris.apiAccessPoint
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText DarkGreen "BaseURL is $($BaseUri)"
			
		}
		Catch {
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Crimson "ER01 - Error Retrieving Base URL"
			return
		}
	}
	if ($baseURI -notlike $null){
		$richText.AppendText([Environment]::NewLine)
		Append-ColoredLine $richText SlateGray "Getting user list"
		
		Try {
			$uri = $baseUri + "api/rest/v6/users"
			$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
			$headers.Add("Authorization", "Bearer $bearer")
			$headers.Add("Content-Type", "application/json")
			$userList = (Invoke-RestMethod -uri $uri -headers $headers -method Get).userInfoList
			$userList = ($userList | select-object -expandproperty email  | out-String).Trim()
			#Append-ColoredLine $richText SlateGray "$($userlist)"
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText DarkGreen "User list retrieved"
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Black "$userList"
		}
		Catch {
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Crimson "ER03 - Error Retrieving Users"
			return
		}
	}
	else {
		$richText.AppendText([Environment]::NewLine)
		Append-ColoredLine $richText Crimson "ER02 - Error Retrieving Base URL"
	}
}
$SearchUsers = {
	$richText.Clear()
	if (($clientIdBox.Text -like $null) -or ($searchbox.text -like $null)){
		Append-ColoredLine $richText Crimson "ClientID or Search String is invalid or blank. Please re-enter"
		return
	}
	else {
		Append-ColoredLine $richText SlateGray "Getting API endpoint from Adobe"
		$bearer = $clientIdBox.Text
		$searchString = $searchbox.Text
		$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$headers.Add("Authorization", "Bearer $bearer")
		$baseUriRequest = 'https://api.echosign.com/api/rest/v6/baseUris'
		Try {
			$uris = Invoke-RestMethod -Method Get -UseBasicParsing -uri $baseUriRequest -Headers $headers
			$baseURI = $uris.apiAccessPoint
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText DarkGreen "BaseURL is $($BaseUri)"
			
		}
		Catch {
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Crimson "ER01 - Error Retrieving Base URL"
			return
		}
	}
	if ($baseURI -notlike $null){
		$richText.AppendText([Environment]::NewLine)
		Append-ColoredLine $richText SlateGray "Getting user list"
		Try {
			$uri = $baseUri + "api/rest/v6/users"
			$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
			$headers.Add("Authorization", "Bearer $bearer")
			$headers.Add("Content-Type", "application/json")
			$userList = (Invoke-RestMethod -uri $uri -headers $headers -method Get).userInfoList
			$userList = $userList | select-object -expandproperty email
			#Append-ColoredLine $richText SlateGray "$($userlist)"
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText DarkGreen "User list retrieved"
			$emails = $userlist | where-object {$_ -like "*$searchString*"}
			$emailsString = ($emails | out-String).Trim()
			#Append-ColoredLine $richText Blue "emails is $($emails)"
			#Append-ColoredLine $richText Blue "emailsString is $($emailsString)"
		}
		Catch {
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Crimson "ER03 - Error Retrieving Users"
			return
		}
		if ($emailsString -like $null){
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Goldenrod "No matching users found"
		}
		if ($emailsString -notlike $null){
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText DarkGreen "Matching Users Found"
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Black "$($emailsString)"
		}
	}
	else {
		$richText.AppendText([Environment]::NewLine)
		Append-ColoredLine $richText Crimson "ER02 - Error Retrieving Base URL"
	}
}
$checkUser = {
	$richText.Clear()
	$userCheck = IsValidEmail -EmailAddress $emailbox.text
	if (($clientIdBox.Text -like $null) -or ($emailbox.Text -like $null) -or ($userCheck -like $false)){
		Append-ColoredLine $richText Crimson "ClientID or Email Address is invalid or blank. Please re-enter"
	}
	else {
		Append-ColoredLine $richText Gray "Getting API endpoint from Adobe"
		$bearer = $clientIdBox.Text
		$user = $emailBox.Text
		$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$headers.Add("Authorization", "Bearer $bearer")
		$baseUriRequest = 'https://api.echosign.com/api/rest/v6/baseUris'
		Try {
			$uris = Invoke-RestMethod -Method Get -UseBasicParsing -uri $baseUriRequest -Headers $headers
			$baseURI = $uris.apiAccessPoint
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText DarkGreen "BaseURL is $($BaseUri)"
			
			}
		Catch {
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Crimson "ER01 - Error Retrieving Base URL"
			return
		}
		if ($baseURI -notlike $null){
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText SlateGray "Getting user information for $($user)"
			
			Try {
				$uri = $baseUri + "api/rest/v6/users"
				$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
				$headers.Add("Authorization", "Bearer $bearer")
				$headers.Add("Content-Type", "application/json")
				$userList = (Invoke-RestMethod -uri $uri -headers $headers -method Get).userInfoList
				$userList = $userList | select-object email,id
				#Append-ColoredLine $richText SlateGray "$($userlist)"
				$richText.AppendText([Environment]::NewLine)
				Append-ColoredLine $richText SlateGray "User list retrieved"
				$contains = $userList.email.Contains($user)
			}
			Catch {
				$richText.AppendText([Environment]::NewLine)
				Append-ColoredLine $richText Crimson "ER03 - Error Retrieving Users"
				return
			}
			if ($contains -like $true){
				Try {
					$richText.AppendText([Environment]::NewLine)
					Append-ColoredLine $richText DarkGreen "$($user) is a valid Adobe Sign User"
					$id = ($userList | Where-object {$_.email -like $user}).id
					$uri = $baseUri + "api/rest/v6/users/" + $id	
					$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
					$headers.Add("Authorization", "Bearer $bearer")
					$userInfo = (Invoke-RestMethod -uri $uri -headers $headers -method Get)
					$userInfo = $userInfo | Select-Object id,company,email,firstName,lastname,createdDate,isAccountAdmin,status
					$userInfoString = ($userInfo | out-String).Trim()
					$richText.AppendText([Environment]::NewLine)
					Append-ColoredLine $richText SlateGray $userInfoString
				}
				Catch {
					$richText.AppendText([Environment]::NewLine)
					Append-ColoredLine $richText Crimson "ER04 - Error checking Adobe Sign User info for $($user)"
					return
				}
				if ($userinfo.status -like "active"){
					$richText.AppendText([Environment]::NewLine)
					Append-ColoredLine $richText DarkGreen "$($user) is Active in Adobe Sign"
				}
				else {
					$richText.AppendText([Environment]::NewLine)
					Append-ColoredLine $richText Goldenrod "$($user) is listed as $($userinfo.status)"
				}
			}
			
			else {
				$richText.AppendText([Environment]::NewLine)
				Append-ColoredLine $richText Crimson "ER05 - $($user) not found in Adobe Sign users"
			}
		}
		
		else {
			$richText.AppendText([Environment]::NewLine)
			Append-ColoredLine $richText Crimson "ER02 - Error Retrieving Base URL"
		}
	}
}
function Append-ColoredLine {
    param( 
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Windows.Forms.RichTextBox]$box,
        [Parameter(Mandatory = $true, Position = 1)]
        [System.Drawing.Color]$color,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$text
    )
    $box.SelectionStart = $box.TextLength
    $box.SelectionLength = 0
    $box.SelectionColor = $color
    $box.AppendText($text)
    $box.AppendText([Environment]::NewLine)
}
function IsValidEmail { 
    param([string]$EmailAddress)

    try {
        $null = [mailaddress]$EmailAddress
        return $true
    }
    catch {
        return $false
    }
}

Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'adobesigntesttool.designer.ps1')

$Form1.ShowDialog()