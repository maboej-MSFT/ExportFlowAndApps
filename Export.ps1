##Uninstall-Module -Name SharePointPnPPowerShellOnline -AllVersions

##Install-Module -Name PnP.PowerShell -Force -AllowClobber -Scope CurrentUser

# Download from https://go.microsoft.com/fwlink/?linkid=2006349
##Import-Module .\Microsoft.PowerApps.Administration.PowerShell.psm1 -Force
##Import-Module .\Microsoft.PowerApps.PowerShell.psm1 -Force

Connect-PnPOnline -Url "https://maboejtest.sharepoint.com/sites/FlowAppsBackup"
Add-PowerAppsAccount 


 ## Create doc lib per environment
 foreach ($env in Get-PnPFlowEnvironment)
 {
  $envname=$env.Properties.DisplayName.Replace("(Default)", "")
  
   New-PnPList -Title  $envname -Template DocumentLibrary -OnQuickLaunch -ErrorAction SilentlyContinue
 }



## upload backup 


 foreach ($env in Get-PnPFlowEnvironment)
 {
 $envname=$env.Properties.DisplayName.Replace("(Default)", "")
 Write-Host "Getting All Flows in " $env.Properties.DisplayName "Environment"
$flows = Get-PnPFlow -Environment $env -AsAdmin #Remove -AsAdmin Parameter to only target Flows you have permission to access

Write-Host "Found $($flows.Count) Flows to export..."

foreach ($flow in $flows) {

    Write-Host "Exporting as ZIP & JSON... $($flow.Properties.DisplayName)"
    $filename = $flow.Properties.DisplayName.Replace(" ", "")
    $filenameSPO = $flow.Name+"-"+$flow.Properties.DisplayName.Replace(" ", "")
    $filenameSPOSafename= $filenameSPO.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    $timestamp = Get-Date -Format "yyyymmddhhmmss"
    $exportPath = "$($filename)_$($timestamp)"
    $exportPath = $exportPath.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    Export-PnPFlow -Environment $Env -Identity $flow.Name -PackageDisplayName $flow.Properties.DisplayName -AsZipPackage -OutPath "$exportPath.zip" -Force
    ##Export-PnPFlow -Environment $FlowEnv -Identity $flow.Name | Out-File "$exportPath.json"
   
    Add-PnPFile -Path "$exportPath.zip" -Folder  $envname.Replace("&","") -NewFileName "$filenameSPOSafename.zip"
   

}
}


## apps

 
 foreach ($env in Get-PnPFlowEnvironment)
 {
 
 $envname=$env.Properties.DisplayName.Replace("(Default)", "")
 Write-Host "Getting All Apps in " $env.Properties.DisplayName "Environment"

 
$apps=Get-PowerApp -EnvironmentName $env.Name

Write-Host "Found $($apps.Count) Apps to export..."


foreach ($app in $apps)
{
$appUri=$app.Internal.properties.appUris.documentUri

Write-Host "Exporting as msapp... $($app.DisplayName)"
    $filename = $app.DisplayName.Replace(" ", "")
    $filename = $filename.Replace("[", "")
    $filename = $filename.Replace("]", "")
    $filenameSPO = $app.AppName+"-"+$app.DisplayName.Replace(" ", "")
    $filenameSPO = $filenameSPO.Replace("[", "")
    $filenameSPO = $filenameSPO.Replace("]", "")
    $filenameSPOSafename= $filenameSPO.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    $timestamp = Get-Date -Format "yyyymmddhhmmss"
    $exportPath = "$($filename)_$($timestamp)"
    $exportPath = $exportPath.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
   

Invoke-WebRequest -Uri $appUri.value -OutFile "$exportPath.msapp"
Add-PnPFile -Path "$exportPath.msapp" -Folder  $envname.Replace("&","") -NewFileName "$filenameSPOSafename.msapp"

}

}





