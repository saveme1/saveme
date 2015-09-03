unit content;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  IpHtml, textstrings, Zipper, DateUtils, Dialogs, MD5
  {$IFDEF Windows}
  , Windows
  {$ENDIF};

procedure ShowContent(HtmlPanel: TIpHtmlPanel; What: string);
procedure ShowTreeContent(HtmlPanel: TIpHtmlPanel; NodeText: string);
procedure UnpackContentIfNeeded();



implementation

procedure UnpackContentIfNeeded();
var
  UnZipper: TUnZipper;
  HashFile, ZipFile: ansistring;

  function GetHTMLHash(): string;
  var
    tmpStream: TResourceStream;
  begin
    tmpStream := TResourceStream.Create(HInstance, 'HTMLVERSION', RT_RCDATA);
    try
      Result:= tmpStream.ReadAnsiString();
    finally
      tmpStream.Free;
    end;
  end;

  //Compare hash of html content with hash of zip file
  //return true if they are different
  function isContentOld(): boolean;
  var
    NewHash, OldHash: ansistring;
    FsIn: TFileStream;
  begin
    NewHash := GetHTMLHash();
    FsIn := TFileStream.Create(HashFile, fmOpenRead);
    try
      OldHash := FsIn.ReadAnsiString();
    finally
      FsIn.Free;
    end;

    if OldHash <> NewHash then
      Result := True
    else
      Result := False;
  end;

  procedure WriteZipHash();
  var
    Hash: ansistring;
    FsOut: TFileStream;

  begin
    Hash := MD5Print(MD5File(ZipFile));
    FsOut := TFileStream.Create(HashFile, fmCreate);
    try
      FsOut.WriteAnsiString(Hash);
    finally
      FsOut.Free;
    end;
  end;

  procedure UnpackResource();
  var
    S: TResourceStream;
    F: TFileStream;
  begin
    // create a resource stream which points to our resource
    S := TResourceStream.Create(HInstance, 'HTML', RT_RCDATA);
    try
      // create a file html.zip in the application directory
      if not DirectoryExists(GetAppConfigDir(False)) then
        MkDir(GetAppConfigDir(False));
      F := TFileStream.Create(ZipFile, fmCreate);
      try
        F.CopyFrom(S, S.Size); // copy data from the resource stream to file stream
      finally
        F.Free; // destroy the file stream
      end;
    finally
      S.Free; // destroy the resource stream
    end;
    WriteZipHash;
  end;

  procedure UnpackContent();
  begin
    UnpackResource;
    UnZipper := TUnZipper.Create;
    try
      UnZipper.FileName := ZipFile;
      UnZipper.OutputPath := GetAppConfigDir(False);
      UnZipper.Examine;
      UnZipper.UnZipAllFiles;
    finally
      UnZipper.Free;
      DeleteFile(PChar(ZipFile));
    end;
  end;

begin
  //Unpack content: html resource -> html.zip -> unzip
  // in config directory
  ZipFile := GetAppConfigDir(False) + 'html.zip';
  HashFile := GetAppConfigDir(False) + 'HTMLVERSION';

  if not FileExists(HashFile) or isContentOld() then
    UnpackContent;

end;

function GetContent(what: ansistring): string;
var
  Buf: TTextStrings;
var
  Src: ansistring;
begin
  Buf := TTextStrings.Create;
  Src := GetAppConfigDir(False) + 'html/en/' + what + '.html';
  Buf.LoadFromFile(Src);
  Result := Buf.Text;
  Buf.Free;
end;


procedure ShowContent(HtmlPanel: TIpHtmlPanel; What: string);
var
  Content: string;
begin
  Content := GetContent(What);
  HtmlPanel.SetHtmlFromStr(Content);
end;

procedure ShowTreeContent(HtmlPanel: TIpHtmlPanel; NodeText: string);
var
  What: ansistring;
begin
  //Remove spaces and ?
  What := StringReplace(NodeText, #32, '', [rfReplaceAll]);
  What := StringReplace(What, '?', '', [rfReplaceAll]);
  What := AnsiLowerCase(What);
  ShowContent(HtmlPanel, What);
end;

end.
