<#
    .SYNOPSIS
    Ths script will download KAPE and extract it to the c directory.
    .DESCRIPTION
    This script will download KAPE from the original, official KAPE source.
    .EXAMPLE
    C:\PS> Download-KAPE.ps1                      # Downloads KAPE with native ATEA-files
	C:\PS> Download-KAPE.ps1 -download kape       # Downloads KAPE with native ATEA-files
	C:\PS> Download-KAPE.ps1 -download utils      # Downloads 3rd party utilies with associated ATEA-files
	C:\PS> Download-KAPE.ps1 -download ateaonly   # Downloads all ATEA-files
	C:\PS> Download-KAPE.ps1 -download all        # Downloads KAPE, ATEA-files and 3rd party utilies
	
    
    .NOTES
    Author: Gos
    Date:   November 26, 2020
#>
param ($download, [switch] $help)
cls
# Sett cursor position litt ned
#$Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 2,($host.ui.rawui.WindowSize.Height 10)
	
Write-Host -ForegroundColor Cyan @"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






                                                                                               
               _/_/    _/_/_/_/_/  _/_/_/_/    _/_/            _/_/_/  _/_/_/    _/_/_/_/_/   
            _/    _/      _/      _/        _/    _/            _/    _/    _/      _/        
           _/_/_/_/      _/      _/_/_/    _/_/_/_/            _/    _/_/_/        _/         
          _/    _/      _/      _/        _/    _/            _/    _/    _/      _/          
         _/    _/      _/      _/_/_/_/  _/    _/          _/_/_/  _/    _/      _/           
                                                                                           
                                                                                           
	Download KAPE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"@


write-host ""
Write-Host " The script will download KAPE and extract it to c:\airt\kape`n"
Write-Host " Usage: Download-KAPE.ps1"
Write-Host "        Download-KAPE.ps1 -download <kape|utils|ateaonly|all>"
Write-Host "        Download-KAPE.ps1 -help    OR     Get-Help Download-KAPE.ps1 -full"
write-host ""


# Define folder environment
$kapedestfolder = "C:\airt\"
$kapetkapefolder = "C:\airt\KAPE\targets\!local"
$kapeoutputfolder = "C:\airt\KAPE_OUT"

function CreateKAPEFolders {
	if(New-Item -ItemType Directory -Path $kapedestfolder -erroraction 'silentlycontinue')   { Write-Host "$kapedestfolder created"  }
	if(New-Item -ItemType Directory -Path $kapetkapefolder -erroraction 'silentlycontinue')  { Write-Host "$kapetkapefolder created" }
	if(New-Item -ItemType Directory -Path $kapeoutputfolder -erroraction 'silentlycontinue') { Write-Host "$kapeoutputfolder created"}
	}
function DownloadKAPE {
	CreateKAPEFolders
	Write-Host "Downloading KAPE."
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'kape.zip'
	$dUrl = 'https://bit.ly/2Ei31Ga'
	$progressPreference = 'Continue'																	# SilentlyContinue, Continue, Inquire(Y/N),Stop
	Invoke-WebRequest -Uri $dUrl -OutFile $destFile -ErrorAction:silentlycontinue -UseBasicParsing
	
	Write-Host "Expanding archive."
	$progressPreference = 'Continue'
	Expand-Archive -Path $destFile -DestinationPath $kapedestfolder -Force
	}
function DownloadKAPEAteaNativeFiles{
	Write-Host "Downloading KAPE Atea-files."
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\targets\!local\!Atea_collection.tkape'
	$kapeCfgSrcUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/!Atea_collection.tkape"
	Invoke-WebRequest -Uri $kapeCfgSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing

	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\Modules\LiveResponse\!Atea_live_infocollect_native'
	$kapeCfgSrcUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/!Atea_live_infocollect_native"
	Invoke-WebRequest -Uri $kapeCfgSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	}
function Download3rdPartyUtils {
	Write-Host "Downloading 3rd party tools."
	
	#
	# Download WinPMem
	#
	Write-Host "..Downloading WinPMem version 3.2."
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\Modules\bin\winpmem.exe'
	$WinPMemSrcUrl = "https://github.com/Velocidex/c-aff4/releases/download/3.2/winpmem_3.2.exe"
	Invoke-WebRequest -Uri $WinPMemSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	
	#
	# Download PS Tools
	# Extracted into a temp folder and copying only applicable before riding the system of the tempfolder
	#
	$PSToolsTemp = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\PSToolsTemp'
	if(New-Item -ItemType Directory -Path $PSToolsTemp -erroraction 'silentlycontinue') { Write-Host "..Temporary PSTools-folder created"}
	
	Write-Host "..Downloading PStools."
	$destFile = Join-Path -Path $PSToolsTemp -ChildPath '\PSTools.zip'
	$PSToolsSrcUrl = "https://download.sysinternals.com/files/PSTools.zip"
	Invoke-WebRequest -Uri $PSToolsSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	Write-Host "..Expanding archive."
	Expand-Archive -Path $destFile -DestinationPath $PSToolsTemp -Force
	Write-Host "..Copying necessary PS Tools Binaries"
	$NecesssaryPSTools = "psfile.exe","psinfo.exe","pslist.exe","psloggedon.exe","psservice.exe"
	foreach ($pstool in $NecesssaryPSTools) {
		write-host "..Copying $pstool into modules"
		$pscopysrcfile = Join-Path -Path $PSToolsTemp -ChildPath $pstool
		$pscopydstfile = Join-Path -Path $kapedestfolder"KAPE\Modules\bin\" -ChildPath $pstool
		Copy-Item -path $pscopysrcfile -destination $pscopydstfile
	}
	#Clean up of PSToolsTemp-folder
	if(Remove-Item -Path $PSToolsTemp -Recurse -force){	Write-Host "..Temporary PSfolder with content removed"}
	
	}
function DownloadKAPEAtea3rdPartyFiles{
	Write-Host "Downloading 3rd party tools Atea-files"
	}

#Param switcher - Halp needed!
if($help) {
	$script = $MyInvocation.MyCommand.Path
	write-host -ForegroundColor Red	"Art thou seeking my wisdom? I give you Get-Help $script"
	write-host ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('LCosLCwqLCwsKioqKioqKiwsLCwsKioqKiosLCwsKioqKioqKiwqKioqLCwsLCwsLCosKioqKioqKioqKioqKioqKioqKioqKioqKioqKioKKiosLCwqKiosKiosKioqKioqLCwsLCwqKioqKioqL0BAQEBAIygvKi8qKiwqLCoqKioqKiovKioqLCoqLyoqKioqKioqKioqKioqKi8vKioKLCoqKiwqKioqKiwsLCwsLCwsLCosLCwqKiomQEBAQEBAQEAmQEBAQCZALyoqKioqLCoqKioqKi8qLyoqLyoqKiovKioqKiovKioqKioqKioKLCoqLCwsLCwsKioqKiwqKioqKioqKioqQEBAQEBAQEBAQEBAQEBAQEAmQEBAQCgqKioqKioqKioqKioqKioqKioqKiwqKioqKioqLyoqKioKLCosKiwqKiosKiosLCwqKioqLCoqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqKioqKioqKioqKioqKioqKioqKioqKioqKiovKioqKioKKiwsKiosKiosLCwqLCosKioqKiwsKipAJkBAQEBAQEBAQEAmQEBAQEBAQEBAQEAjKioqKioqKioqKioqKioqKioqLyoqKioqKioqLyoqLCoKKiwqKiwsLCwqLCoqLCwqLCoqKioqKi9AQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEAqKioqKioqKiwsKioqKioqKioqKioqKioqKioqKioqKioKLCwsKiosKiwsKiwsLCwsLCoqKioqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCYqKioqKiosKiosKioqKioqKioqKioqLyoqKioqLyoqKioKKiosLCwsLCosKiwqLCwqKiosLCwsLCooQEAmQEBAQEBAQEBAQEBAQEBAQEBAQCoqKiwqKiwsKioqLCwqKioqKioqKioqKioqKioqKioqKi8KLCosLCwsKiwsLCosLCwsLCoqKiwqLCwsJiZAQEBAQEBAQEBAQEBAQEBAQEAmKioqKioqKiwsKioqLCoqKioqKi8qKi8qKioqKioqKioqKioKKiosKiosKiwqLCosLCwsKiosKiwqLCwqL0BAQEBAQEBAQEBAQEBAQEBAQCYqKioqKioqKioqLCoqKioqKioqKiovKioqKioqKioqKioqKioKKiwsLCosLCoqLCosLCoqKioqLyosKiwsKkBAQEBAQEBAQEBAQEBAQEBAJS8vLyovKioqKioqKioqKiwsKioqKioqKioqKioqKioqKi8vKioKKiosLCwqKioqKioqLy8mJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCYqKioqKioqKioqKioqKioqKioqKioqKi8qKioKKiwsKiwqKiovQEBAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCMqKioqKioqKioqKioqKioqKioqKioqKioKLCoqLCwqKkBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAKCoqKioqKioqKi8qKioqKioqKioqKi8KLCosKiwqQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqLyoqKioqKioqKiovKioqKioqKioKKiwqKipAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIyoqKioqKioqLyoqKioqKioqKioKLCwqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAvKioqKioqKioqKioqLyoqKioKLCoqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQC8qKioqKioqKioqKioqKioKKiosKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIyoqKioqKioqKioqKioKKiwqKipAQEBAQEBAQEBAQEBAQEBAQCZAQEAmQEBAQCZAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCZAQEBAQCZAQEBAJigqKi8qKioqKioqKioKKioqLCojQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAjKioqKioqKioqKi8KLCwsKioqQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQCZAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBALyoqKiovKioqKioKKiosKioqQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIyoqKioqKiovKioKKiwqKioqKihAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBALyovKioqKioqKioKKiwsLCwqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQCMqKioqKi8qKioqKioqKioKLCosLCoqLyoqJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqKioqKioqKioqKioqKioqKioKLCwqLCoqKioqL0BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAoKioqKi8KKiwqKioqKioqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqKioKKioqKioqKioqKiooQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBALy8KKioqKioqKioqKiovL0BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAKioKKioqKioqKioqKioqKiNAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCZAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBALyoKKioqKioqKioqKioqKi8mQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAjKi8KKioqKioqKioqKioqKioqJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCoqKi8KKioqKioqKioqKioqKioqKkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCUqKiovKioKKioqKioqKioqKioqKiovLy9AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQCMqKi8qKioqKioqKioKQEBAQEBAQEBAQEBAQEBAQEBAQCgqQEAqI0BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAlQEBAQEBAQCZAJSYjLyoKQEBAQEAqKiovQCZAKioqKEBAQEAqLCoqQEBAQEBAKioqKkBALCoqJkBAQEAqKipAQC8oI0BAQEAmKi9AQCZAQCMjQEBAQEBAQEBAQCZAQEAKQEBAQEAqKiovQEBAKioqI0BAQCosKiosKkBAQEAqKixAQEBALCwqKixAQEAqKipAQCwqLCZALCwqKiZAQCoqLCwoJUAoKioqKioqKi9AQEAKQEBAQEBALyoqQEAqKioqQEBAKiwsQCMqKipAQCYmKioqI0BAKiwqLCwsKkAsLCpAQCoqLEBALyoqKkBAQC8qLComQEAvKioqLygjI0BAQEAKQEBAQEBAQC8qKioqKihAQEAqKioqKi8qKiojQEBAJioqKkBAKioqQCYqKi8qKipAQCoqKkBAQEAqKiolQEBAKioqL0AqLyoqKC8qL0BAQEAKQEBAQEBAQEAqKioqQEBAQCoqKihAQEAmKi8qJiUqKi8qQCZAKioqQEBAJioqKipAJSoqL0AoKi8vKipAJS8qLy8qQEAqKioqKioqKi9AQEAKQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCYlJkBAJkAmJiYmQCUlI0BAQEA=')))
	get-help $script
	# If help is given, then exit script
	exit 
	}
#Param switcher - Downloads
if(!$download -OR $download -eq "kape") {
	# No download-parameter given or parameter kape given
	# Downloading KAPE + ATEA-native files
	DownloadKAPE
	DownloadKAPEAteaNativeFiles
}elseif($download -eq "utils"){
	# Download-parameter utils given
	# Downloading all third party utilies with associated ATEA mkape-files
	Download3rdPartyUtils
	DownloadKAPEAtea3rdPartyFiles
}elseif($download -eq "ateaonly"){
	# Download-parameter utils given
	# Downloading all atea mkape/tkape files. Use case; updated files while on engagement
	DownloadKAPEAteaNativeFiles
	DownloadKAPEAtea3rdPartyFiles
}elseif($download -eq "all"){
	# Download-parameter all given
	# Downloading KAPE, Atea native m/tkape files, 3rd party utilies with associated ATEA mkape-files
	DownloadKAPE
	Download3rdPartyUtils
	DownloadKAPEAteaNativeFiles
	DownloadKAPEAtea3rdPartyFiles
}   

