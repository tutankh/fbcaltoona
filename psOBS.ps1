# This script is intended to gather all relevant local data
# regarding connected devices, and set up an OBS profile/scene
# collection with those details.
begin{
  #region Import Modules
    Import-Module $PSScriptRoot\submodules\PsIni\PsIni
  #endregion

  #region Basic Config
    $profileName = "fbc-default-profile"
  #endregion

  #region Declare paths

    $appData = "$HOME/Library/Application Support/obs-studio"
    $globalIniPath = "$appData/global.ini"

    $profilePath = "$appdata/basic/profiles/$profileName"

    $profileIniPath = "$profilePath/basic.ini"

    $serviceConfigPath = "$profilePath/service.json"

    $sceneCollectionDir = "$(Split-Path $profilePath -Parent)/scenes/$sceneCollectionName"
    $sceneCollectionPath = "$sceneCollectionDir/$sceneCollectionName"

    $countdownPluginPath = "$PSScriptRoot/submodules/obs-advanced-timer/advanced-timer.lua"

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

    $profileDirName = $profileName
    $sceneCollectionName = "$profileName-scenes"
    $sceneCollectionFile = "$profileName-scenes"

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

  #region Get Existing Configs, Make Default templates

    #Global
    if (Test-Path $globalIniPath) {
      $globalIni = Get-IniContent $globalIniPath
    } else {
      $globalIni = @{
        "General"=@{
          "Pre19Defaults"=$false;
          "Pre21Defaults"=$false;
          "Pre23Defaults"=$false;
          "Pre24.1Defaults"=$false;
          "FirstRun"=$true;
          "LastVersion"=436207616;
        };
        "Basic"=@{};
        "BasicWindow"=@{};
        "ScriptLogWindow"=@{
          "geometry"="AdnQywADAAAAAAAAAAAAKwAAAlcAAAG6AAAAAAAAACsAAAJXAAABugAAAAAAAAAABwAAAAAAAAAAKwAAAlcAAAG6";
        };
        "PropertiesWindow"=@{};
        "scripts-tool"=@{
          "prevScriptRow"=0
        }
      }
    }

    #Profile
    if (Test-Path $profileIniPath){
      $profileIni = Get-IniContent $profileIniPath
    } else {
      $profileIni = @{
        "General"=@{};
        "Video"=@{};
        "Panels"=@{};
        "SimpleOutput"=@{};
        "Output"=@{};
        "Audio"=@{};
      }
    }

    #Service (Live Streaming)
    $streamingKey = Read-Host -Prompt "No Existing config was found for Live Streaming to Facebook.`nA new config will be generated, and you will need to get a streaming key by logging into Facebook.`nEnter the key here, then press [Enter] to continue."
    $serviceConfig = @{
      "settings"=@{
        "bwtest" = $false;
        "key" = $null;
        "server" = "rtmps://rtmp-api.facebook.com:443/rtmp/";
        "service" = "Facebook Live";
      };
      "type"="rtmp_common"
    }

    #Scenes and Sources
    if (-not (Test-Path $sceneCollectionDir)) {
      New-Item -ItemType Directory $sceneCollectionDir
    }
    if (Test-Path $sceneCollectionPath){
      $scenes = Get-Content $sceneCollectionPath | ConvertFrom-Json -Depth 20
    } else {
      $scenes = @{
        "AuxAudioDevice1" = @{};
        "current_program_scene" = "Black";
        "current_scene" = "Logo";
        "current_transition" = "Fade";
        "groups" = @();
        "modules" = @{
          "auto-scene-switcher" = @{
            "active" = $false;
            "interval" = 300;
            "non-matching_scene" = "";
            "switch_if_not_matching" = $false;
            "switches" = @();
          };
          "scripts-tool" = @(
            @{
              "path" = $countdownPluginPath;
              "settings" = @{
                "hour":
              };
            },
          );
        };
        "name" = $sceneCollectionName;
        "preview_locked" = $false;
        "quick_transitions"=@(
          @{
            "id" = 1;
            "duration" = 3000;
            "fade_to_black" = $false;
            "hotkeys" = @();
            "name" = "CrossFade-3000";
          },
          @{
            "id" = 2;
            "duration" = 1500;
            "fade_to_black" = $false;
            "hotkeys" = @();
            "name" = "CrossFade-1500"
          },
          @{
            "id" = 3;
            "duration" = 1000;
            "fade_to_black" = $false;
            "hotkeys" = @();
            "name" = "Fade";
          }
        );
        "saved_projectors" = @();
        "scaling_enabled" = $false;
        "scaling_level" = 0;
        "scaling_off_x" = 0.0;
        "scaling_off_y" = 0.0;
        "scene_order" = @();
        "sources" = @();
        "transition_duration" = 300;
        "transitions" = @()
      }
    }
  #endregion
}

process{

  #region Set Global INI Settings

    $globalIni.Basic.Profile = $profileName
    $globalIni.Basic.ProfileDir = $profileDirName
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

  #region Create the profile directory if it doesn't Existing
    if (-not (Test-Path $profilePath)) {
      New-Item -ItemType Directory -Path $profilePath
    }
  #endregion

  #region Set Streaming Key and write out config

    $serviceConfig.settings.key = $streamingKey
    $serviceConfig | ConvertTo-Json -Depth 5 | Out-File -FilePath $serviceConfigPath -Force

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
