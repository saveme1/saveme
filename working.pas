unit working;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, LCLIntf;

type

  { TFormWorking }

  TFormWorking = class(TForm)
    ImageWorking: TImage;
    Label1: TLabel;
    Timer1: TTimer;
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ImageWorkingClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    FStartTicks: integer;
  public
    { public declarations }
  end;

procedure ShowWorking();
procedure HideWorking();

const
  ShowInterval = 5000;

var
  FormWorking: TFormWorking;
  ShowIntervalCnt: integer;


implementation

{$R *.lfm}

{ TFormWorking }

procedure TFormWorking.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TFormWorking.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Timer1.Enabled := False;
end;

procedure TFormWorking.FormShow(Sender: TObject);
begin
  Timer1.Enabled := True;
  ShowIntervalCnt := ShowInterval div Ord(Timer1.Interval);
end;

procedure TFormWorking.ImageWorkingClick(Sender: TObject);
begin
  Close;
end;

procedure TFormWorking.Label1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormWorking.Timer1Timer(Sender: TObject);
var
  Msg: ansistring;
begin
  if ShowIntervalCnt = 0 then
    Close
  else
  begin
    ShowIntervalCnt := ShowIntervalCnt - 1;
    Msg := 'Working ' + StringOfChar(#46, 3 - ShowIntervalCnt mod 3);
    Label1.Caption := Msg;
  end;
end;

procedure ShowWorking();
begin
  if Assigned(FormWorking) then
  begin
    FormWorking.ShowOnTop;
    Application.ProcessMessages;
  end;
end;

procedure HideWorking();
begin
  if Assigned(FormWorking) then
    FormWorking.Close;
end;

begin
end.

