# This script is intended to gather all relevant local data
# regarding connected devices, and set up an OBS profile/scene
# collection with those details.
begin{
  #region Import Modules
    Import-Module $PSScriptRoot\submodules\PsIni\PsIni
  #endregion

  #region Basic Config
  #endregion

  #region Declare paths

    $globalIniPath = "$HOME/Library/Application Support/obs-studio/global.ini"


  #endregion

  #region Define Global Settings
    $gridMode = $false
    # Window Geometry & Dock State- This is some kind of B64 string, but at present
    # you can just use OBS to generate it.
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
    # Canvas size is the size of the Video capable of having objects dragged to it.DESCRIPTION
    # 1920 x 1080 should allow for 1080p streaming when this becomes available. Output size
    # would need to be adjusted to make that final.
    $canvasX = 1920
    $canvasY = 1080

    # Output size is the format of the scaled output that will be sent to the streaming service
    $outputX = 1280
    $outputY = 720

    # Generally Mono is pretty safe.
    $audioChannel = "Mono"

    #Don't mess with these settings unless you know what you are doing
    $panelCookieId = "6AB072021E3861CE"
    $fpsType = 0
    $FPSCommon = 60
    $vBitrate = 3530
    $streamEncoder = "x264"
    $recQuality = "Stream"

    $mode = "Simple"

    $MonitoringDeviceName = $null
    $MonitoringDeviceId = $null


  #endregion

  #region Define Scene collection

  #endregion

  #region Get Existing Config

    $globalIni = Get-IniContent $globalIniPath

  #endregion
}

process{
  #region Set Global INI Settings

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
