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

  #region Declare paths & other misc variables

    $appData = "$HOME/Library/Application Support/obs-studio"
    $globalIniPath = "$appData/global.ini"

    $profilePath = "$appdata/basic/profiles/$profileName"

    $profileIniPath = "$profilePath/basic.ini"

    $serviceConfigPath = "$profilePath/service.json"

    $sceneCollectionDir = "$(Split-Path $profilePath -Parent)/scenes/$sceneCollectionName"
    $sceneCollectionPath = "$sceneCollectionDir/$sceneCollectionName"

    $countdownPluginPath = "$PSScriptRoot/submodules/obs-advanced-timer/advanced-timer.lua"

    $defaultVer = 436207616

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
    $centerSnapping = $true

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

    $ChannnelSetup = $audioChannel
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
          "LastVersion"=$defaultVer;
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
      $profileIni    = @{
        "General"      = @{};
        "Video"        = @{};
        "Panels"       = @{};
        "SimpleOutput" = @{};
        "Output"       = @{
          "Mode" = "Simple";
          "RetryDelay" = 5;
          "MaxRetries" = 24;
        };
        "Audio"        = @{};
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
        "AuxAudioDevice1" = @{
          "name" =                      "Mic/Aux";
          "id" =                        "coreaudio_input_capture";
          "balance" =                   0.5;
          "deinterlace_field_order" =   0;
          "deinterlace_mode" =          0;
          "enabled" =                   $true;
          "flags" =                     0;
          "hotkeys" =                 @{
            "libobs.mute" =             @();
            "libobs.push-to-mute" =     @();
            "libobs.push-to-talk" =     @();
            "libobs.unmute" =           @();
          };
          "mixers" =                   255;
          "monitoring_type" =          2;
          "muted" =                    $false;
          "prev_ver" =                 $defaultVer;
          "private_settings" =         @{};
          "push-to-mute" =             $false;
          "push-to-mute-delay" =       0;
          "push-to-talk" =             $false;
          "push-to-talk-delay" =       0;
          "settings" = @{
            "device_id" =              "InputAudioDeviceIdString";
          };
          "sync" =                     140000000;
          "versioned_id" =             "coreaudio_input_capture";
          "volume" =                   0.9;

        };
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
                "hour": 10;
                "mode": "Specific time";
                "pause_hotkey": [
                  @{"key" = "OBS_KEY_SEMICOLON";}
                ];
                "reset_hotkey" = [
                  @{"key" = "OBS_KEY_SEMICOLON";}
                ];
                "source" = "Countdown";
                "stop_text" = "NOW!";
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
        "scene_order" = @(
          @{"name" = "Intro-Drone-Countdown-Scene";},
          @{"name" = "Black-Screne-Scene"},
          @{"name" = "Logo-Scene"},
          @{"name" = "Camera-Scene"},
          @{"name" = "White-Screne-Scene"},
          @{"name" = "Extra-Video-Scene"}
        );
        "sources" = @(
        #Countdown timer text layer
          @{
            "name" = "Countdown";
            "id" = "text_ft2_source";
            "balance" = 0.5;
            "deinterlace_field_order" = 0;
            "deinterlace_mode" = 0;
            "enabled" = $true;
            "flags" = 0;
            "hotkeys" = @{};
            "mixers" = 0;
            "monitoring_type" = 0;
            "muted" = $false;
            "prev_ver" = $defaultVer;
            "private_settings" = @{};
            "push-to-mute" = $false;
            "push-to-mute-delay" = 0;
            "push-to-talk" = $false;
            "push-to-talk-delay" = 0;
            "settings" = @{
              "color1" = 4289189796;
              "color2" = 4290337863;
              "drop_shadow" = $true;
              "font" = @{
                "face" = "Heiti SC";
                "flags" = 0;
                "size" = 256;
                "style" = "Light";
              };
              "outline" = $false;
            # Text below is a placeholder. Actual text to be retrieved automatically
              "text" = "NOW!!";
            };
            "sync" = 0;
            "versioned_id" = "text_ft2_source_v2";
            "volume" = 1.0;
          },
        #White Screen Layer
          @{
            "name" = "White-Screen-Layer";
            "id" = "color_source";
            "balance" = "0.5";
            "deinterlace_field_order" = 0;
            "deinterlace_mode" = 0;
            "enabled" = $true;
            "flags" = 0;
            "hotkeys" = @{};
            "mixers" = 0;
            "monitoring_type" = 0;
            "muted" = $false;
            "prev_ver" = $defaultVer;
            "private_settings" = @{};
            "push-to-mute" = $false;
            "push-to-mute-delay" = 0;
            "push-to-talk" = $false;
            "push-to-talk-delay" = 0;
          # There are no settings because this is the default color.  Changing the color
          # would require adding settings.
            "settings" = @{};
            "sync" = 0;
            "versioned_id" = "color_source_v3";
            "volume" = 1.0;
          },
        #Camera Layer
          @{
            "name" =                        "PTZ-Optics-Source";
            "id" =                          "av_capture_input";
            "balance" =                     0.5;
            "deinterlace_field_order" =     0;
            "deinterlace_mode" =            0;
            "enabled" =                     $true;
            "filters" =                     @(
              @{
                "balance" =                 0.5;
                "deinterlace_field_order" = 0;
                "deinterlace_mode" =        0;
                "enabled" =                 $true;
                "flags" =                   0;
                "hotkeys" =                 @{};
                "id" =                      "sharpness_filter";
                "mixers" =                  0;
                "monitoring_type" =         0;
                "muted" =                   $false;
                "name" =                    "Sharpen";
                "prev_ver" =                $defaultVer;
                "private_settings" =        @{};
                "push-to-mute" =            $false;
                "push-to-mute-delay" =      0;
                "push-to-talk" =            $false;
                "push-to-talk-delay" =      0;
                "settings" = @{
                    "sharpness" =           0.40000000000000000;
                };
                "sync" =                    0;
                "versioned_id": =           "sharpness_filter";
                "volume" =                  1.0

              },
              @{
                "balance" =                 0.5;
                "deinterlace_field_order" = 0;
                "enabled" =                 $true;
                "flags" =                   0;
                "hotkeys" =                 @{};
                "id" =                      "color_filter";
                "mixers" =                  0;
                "monitoring_type" =         0;
                "muted" =                   $false;
                "name" =                    "Color Correction";
                "prev_ver" =                $defaultVer;
                "private_settings" =        @{};
                "push-to-mute" =            $false;
                "push-to-mute-delay" =      0;
                "push-to-talk" =            $false;
                "push-to-talk-delay" =      0;
                "settings" =                @{
                  "gamma" =                 -0.3;
                  "saturation" =            0.25;
                };
                "sync" =                    0;
                "versioned_id" =            "color_filter";
                "volume" =                  1.0;
              }
            );
            "flags" =                   0;
            "hotkeys" =                 @{};
            "mixers" =                  0;
            "monitoring_type" =         0;
            "muted" =                   $false;
            "prev_ver" =                $defaultVer;
            "private_settings" =        @{};
            "push-to-mute" =            $false;
            "push-to-mute-delay" =      0;
            "push-to-talk" =            $false;
            "push-to-talk-delay" =      0;
            "settings" =                @{
              "buffering" =             $true;
              "color_space" =           1;
              "device" =                "deviceID";
              "device_name" =           "deviceName";
              "frame_rate" =            @{
                "denominator" = 1000000.0;
                "numerator" =   30000030.0;
              };
              "input_format" =          4294967295;
              "preset" =                "AVCaptureSessionPreset1280x720";
              "resolution" =            "{\n    \"height\": 1080,\n    \"width\": 1920\n}";
              "use_preset" =            "true";
              "video_range" =           2;
            };
            "sync" = 0;
            "versioned_id" = "av_capture_input";
            "volume" = 1.0;
          },
        #Drone Footage Layer
          @{},
        #White Scene
          @{},
        #Black Screen No Scene Contents
          @{
            "name" = "Black-Screen-Scene";
            "id" = "scene";
            "balance" = "0.5";
            "deinterlace_field_order" = 0;
            "deinterlace_mode" = 0;
            "enabled" = $true;
            "flags" = 0;
            "hotkeys" = @{};
            "mixers" = 0;
            "monitoring_type" = 0;
            "muted" = $false;
            "prev_ver" = $defaultVer;
            "private_settings" = @{};
            "push-to-mute" = $false;
            "push-to-mute-delay" = 0;
            "push-to-talk" = $false;
            "push-to-talk-delay" = 0;
            "settings" = @{
              "custom_size" = $false;
              "id_counter" = 2;
              "items" = @();
            };
            "sync" = 0;
            "versioned_id" = "scene";
            "volume" = 1.0;
          },
        #Extra Video Scene
          @{
            "name" = "Extra-Video-Scene";
            "id" = "scene";
            "balance" = "0.5";
            "deinterlace_field_order" = 0;
            "deinterlace_mode" = 0;
            "enabled" = $true;
            "flags" = 0;
            "hotkeys" = @{};
            "mixers" = 0;
            "monitoring_type" = 0;
            "muted" = $false;
            "prev_ver" = $defaultVer;
            "private_settings" = @{};
            "push-to-mute" = $false;
            "push-to-mute-delay" = 0;
            "push-to-talk" = $false;
            "push-to-talk-delay" = 0;
            "settings" = @{
              "custom_size" = $false;
              "id_counter" = 1;
              "items" = @();
            };
            "sync" = 0;
            "versioned_id" = "scene";
            "volume" = 1.0;
          },

        );
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
    $globalIni.BasicWindow.CenterSnapping = $centerSnapping

    $globalIni.PropertiesWindow.cx = $propertiesX
    $globalIni.PropertiesWindow.cy = $propertiesY

  #endregion

  #region Create the profile directory if it doesn't Existing
    if (-not (Test-Path $profilePath)) {
      New-Item -ItemType Directory -Path $profilePath
    }
  #endregion

  #region Set Streaming Key

    $serviceConfig.settings.key = $streamingKey

  #endregion

  #region Get Connected PTZ Camera, FocusRite, and CalDigit devices
  #Camera
  $connectedCameras = (Invoke-Command -ScriptBlock {system_profiler SPCameraDataType -json 2> /dev/null} | ConvertFrom-Json).SPCameraDataType

  $selectedCamera = $connectedCameras | Where-object {$_.'_name' -like "PTZ Optics*"} | Select-object -First 1

  if (-not $selectedCamera) {
    Clear-Host
    $selectAltCam = Read-Host -Prompt "No 'PTZ Camera' found.  Would you like to use $($connectedCameras[-1]._name)? [ yes | no ]"
    Clear-Host
    if ($selectAltCam -like "y*") {
      $selectedCamera = $connectedCameras[0]
    } else {
      Write-Host "Ok. please connect the camera and try again... Exiting..."
      Start-sleep -seconds 5
      exit
    }
  }
  Write-Host $selectedCamera.'_name'
  #Write-Host "Modifying the Config to use this Video Source..."

  #Audio In/Out
  $connectedAudio = (Invoke-Command -ScriptBlock {system_profiler SPAudioDataType -json 2> /dev/null} | ConvertFrom-Json).SPAudioDataType
  $connectedUSB = (Invoke-Command -ScriptBlock {system_profiler SPUSBDataType -json 2> /dev/null} | ConvertFrom-Json).SPUSBDataType

  #endregion

  #region Set Source/Monitoring device IDs in Scene Collection
    #Camera
    ($scenes.sources | Where-Object name -like "PTZ*Optics*").settings.device = $selectedCamera.'spcamera_unique-id'
    ($scenes.sources | Where-Object name -like "PTZ*Optics*").settings.device_name = $selectedCamera.'_name'

    #Audio Input
    $scenes.AuxAudioDevice1.settings.device_id = "AppleUSBAudioEngine:FocusRite:Scarlett 2i2 USB:$("whatitis"):$("SomeInt" ?? 1)),$("someInt")"

    #Monitoring device
    $profileIni.Audio.ChannelSetup = $ChannelSetup

  #endregion

  #region Write Out Config filters

    #Global INI file
    $globalIni | Set-IniContent -FilePath $globalIniPath

    #Streaming Service JSON Config
    $serviceConfig | ConvertTo-Json -Depth 5 | Out-File -FilePath $serviceConfigPath -Force

    #Profile Basic IniContent
    $profileIni | Set-IniContent -FilePath $profileIniPath

    #Profile Scene Collection
    $scenes | ConvertTo-Json -Depth 20 | Out-File -FilePath $sceneCollectionPath -Force

  #endregion
}
end{
  Write-Host "Operation appears to have been successful.  Exiting script and launching OBS..."
  Start-Sleep -seconds 5

}
