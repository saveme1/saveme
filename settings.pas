unit settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  content, IpHtml;

type

  { TFormSettings }

  TFormSettings = class(TForm)
    Button1: TButton;
    ButtonReload: TButton;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    MemoInfo: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonReloadClick(Sender: TObject);
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


procedure TFormSettings.ButtonCancelClick(Sender: TObject);
begin
  FormSettings.Hide;
end;

procedure TFormSettings.Button1Click(Sender: TObject);
begin
  FontDialog1.Execute;
  MainFont := FontDialog1.Font;
  Application.MainForm.Font := MainFont;
end;

procedure TFormSettings.ButtonOKClick(Sender: TObject);
begin
  FormSettings.Hide;
end;

procedure TFormSettings.ButtonReloadClick(Sender: TObject);
begin
  UnpackContentIfNeeded;
end;

procedure TFormSettings.FormShow(Sender: TObject);
Var Info: ansistring;
begin
  Info:='Working dir: ' + GetCurrentDirUTF8();
  MemoInfo.Text:=Info;
end;

end.

