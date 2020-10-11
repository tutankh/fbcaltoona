# This script is intended to gather all relevant local data
# regarding connected devices, and set up an OBS profile/scene
# collection with those details.

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
