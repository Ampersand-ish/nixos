# DankMaterialShell (dms) — bar/launcher/lock/idle/notifications/wallpaper/polkit.
# Spawned by niri (spawn-at-startup "dms run"), so its systemd unit is off.
# settings.json is written declaratively via programs.dank-material-shell.settings
# (merged with the stylix target's theme/font/transparency keys); it captures the
# runtime settings.json (configVersion 18), so runtime UI edits last until the
# next rebuild.
{ inputs, ... }:
{
  flake.modules.homeManager.dms =
    { lib, ... }:
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.danksearch.homeModules.default
      ];

      programs.dank-material-shell = {
        enable = true;
        systemd.enable = false; # spawned by niri spawn-at-startup instead

        settings = {
          # Runtime UI choice: dynamic matugen theming (stylix target would set
          # "custom"; it still owns customThemeFile, unused while dynamic is on).
          currentThemeName = lib.mkForce "dynamic";
          currentThemeCategory = "dynamic";
          matugenScheme = "scheme-content";
          matugenSourceMode = "value";
          matugenTemplateNeovim = true;

          firstDayOfWeek = 0;
          clockFormat = "24h";
          weatherEnabled = false;
          networkPreference = "ethernet";

          enableRippleEffects = false;
          barElevationEnabled = false;
          showWorkspacePadding = true;
          waveProgressEnabled = false;
          audioVisualizerEnabled = false;
          modalDarkenBackground = false;
          textRenderQuality = 2;
          fontWeight = 500;
          batteryNotifyCritical = false;
          lockBeforeSuspend = true;
          lockScreenShowWeather = false;

          niriOverviewLauncherStyle = "spotlight";
          launcherStyle = "spotlight";
          launcherUseOverlayLayer = true;
          launcherLogoMode = "os";
          launcherLogoColorOverride = "primary";

          # The old default barConfig (noctalia-equivalent: top, auto-hide)
          # as evolved at runtime: island mode, runningApps/tray/spacer widgets.
          barConfigs = [
            {
              id = "default";
              name = "Main Bar";
              enabled = true;
              position = 0;
              screenPreferences = [ "all" ];
              showOnLastDisplay = true;
              leftWidgets = [
                "workspaceSwitcher"
                {
                  id = "runningApps";
                  enabled = true;
                  runningAppsCompactMode = true;
                  runningAppsGroupByApp = true;
                  runningAppsCurrentWorkspace = true;
                  runningAppsCurrentMonitor = true;
                }
              ];
              centerWidgets = [
                "music"
                "clock"
                "weather"
              ];
              rightWidgets = [
                {
                  id = "systemTray";
                  enabled = true;
                  trayUseInlineExpansion = false;
                  trayAutoOverflow = true;
                  trayPopupSingleLine = false;
                }
                {
                  id = "spacer";
                  enabled = true;
                  size = 10;
                }
                "clipboard"
                "notificationButton"
                "controlCenterButton"
              ];
              spacing = 4;
              innerPadding = 4;
              bottomGap = 0;
              transparency = 1.0;
              widgetTransparency = 1.0;
              squareCorners = false;
              noBackground = false;
              gothCornersEnabled = true;
              gothCornerRadiusOverride = true;
              gothCornerRadiusValue = 12;
              borderEnabled = false;
              borderColor = "surfaceText";
              borderOpacity = 1.0;
              borderThickness = 1;
              fontScale = 1.0;
              autoHide = true;
              autoHideDelay = 250;
              openOnOverview = false;
              visible = true;
              popupGapsAuto = true;
              popupGapsManual = 4;
              island = true;
              islandFloating = false;
              islandUseOverlayLayer = false;
              islandHomeCompactTight = true;
              widgetPadding = 8;
              barInsetPadding = 4;
              maximizeWidgetIcons = false;
              maximizeWidgetText = false;
              removeWidgetPadding = false;
              widgetOutlineEnabled = false;
              shadowIntensity = 0;
              attachToScreenEdge = false;
              hoverPopouts = true;
              maximizeDetection = true;
              islandSatellitePosition = "edges";
              islandSatelliteGap = 48;
              islandInteractionMode = "hybrid";
              islandReducedMotion = false;
              barLengthPadding = 0;
              islandCompactThickness = 38;
              islandOuterGap = 4;
              islandAlongOffset = 0;
              islandHomeClockDisplay = "time";
              islandPalette = "default";
              islandHighContrast = false;
              islandMediaClockVisible = true;
              islandSatellitesEnabled = true;
              islandSatelliteBackground = false;
              islandSatelliteGothCorners = true;
            }
          ];

          desktopClockCustomColor = {
            r = 1;
            g = 1;
            b = 1;
            a = 1;
            hsvHue = -1;
            hsvSaturation = 0;
            hsvValue = 1;
            hslHue = -1;
            hslSaturation = 0;
            hslLightness = 1;
            valid = true;
          };

          systemMonitorCustomColor = {
            r = 1;
            g = 1;
            b = 1;
            a = 1;
            hsvHue = -1;
            hsvSaturation = 0;
            hsvValue = 1;
            hslHue = -1;
            hslSaturation = 0;
            hslLightness = 1;
            valid = true;
          };

          builtInPluginSettings = {
            dms_settings_search = {
              trigger = "?";
            };
            dms_clipboard_search = {
              trigger = "cb";
            };
            dms_power = {
              trigger = "pw";
            };
            dms_qr_generator = {
              trigger = "qrg";
            };
            dms_notepad = {
              enabled = true;
            };
            dms_sysmon = {
              enabled = true;
            };
          };

          barInsetPaddingShared = 4;
          barInsetPaddingSyncAll = true;
          configVersion = 18;
        };
      };

      # dsearch backs file results in the DMS launcher; systemd user service
      # (`dsearch serve`) starts on login.
      programs.dsearch.enable = true;
      programs.dsearch.config = {
        index_paths = [
          {
            path = "~";
            max_depth = 6;
            exclude_hidden = true;
            # Extends dsearch's built-in default exclude list.
            merge_default_exclude_dirs = true;
            exclude_dirs = [
              "secrets"
              "nixos"
              "Wallpapers"
              "Steam"
            ];
          }
        ];
      };
    };
}
