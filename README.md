## KAPE
Only if **instructed** by Atea IRT, download KAPE from here: https://github.com/atea/airt/releases/ 


### Procedure 
 - Download KAPE.
 - Preferrably run it from on an USB on physical devices.
 - Start up cmd **as administrator**.
 - Issue the command underneat
    - Needs to be from an elevated powershell prompt.
    - Adjust drive letter as appropriate. (f.ex Change E:\ to whatever drive letter the USB drive)
    
### KAPE collection command
```powershell
# From elevated shell & Adjust drive letter as needed
.\kape.exe --tsource c: --tdest e:\airt\KAPE_OUT\%m_%d --target !Atea_default_collection.tkape,!SANS_Triage --zip KAPEtriage_%m_%d --gui
```