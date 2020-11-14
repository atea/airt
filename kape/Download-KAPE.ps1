<#
    .SYNOPSIS
    Ths script will download KAPE and extract it to the current working directory. It is expected this script is run from an existing KAPE directory.
    .DESCRIPTION
    This script will download KAPE from the original source.
	Source code borrowed from Eric Zimmerman.
    .EXAMPLE
    C:\PS> Download-KAPE.ps1
    
    .NOTES
    Author: Gos
    Date:   November 14, 2020
#>

write-host ""
Write-Host " The script will download KAPE and extract it to the current working directory."
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

if (Test-Path $kapedestfolder"\KAPE\kape.exe") {
	write-host "KAPE downloaded and extracted."
	} else {
	write-host "Can not find kape.exe.... o.O"
	}

New-Item -ItemType Directory -Force -Path $kapetkapefolder | out-null
	
Write-Host "Downloading KAPE Atea-files."
$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\targets\!local\!Atea_collection.tkape'
$tkapeUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/!Atea_collection.tkape"
Invoke-WebRequest -Uri $tkapeUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing