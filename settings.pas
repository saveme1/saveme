unit settings;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF Windows}
  Registry,
  {$ENDIF}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, IniPropStorage, DBCtrls, content, IpHtml, lib, protection;

type

  { TFormSettings }

  TFormSettings = class(TForm)
    BitBtnProtect: TBitBtn;
    BitBtnCancel: TBitBtn;
    BitBtnOK: TBitBtn;
    BitBtnReload: TBitBtn;
    Button1: TButton;
    CheckBoxRunOnStartup: TCheckBox;
    CheckBoxShowLog: TCheckBox;
    CheckBoxAutoUpdate: TCheckBox;
    CheckBoxShowTrayIcon: TCheckBox;
    FontDialog1: TFontDialog;
    GroupBox1: TGroupBox;
    IniPropStorage1: TIniPropStorage;
    MemoInfo: TMemo;
    Panel1: TPanel;
    TrayIcon: TTrayIcon;
    procedure BitBtnOKClick(Sender: TObject);
    procedure BitBtnCancelClick(Sender: TObject);
    procedure BitBtnProtectClick(Sender: TObject);
    procedure BitBtnReloadClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBoxRunOnStartupOnChange(Sender: TObject);
    procedure CheckBoxShowLogChange(Sender: TObject);
    procedure CheckBoxShowTrayIconChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    procedure UpdateMemo();
    { private declarations }
  public
    { public declarations }
  end;

var
  FormSettings: TFormSettings;
  MainFont: TFont;

implementation

{$R *.lfm}

{ TFormSettings }
uses
  main;

procedure TFormSettings.Button1Click(Sender: TObject);
begin
  FontDialog1.Execute;
  MainFont := FontDialog1.Font;
  MainForm.SetFont(MainFont);
end;

procedure TFormSettings.CheckBoxRunOnStartupOnChange(Sender: TObject);
{$IFDEF Windows}
var
  Reg: TRegistry;
{$ENDIF}
begin
  {$IFDEF Windows}
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;  // For current user
    //Reg.RootKey := HKEY_LOCAL_MACHINE; // For all users
    Reg.Access := KEY_ALL_ACCESS;

    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False) then
    begin
      if CheckBoxRunOnStartup.Checked then
      begin
        // add startup entry
        Reg.WriteString('saveme', Application.ExeName);
        // CheckBoxRunOnStartup.Checked := True;
      end
      else
      begin
        // delete startup entry
        Reg.DeleteValue('saveme');
        //CheckBoxRunOnStartup.Checked := False;
      end;

      Reg.CloseKey;
    end
    else
      MessageDlg('Unable to add registry value', mtError, [mbOK], 0);

  finally
    if Assigned(Reg) then
      FreeAndNil(Reg);
  end;
  {$ENDIF}

  {$IFDEF Linux}
  {$ENDIF}
end;

procedure TFormSettings.CheckBoxShowLogChange(Sender: TObject);
begin
  UpdateMemo();
end;

procedure TFormSettings.CheckBoxShowTrayIconChange(Sender: TObject);
begin
  if CheckBoxShowTrayIcon.Checked then
    TrayIcon.Show
  else
    TrayIcon.Hide;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
  IniPropStorage1.IniFileName := GetAppConfigFile(False, True);
  IniPropStorage1.IniSection := 'settings';
  MemoInfo.Text := '--Log--';
  TrayIcon.Hint := isProtectedStr();
end;

procedure TFormSettings.BitBtnOKClick(Sender: TObject);
begin
  FormSettings.Hide;
end;

procedure TFormSettings.BitBtnCancelClick(Sender: TObject);
begin
  FormSettings.Hide;
end;

procedure TFormSettings.BitBtnProtectClick(Sender: TObject);
var
  Res: integer;
begin
  if isProtected() then
    //If protected we offer to switch to another DNS server
  begin
    Res := MessageDlg(
      'Your computer is already protected, do you want to do it again?',
      mtWarning, mbYesNoCancel, 0);
    if Res = mrYes then
    begin
      //We need to hide the settings form so that the
      //UAC dialog shows immediately and not blinking in
      //the taskbar (RunAsAdmin uses the main form Window handle)
      FormSettings.Hide;
      SetSafeDNS(); //Force setting of safe DNS servers
    end;
  end
  else
    //If not protected we simply pick the default safe DNS server
    SetSafeDNS();
  FormSettings.Hide;
  {$IFDEF Linux}
  MainForm.Restart();
  {$ENDIF}
end;

procedure TFormSettings.BitBtnReloadClick(Sender: TObject);
begin
  UnpackContentIfNeeded;
end;

procedure TFormSettings.UpdateMemo();
const
  GIT_VERSION = {$I saveme.tag} ;
var
  Info, DNSServer: ansistring;
  {$IFDEF Windows}
  NetIfList: tNetworkInterfaceList;
  IfInfo: tNetworkInterface;
  TmpStr: ansistring;
  {$ENDIF}

begin
  //Exit if we are not to show the log
  MemoInfo.Visible := CheckBoxShowLog.Checked;
  if not MemoInfo.Showing then
    Exit;

  //Date/Version/Compiler info, working directory and DNS Server
  try
    Info := '-- Log --' + LineEnding;
    Info := Info + {$I %DATE%} +'  ' + {$I %TIME%} +LineEnding;
    Info := Info + 'Version'#9#9': ' + GIT_VERSION + LineEnding;
    Info := Info + 'Target'#9#9': ' + {$I %FPCTARGETOS%} + ' ' +
          {$I %FPCTARGETCPU%} + LineEnding;
    Info := Info + 'Compiler'#9#9': ' + {$I %FPCVERSION%} + LineEnding;
    Info := Info + 'Working dir'#9': ' + GetCurrentDirUTF8() + LineEnding;

    DNSServer := GetDNSServer();
    Info := Info + 'DNS Server'#9': ' + DNSServer + LineEnding;

  {$IFDEF Windows}
    StoreOrigDNSServers(TmpStr);
    Info := Info + 'Orig. DNS Server(s): ' + TmpStr + LineEnding;

    //Show windows interfaces
    Info := Info + 'Interface for DNS Srvr: ' + NetInterfaceForDNSServer(DNSServer) +
      LineEnding;

    // { TODO : Settings memo to show all that info? }
    Info := Info + '--- Windows Interfaces ---' + LineEnding;
    GetNetworkInterfaces(NetIfList);
    for IfInfo in NetIfList do
    begin
      Info := Info + 'AddrNet: ' + IfInfo.AddrNet + LineEnding +
        //'CompName: ' + IfInfo.ComputerName + LineEnding +
        'AddrIP: ' + IfInfo.AddrIP + LineEnding + 'Up?: ' +
        BoolToStr(IfInfo.IsInterfaceUp, True) + LineEnding + 'Loopback?: ' +
        BoolToStr(IfInfo.IsLoopback, True) + LineEnding + LineEnding;
    end;
  {$ENDIF}

  finally
    MemoInfo.Text := Info;
  end;

end;

procedure TFormSettings.FormShow(Sender: TObject);
begin
  {$IFDEF Linux}
  CheckBoxRunOnStartup.Hint := 'Not available in Unix';
  CheckBoxRunOnStartup.ShowHint := True;
  CheckBoxRunOnStartup.Enabled := False;
  {$ENDIF}
  CheckBoxShowTrayIcon.Checked := TrayIcon.Visible;
  FontDialog1.Font := Application.MainForm.Font;
  UpdateMemo();
end;

end.
