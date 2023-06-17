#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")

#define MyAppName "Kyber Mod Manager"
#define MyAppVersion "1.0.10"
#define MyAppPublisher "liam"
#define MyAppURL "https://reax.at"
#define AppId "Kyber Mod Manager"
#define MyAppExeName "kyber_mod_manager.exe"

[Setup]
AppId={#AppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
SetupIconFile=app_icon.ico
OutputDir=./
OutputBaseFilename=KMM Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern


#include <idp.iss>

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\dart_discord_rpc_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\discord-rpc.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\kyber_mod_Manager.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\sentry_flutter_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\windows_taskbar_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\flutter_platform_alert_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\system_theme_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\auto_update_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\desktop_drop_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\flutter_acrylic_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\system_tray_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\webview_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\WebView2Loader.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\dynamic_env_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\protocol_handler_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{tmp}\chrome-win.zip"; DestDir: "{app}"; Flags: external deleteafterinstall ignoreversion skipifsourcedoesntexist; ExternalSize: 186331554
Source: "7za.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall;

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; AppUserModelID: "reax.KMM"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[UninstallDelete]
Type: filesandordirs; Name: "{app}\970485"

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  Result := True
  if (CurPageID = 9) and not DirExists(ExpandConstant('{app}\970485\chrome-win')) then 
  begin
    idpAddFile('https://storage.googleapis.com/chromium-browser-snapshots/Win_x64/970485/chrome-win.zip', ExpandConstant('{tmp}\chrome-win.zip'));
    idpDownloadAfter(wpReady);
    Result:= True;
  end;
end;

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
Filename: {tmp}\7za.exe; Parameters: "x ""{tmp}\chrome-win.zip"" -o""{app}\970485"" * -r -aoa"; Flags: runhidden runascurrentuser;
