<#
    .SYNOPSIS
    Ths script will download KAPE and extract it to the c directory.
	Depending on the options given, the script will initialize a download one of or a selection of KAPE, Atea KAPE-files or 3rd utilies 
	
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
                                                                                           
                                                                                           
	Download KAPE with utilies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"@


write-host ""
Write-Host " The script will download KAPE and extract it to c:\airt\kape`n"
Write-Host " Usage: Download-KAPE.ps1"
Write-Host "        Download-KAPE.ps1 -download <kape|utils|ateaonly|all>"
Write-Host "        Download-KAPE.ps1 -help    OR     Get-Help Download-KAPE.ps1 -full`n"
write-host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


# Define folder environment
$kapedestfolder = "C:\airt\"
$kapetkapefolder = "C:\airt\KAPE\targets\!local"
$kapemkapefolder = "C:\airt\KAPE\modules\Atea"
$kapeoutputfolder = "C:\airt\KAPE_OUT"

# Define TLS-version to be used for web-requests as older servers default to lesser secure TLS-versions
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function VerifyHash($file,$ExpectedHash) {
	# Function checks supplied hash against a hashing operation against the file.
	# If a mismatch, the file will be deemed tampered with, deleted and a note dropped.
	$Hash = (Get-FileHash -path $file -Algorithm SHA512)
	if($Hash.hash -eq $ExpectedHash) {
		Write-Host "..Hash of $file as expected"
	}elseif($Hash.hash -ne $ExpectedHash){
		Write-Host -ForegroundColor Red "..Hash not as expected.`n..Got Hash $Hash`n..Expected $ExpectedHash `n..Deleting $file "
		Remove-Item -Path $file -Force
		"File slettet da SHA512 ikke stemte over ens med forventing. Endring av filer i tredjeparts utils?" | out-file "$file.txt"
	}else{
		Write-Host "..Unable to verify hash"
	}
}

function UnzipFile($zipfile,$destpath) {
	# Function to determine wether to use Expand-Archive or something else.
	# Expand-Archive was introduced in PS-v5
	if($PSVersionTable.PSVersion.Major -gt 4) {
		write-host "..Expanding Archive"
		write-host $zipfile
		Expand-Archive -Path $zipfile -DestinationPath $destpath -Force
	}else{
		write-host "..Expanding Archive using COM object"
		$shell = new-object -com Shell.Application 
		$shell.namespace($destpath).copyhere($shell.NameSpace($zipfile).Items(),0x14)  #0x14 = silent overwrite
	}
}

function CreateKAPEFolders {
	Write-Host "Creating folders"
	if(New-Item -ItemType Directory -Path $kapedestfolder -erroraction 'silentlycontinue')   { Write-Host "..$kapedestfolder created"  }
	if(New-Item -ItemType Directory -Path $kapetkapefolder -erroraction 'silentlycontinue')  { Write-Host "..$kapetkapefolder created" }
	if(New-Item -ItemType Directory -Path $kapemkapefolder -erroraction 'silentlycontinue')  { Write-Host "..$kapemkapefolder created" }
	if(New-Item -ItemType Directory -Path $kapeoutputfolder -erroraction 'silentlycontinue') { Write-Host "..$kapeoutputfolder created"}
	
	}
function DownloadKAPE {
	CreateKAPEFolders
	Write-Host "Downloading KAPE"
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'kape.zip'
	$dUrl = 'https://bit.ly/2Ei31Ga'
	$progressPreference = 'Continue'																	# SilentlyContinue, Continue, Inquire(Y/N),Stop
	Invoke-WebRequest -Uri $dUrl -OutFile $destFile -ErrorAction:silentlycontinue -UseBasicParsing
	
	$progressPreference = 'Continue'
	UnzipFile -zipfile $destFile -destpath $kapedestfolder
	}
function DownloadKAPEAteaNativeFiles{
	Write-Host "Downloading KAPE Atea-files."
	
	#Download tkape file
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\targets\!local\!Atea_collection.tkape'
	$kapeCfgSrcUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/!Atea_collection.tkape"
	Invoke-WebRequest -Uri $kapeCfgSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	Write-Host "..!Atea_collection.tkape downloaded"
	
	#Download mkape file
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\Modules\Atea\!Atea_live_infocollect_native.mkape'
	$kapeCfgSrcUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/!Atea_live_infocollect_native.mkape"
	Invoke-WebRequest -Uri $kapeCfgSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	Write-Host "..!Atea_live_infocollect_native.mkape downloaded"
	}
function Download3rdPartyUtils {
	Write-Host "Downloading 3rd party tools."
	
	#
	# Download WinPMem
	#
	Write-Host "..Downloading WinPMem version 3.2."
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\Modules\bin\winpmem.exe'
	$WinPMemSrcUrl = "https://github.com/Velocidex/WinPmem/releases/download/v4.0.rc1/winpmem_mini_x64_rc2.exe"
	Invoke-WebRequest -Uri $WinPMemSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	 
	#
	# Download PS Tools
	# Extracted into a temp folder and copying only applicable before riding the system of the tempfolder
	#
	$PSToolsTemp = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\PSToolsTemp'
	if(New-Item -ItemType Directory -Path $PSToolsTemp -erroraction 'silentlycontinue') { Write-Host "..Temporary PSTools-folder created"}
	
	Write-Host "..Downloading latest PStools"
	$destFile = Join-Path -Path $PSToolsTemp -ChildPath '\PSTools.zip'
	$PSToolsSrcUrl = "https://download.sysinternals.com/files/PSTools.zip"
	Invoke-WebRequest -Uri $PSToolsSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	

	#Unzip archive
	UnzipFile -zipfile $destFile -destpath $PSToolsTemp
		
	#Copy files from temporary folder to bin-folder
	Write-Host "..Copying necessary PS Tools Binaries"
	$NecesssaryPSTools = "psfile.exe","psinfo.exe","pslist.exe","psloggedon.exe","psservice.exe"
	foreach ($pstool in $NecesssaryPSTools) {
		write-host "..Copying $pstool into modules"
		$pscopysrcfile = Join-Path -Path $PSToolsTemp -ChildPath $pstool
		$pscopydstfile = Join-Path -Path $kapedestfolder"KAPE\Modules\bin\" -ChildPath $pstool
		Copy-Item -path $pscopysrcfile -destination $pscopydstfile
	}
	#Clean up of PSToolsTemp-folder
	Remove-Item -Path $PSToolsTemp -Recurse -force
	Write-Host "..Temporary PSfolder with content removed"

	#
	# Download Autorunsc
	#
	Write-Host "..Downloading latest AutoRunsC"
	$destFile = Join-Path -Path $kapedestfolder -ChildPath 'KAPE\Modules\bin\autorunsc.exe'
	$AutorunscSrcUrl = "http://live.sysinternals.com/autorunsc.exe"
	Invoke-WebRequest -Uri $AutorunscSrcUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
	
}

function DownloadKAPEAtea3rdPartyFiles{
	Write-Host "Downloading 3rd party tools Atea-files"
	$AteaFiles = "!Atea_live_all.mkape","!Atea_live_memdump.mkape","!Atea_live_sysinternals.mkape"
	foreach ($file in $AteaFiles) {
		$KapeSrcUrl = "https://raw.githubusercontent.com/ateanorge/airt/master/kape/$file"
		$KapeDstfile = Join-Path -Path $kapedestfolder"KAPE\Modules\Atea\" -ChildPath $file
		#$KapeDstfile = Join-Path -Path $kapedestfolder"KAPE\Modules\" -ChildPath $file
		Invoke-WebRequest -Uri $KapeSrcUrl -OutFile $KapeDstfile -ErrorAction:Stop -UseBasicParsing
			Write-Host "..$file downloaded"
	}
}

#Param switcher - Halp needed!
if($help) {
	$script = $MyInvocation.MyCommand.Path
	
	write-host ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('LCosLCwqLCwsKioqKioqKiwsLCwsKioqKiosLCwsKioqKioqKiwqKioqLCwsLCwsLCosKioqKioqKioqKioqKioqKioqKioqKioqKioqKioKKiosLCwqKiosKiosKioqKioqLCwsLCwqKioqKioqL0BAQEBAIygvKi8qKiwqLCoqKioqKiovKioqLCoqLyoqKioqKioqKioqKioqKi8vKioKLCoqKiwqKioqKiwsLCwsLCwsLCosLCwqKiomQEBAQEBAQEAmQEBAQCZALyoqKioqLCoqKioqKi8qLyoqLyoqKiovKioqKiovKioqKioqKioKLCoqLCwsLCwsKioqKiwqKioqKioqKioqQEBAQEBAQEBAQEBAQEBAQEAmQEBAQCgqKioqKioqKioqKioqKioqKioqKiwqKioqKioqLyoqKioKLCosKiwqKiosKiosLCwqKioqLCoqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqKioqKioqKioqKioqKioqKioqKioqKioqKiovKioqKioKKiwsKiosKiosLCwqLCosKioqKiwsKipAJkBAQEBAQEBAQEAmQEBAQEBAQEBAQEAjKioqKioqKioqKioqKioqKioqLyoqKioqKioqLyoqLCoKKiwqKiwsLCwqLCoqLCwqLCoqKioqKi9AQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEAqKioqKioqKiwsKioqKioqKioqKioqKioqKioqKioqKioKLCwsKiosKiwsKiwsLCwsLCoqKioqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCYqKioqKiosKiosKioqKioqKioqKioqLyoqKioqLyoqKioKKiosLCwsLCosKiwqLCwqKiosLCwsLCooQEAmQEBAQEBAQEBAQEBAQEBAQEBAQCoqKiwqKiwsKioqLCwqKioqKioqKioqKioqKioqKioqKi8KLCosLCwsKiwsLCosLCwsLCoqKiwqLCwsJiZAQEBAQEBAQEBAQEBAQEBAQEAmKioqKioqKiwsKioqLCoqKioqKi8qKi8qKioqKioqKioqKioKKiosKiosKiwqLCosLCwsKiosKiwqLCwqL0BAQEBAQEBAQEBAQEBAQEBAQCYqKioqKioqKioqLCoqKioqKioqKiovKioqKioqKioqKioqKioKKiwsLCosLCoqLCosLCoqKioqLyosKiwsKkBAQEBAQEBAQEBAQEBAQEBAJS8vLyovKioqKioqKioqKiwsKioqKioqKioqKioqKioqKi8vKioKKiosLCwqKioqKioqLy8mJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCYqKioqKioqKioqKioqKioqKioqKioqKi8qKioKKiwsKiwqKiovQEBAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCMqKioqKioqKioqKioqKioqKioqKioqKioKLCoqLCwqKkBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAKCoqKioqKioqKi8qKioqKioqKioqKi8KLCosKiwqQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqLyoqKioqKioqKiovKioqKioqKioKKiwqKipAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIyoqKioqKioqLyoqKioqKioqKioKLCwqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAvKioqKioqKioqKioqLyoqKioKLCoqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQC8qKioqKioqKioqKioqKioKKiosKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIyoqKioqKioqKioqKioKKiwqKipAQEBAQEBAQEBAQEBAQEBAQCZAQEAmQEBAQCZAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCZAQEBAQCZAQEBAJigqKi8qKioqKioqKioKKioqLCojQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAjKioqKioqKioqKi8KLCwsKioqQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQCZAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBALyoqKiovKioqKioKKiosKioqQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAIyoqKioqKiovKioKKiwqKioqKihAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBALyovKioqKioqKioKKiwsLCwqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQCMqKioqKi8qKioqKioqKioKLCosLCoqLyoqJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqKioqKioqKioqKioqKioqKioKLCwqLCoqKioqL0BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAoKioqKi8KKiwqKioqKioqKipAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAqKioKKioqKioqKioqKiooQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBALy8KKioqKioqKioqKiovL0BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAKioKKioqKioqKioqKioqKiNAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCZAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBALyoKKioqKioqKioqKioqKi8mQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAjKi8KKioqKioqKioqKioqKioqJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCoqKi8KKioqKioqKioqKioqKioqKkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCUqKiovKioKKioqKioqKioqKioqKiovLy9AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkBAQEBAQEBAQEBAQCMqKi8qKioqKioqKioKQEBAQEBAQEBAQEBAQEBAQEBAQCgqQEAqI0BAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAlQEBAQEBAQCZAJSYjLyo=')))
	write-host -ForegroundColor Red	"Art thou seeking my wisdom? I bestow upon thee, the content of Get-Help $script"
	get-help $script -full
	
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
}else {
	Write-Host -ForegroundColor Red "Incorrect Download option."
}
	

