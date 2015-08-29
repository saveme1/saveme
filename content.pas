unit content;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,
  IpHtml, textstrings;
procedure ShowContent(HtmlPanel: TIpHtmlPanel; What: string);


implementation

function GetContent(what: ansistring): string;
var Buf: TTextStrings;
var Src: ansistring;
begin
   Buf:=TTextStrings.Create;
   Src:='html/en/' + what + '.html';
   Buf.LoadFromFile(Src);
   Result:=Buf.Text;
   Buf.Free;
end;


procedure ShowContent(HtmlPanel: TIpHtmlPanel; What: string);
var Content: string;
begin
   Content:= GetContent(What);
   HtmlPanel.SetHtmlFromStr(Content);
end;

end.

