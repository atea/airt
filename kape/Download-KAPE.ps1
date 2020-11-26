<#
    .SYNOPSIS
    Ths script will download KAPE and extract it to the c directory.
    .DESCRIPTION
    This script will download KAPE from the original, official KAPE source.
    .EXAMPLE
    C:\PS> Download-KAPE.ps1
    
    .NOTES
    Author: Gos
    Date:   November 14, 2020
#>

write-host ""
Write-Host " The script will download KAPE and extract it to c:\airt\kape"
write-host ""

$kapedestfolder = "C:\airt\"
$kapetkapefolder = "C:\airt\KAPE\targets\!local"
$kapeoutputfolder = "C:\airt\KAPE_OUT"

if(New-Item -ItemType Directory -Path $kapedestfolder -erroraction 'silentlycontinue')   { Write-Host "$kapedestfolder created"  }
if(New-Item -ItemType Directory -Path $kapetkapefolder -erroraction 'silentlycontinue')  { Write-Host "$kapetkapefolder created" }
if(New-Item -ItemType Directory -Path $kapeoutputfolder -erroraction 'silentlycontinue') { Write-Host "$kapeoutputfolder created"}

Write-Host "Downloading KAPE."
$destFile = Join-Path -Path $kapedestfolder -ChildPath 'kape.zip'
$dUrl = 'https://bit.ly/2Ei31Ga'
$progressPreference = 'Continue'
Invoke-WebRequest -Uri $dUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing

Write-Host "Expanding archive."
$progressPreference = 'Continue'
Expand-Archive -Path $destFile -DestinationPath $kapedestfolder -Force
	
Write-Host "Downloading KAPE Atea-files."
$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\targets\!local\!Atea_collection.tkape'
$kapeCfgSrcUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/!Atea_collection.tkape"
Invoke-WebRequest -Uri $kapeCfgSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing

$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\Modules\LiveResponse\!Atea_infocollect_native.mkape'
$kapeCfgSrcUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/!Atea_infocollect_native.mkape'"
Invoke-WebRequest -Uri $kapeCfgSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing


