unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, content, IpHtml, lib, protection;

type

  { TFormSettings }

  TFormSettings = class(TForm)
    BitBtnProtect: TBitBtn;
    BitBtnCancel: TBitBtn;
    BitBtnOK: TBitBtn;
    BitBtnReload: TBitBtn;
    Button1: TButton;
    FontDialog1: TFontDialog;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    MemoInfo: TMemo;
    Panel1: TPanel;
    procedure BitBtnOKClick(Sender: TObject);
    procedure BitBtnCancelClick(Sender: TObject);
    procedure BitBtnProtectClick(Sender: TObject);
    procedure BitBtnReloadClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);

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

procedure TFormSettings.Button1Click(Sender: TObject);
begin
  FontDialog1.Execute;
  MainFont := FontDialog1.Font;
  Application.MainForm.Font := MainFont;
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
      SetSafeDNS(); //Force setting of safe DNS server
  end
  else
    //If not protected we simply pick the default safe DNS server
    SetSafeDNS();
  FormSettings.Hide;
end;

procedure TFormSettings.BitBtnReloadClick(Sender: TObject);
begin
  UnpackContentIfNeeded;
end;

procedure TFormSettings.UpdateMemo();
var
  Info, DNSServer: ansistring;
  {$IFDEF Windows}
  NetIfList: tNetworkInterfaceList;
  IfInfo: tNetworkInterface;
  {$ENDIF}

begin
  //Working directory and DNS Server
  DNSServer := GetDNSServer();
  Info := 'Working dir: ' + GetCurrentDirUTF8() + LineEnding;
  Info := Info + 'DNS Server: ' + DNSServer + LineEnding;

  {$IFDEF Windows}
  //Show windows interfaces
  Info := Info + 'Interface for DNS Srvr: ' + NetInterfaceForDNSServer(DNSServer) +
    LineEnding;

  // FIXME
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

  MemoInfo.Text := Info;
end;

procedure TFormSettings.FormShow(Sender: TObject);
begin
  UpdateMemo();
end;

procedure TFormSettings.Label1Click(Sender: TObject);
var
  Res: integer;
begin
  Res := MessageDlg('Are you sure?', mtWarning, mbYesNoCancel, 0);
  if Res = mrYes then
    SetDNSServers(['dhcp']);
end;

end.
