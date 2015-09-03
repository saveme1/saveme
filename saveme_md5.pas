program saveme_md5;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  md5 { you can add units after this };

type

  { TMD5 }

  TMD5 = class(TCustomApplication)
  protected
    procedure DoRun; override;
    procedure WriteMD5(FileNameIn, FileNameOut: string);

  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

  { TMD5 }

  procedure TMD5.WriteMD5(FileNameIn, FileNameOut: string);
  var
    Hash: ansistring;
    FsOut: TFileStream;
  begin
    Hash := MD5Print(MD5File(FileNameIn));
    FsOut := TFileStream.Create(FileNameOut, fmCreate);
    try
      FsOut.WriteAnsiString(Hash);
    finally
      FsOut.Free;
    end;

  end;

  procedure TMD5.DoRun;
  var
    ErrorMsg: string;
  begin
    // quick check parameters
    ErrorMsg := CheckOptions('h', 'help');
    If GetParamCount() < 2 then
      ErrorMsg := 'Usage: md5 <filein> <fileout>';

    if ErrorMsg <> '' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;

    // parse parameters
    if HasOption('h', 'help') then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    WriteMD5(GetParams(1),GetParams(2));

    // stop program loop
    Terminate;
  end;

  constructor TMD5.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TMD5.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TMD5.WriteHelp;
  begin
    { add your help code here }
    writeln('Usage: ', ExeName, ' -h');
  end;

var
  Application: TMD5;
begin
  Application := TMD5.Create(nil);
  Application.Title := 'MD5';
  Application.Run;
  Application.Free;
end.
