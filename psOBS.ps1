# This script is intended to gather all relevant local data
# regarding connected devices, and set up an OBS profile/scene
# collection with those details.
begin{
  #region Import Modules
    Import-Module $PSScriptRoot\submodules\PsIni\PsIni
  #endregion

  #region Define Global Settings
    $gridMode = $false
    $windowGeometry = "AdnQywADAAAAAAAuAAAAFwAABGQAAAMFAAAALgAAAC0AAARkAAADBQAAAAAAAAAABwAAAAAuAAAALQAABGQAAAMF"
    $dockState = "AAAA/wAAAAD9AAAAAQAAAAMAAAQ3AAAA7vwBAAAABvsAAAAUAHMAYwBlAG4AZQBzAEQAbwBjAGsBAAAAAAAAAL0AAACgAP////sAAAAWAHMAbwB1AHIAYwBlAHMARABvAGMAawEAAAC+AAAAvgAAAKAA////+wAAABIAbQBpAHgAZQByAEQAbwBjAGsBAAABfQAAAX4AAAC0AP////sAAAAeAHQAcgBhAG4AcwBpAHQAaQBvAG4AcwBEAG8AYwBrAQAAAvwAAACcAAAAnAD////7AAAAGABjAG8AbgB0AHIAbwBsAHMARABvAGMAawEAAAOZAAAAngAAAJ4A////+wAAABIAcwB0AGEAdABzAEQAbwBjAGsCAAACIgAAAcwAAAK8AAAAyAAABDcAAAHPAAAABAAAAAQAAAAIAAAACPwAAAAA"
    $previewEnabled = $true
    $alwaysOnTop = $true
    $sceneDuplicationMode = $true
    $swapScenesMode = $true
    $editPropertiesMode = $false
    $previewProgramMode = $true
    $dockIsLocked = $false
    $verticalVolume = $true

    $propertiesX = 720
    $propertiesY = 580

    $profileName = "fbc-default-profile"
    $profileDir = "fbc-default-profile"
    $sceneCollectionName = "fbc-default-scenes"
    $sceneCollectionFile = "fbc-default-scenes"

  #endregion

  #region Define Profile Settings

  #endregion

  #region Define Scene collection

  #endregion

  #region Get Existing Config
    $globalIni = Get-IniContent "$HOME/Library/Application Support/obs-studio/global.ini"
  #endregion
}

process{
  #region Set Global Settings

    $globalIni.Basic.Profile = $profileName
    $globalIni.Basic.ProfileDir = $profileDir
    $globalIni.Basic.sceneCollectionName = $sceneCollectionName
    $globalIni.Basic.sceneCollectionFile = $sceneCollectionFile

    $globalIni.BasicWindow.gridMode = $false
    $globalIni.BasicWindow.geometry = $windowGeometry
    $globalIni.BasicWindow.DockState = $dockState
    $globalIni.BasicWindow.AlwaysOnTop = $alwaysOnTop
    $globalIni.BasicWindow.SceneDuplicationMode = $sceneDuplicationMode
    $globalIni.BasicWindow.SwapScenesMode = $swapScenesMode
    $globalIni.BasicWindow.EditPropertiesMode = $editPropertiesMode
    $globalIni.BasicWindow.PreviewProgramMode = $previewProgramMode
    $globalIni.BasicWindow.DocksLocked = $dockIsLocked
    $globalIni.BasicWindow.VerticalVolControl = $verticalVolume

    $globalIni.PropertiesWindow.cx = $propertiesX
    $globalIni.PropertiesWindow.cy = $propertiesY

  #endregion

  $connectedCameras = (Invoke-Command -ScriptBlock {system_profiler SPCameraDataType -json 2> /dev/null} | ConvertFrom-Json).SPCameraDataType

  $selectedCamera = $connectedCameras | Where-object {$_.'_name' -like "PTZ Optics*"} | Select-object -First 1

  if (-not $selectedCamera) {
    Clear-Host
    $selectAltCam = Read-Host -Prompt "No 'PTZ Camera' found.  Would you like to use $($connectedCameras[0]._name)? [ yes | no ]"
    Clear-Host
    if ($selectAltCam -like "y*") {
      $selectedCamera = $connectedCameras[0]
    } else {
      Write-Host "Ok. please connect the camera and try again... Exiting..."
      Start-sleep -seconds 5
      exit
    }
  }
  Write-Host $selectedCamera._name
  Write-Host "Loading Default Config..."

  # Get default Config
  $sceneCollection = Get-Content .\fbc-SceneCollectionDefault.json | ConvertFrom-Json
}
end{
  Write-Host "Exiting"
}
