program saveme;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  main,
  protection,
  content,
  lib,
  settings,
  working,
  update,
  VersionSupport;

{$R *.res}

begin
  if ParamStr(1) = '-v' then
  begin
    WriteLn(GetFileVersion());
  end
  else
  begin
    RequireDerivedFormResource := True;
    Application.Initialize;
    Application.CreateForm(TMainForm, MainForm);
    Application.CreateForm(TFormSettings, FormSettings);
    Application.CreateForm(TFormWorking, FormWorking);
    Application.Run;
  end;
end.
