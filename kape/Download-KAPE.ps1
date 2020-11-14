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

if (Test-Path $kapedestfolder) {
	Write-Host "Destination folder exists."
	} else {
	Write-Host "Creating destination folder."
	New-Item -ItemType Directory -Force -Path $kapedestfolder | out-null
	}

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
	
Write-Host "Downloading KAPE Atea-files."
