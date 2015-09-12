unit update;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF Windows} ShellApi, Windows, {$ENDIF}
  {$IFDEF Linux} BaseUnix, {$ENDIF}
  Classes, SysUtils,
  fphttpclient, Forms, Dialogs, Controls, working, lib, FileUtil;

const
  ONLINE_VER_URL = 'http://www.newsfromgod.com/saveme.ver';
  {$IFDEF Windows}
  ONLINE_EXE_URL = 'http://www.newsfromgod.com/saveme.exe';
  {$ENDIF}
  {$IFDEF Linux}
  ONLINE_EXE_URL = 'http://www.newsfromgod.com/saveme.linux64';

  {$ENDIF}

function GetFromURL(const URL: string; const FileName: string = ''): string;
function UpdateIfNeeded(): boolean;
procedure RestartExe();

implementation

uses
  main; //For VERSION

function GetFromURL(const URL: string; const FileName: string = ''): string;
var
  Httpc: TFPHTTPClient;
begin
  Httpc := TFPHttpClient.Create(nil);
  Result := '';
  try
    if FileName <> '' then
      Httpc.Get(URL, FileName)
    else
      Result := Httpc.Get(URL);
  finally
    FreeAndNil(Httpc);
  end;
end;

procedure RestartExe();
var
  AppName: PChar;
  Output: string;
begin
  Output := '';
  AppName := PChar(Application.ExeName);
  //ShellExecute(MainForm.Handle, 'open', AppName, nil, nil, SW_SHOWNORMAL);
  RunCmd(Application.ExeName, Output);
  MainForm.Close;
end;

function UpdateIfNeeded(): boolean;
var
  BakName,OnlineVer: ansistring;
  Res: integer;
begin
  //Old backup name
  Result := False;
  BakName := Format('%s.old', [Application.ExeName]);


  //Get online version and delete old backup from previous update
  try
    OnlineVer:=  GetFromURL(ONLINE_VER_URL);
  except
    on E: Exception do
    begin
      MessageDlg('Problem accessing online update. Click OK to continue.',mtError,[mbOK],0);
      //Assume there is no update
      OnlineVer:=VERSION;
    end;
  end;

  //Deleting it here gives enough time for previous
  //running executable to close (due to RestartEXE)
  DeleteFile(PChar(BakName));

  if VERSION <> OnlineVer then
  begin
    Res := MessageDlg(
      'Update available, we recommend you download it. Do you want to update?',
      mtConfirmation, mbYesNo, 0);
    if Res = mrYes then
    begin
      //Rename original executable
      //BakName := Format('%s%s.old', [GetTempDir(),ExtractFileName(Application.ExeName)]);
      if RenameFile(Application.ExeName, BakName) then
      begin
        try
          //Save new executable in the original name and place
          ShowWorking();
          GetFromURL(ONLINE_EXE_URL, Application.ExeName);
          {$IFDEF Linux} FpChmod(Application.ExeName, &751 ); {$ENDIF}
          Result := True;
          HideWorking();
          MessageDlg('Update completed.', mtInformation, [mbOK], 0);
          Result:=True;
          RestartExe();
        except
          on E: Exception do
          begin
            HideWorking();
            RenameFile(BakName, Application.ExeName);
            MessageDlg('Update failed:' + LineEnding + E.Message, mtError, [mbOK], 0);
          end;
        end;
      end

      else
        MessageDlg('Unable to rename executable.', mtError, [mbOK], 0);
    end;
  end;
end;

end.
