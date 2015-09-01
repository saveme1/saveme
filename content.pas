unit content;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  IpHtml, textstrings, Zipper
  {$IFDEF Windows}
  ,Windows
  {$ENDIF};

procedure ShowContent(HtmlPanel: TIpHtmlPanel; What: string);
procedure ShowTreeContent(HtmlPanel: TIpHtmlPanel; NodeText: string);


implementation

procedure UnpackContentIfNeeded();
var
  UnZipper: TUnZipper;
  TestFile: ansistring;
  ZipFile: ansistring;

  procedure UnpackResource();
  var
    S: TResourceStream;
    F: TFileStream;
  begin
    // create a resource stream which points to our resource
    S := TResourceStream.Create(HInstance, 'HTML', RT_RCDATA);
    // Replace RT_RCDATA with ??? with what?
    try
      // create a file mydata.dat in the application directory
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
  end;

begin
  TestFile := GetAppConfigDir(False) + 'html/en/about.html';
  if not FileExists(TestFile) then
  begin
    ZipFile := GetAppConfigDir(False) + 'html.zip';
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
end;

function GetContent(what: ansistring): string;
var
  Buf: TTextStrings;
var
  Src: ansistring;
begin
  UnpackContentIfNeeded();
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
