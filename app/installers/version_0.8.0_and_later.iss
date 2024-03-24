; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Profit Taker Analytics"
#define MyAppVersion "0.9.1"
#define MyAppPublisher "Basi"
#define MyAppURL "https://basi.is-a.dev/pta"
#define MyAppExeName "profit_taker_analyzer.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{F1DF8DC8-C888-44E4-9199-720271B5017B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf}\..\Profit-Taker-Analytics
DisableDirPage=no
DisableProgramGroupPage=yes
LicenseFile=C:\Github\portfolio\ptdocssource\docs\docs\eula.md
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputBaseFilename=pta_0.9.1
SolidCompression=yes
Compression=lzma2/ultra64
LZMAUseSeparateProcess=yes
LZMADictionarySize=1048576
LZMANumFastBytes=273
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\update\*"; DestDir: "{app}\update"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\irondash_engine_context_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\super_native_extensions.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\super_native_extensions_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Github\Profit-Taker-Analytics\app\build\windows\x64\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Dirs]
Name: {app}\storage

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

