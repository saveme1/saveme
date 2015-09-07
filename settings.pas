unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, content, IpHtml, lib;

type

  { TFormSettings }

  TFormSettings = class(TForm)
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
    procedure BitBtnReloadClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
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

procedure TFormSettings.BitBtnReloadClick(Sender: TObject);
begin
  UnpackContentIfNeeded;
end;

procedure TFormSettings.FormShow(Sender: TObject);
var
  Info: ansistring;
  {$IFDEF Windows}
  NetIfList: tNetworkInterfaceList;
  IfInfo: tNetworkInterface;
  {$ENDIF}
begin
  Info := '';
  {$IFDEF Windows}
  GetNetworkInterfaces(NetIfList);
  for IfInfo in NetIfList do
  begin
    Info := Info + 'AddrNet: ' + IfInfo.AddrNet + LineEnding +
          //'CompName: ' + IfInfo.ComputerName + LineEnding +
          'AddrIP: ' + IfInfo.AddrIP + LineEnding +
          'Up?: ' + BoolToStr(IfInfo.IsInterfaceUp) + LineEnding +
          'Loopback?: ' + BoolToStr(IfInfo.IsLoopback) + LineEnding +
          LineEnding;
  end;
  {$ENDIF}
  Info := Info + 'Working dir: ' + GetCurrentDirUTF8() +LineEnding;
  MemoInfo.Text := Info;
end;

end.

