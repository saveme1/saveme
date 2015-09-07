unit protection;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, Process, lib;

const
  Safedns1 = '208.67.222.123';
  Safedns2 = '208.67.220.123';

procedure Setsafedns();
function isProtectedStr(): string;
function isProtected(): boolean;

implementation

procedure Setsafedns();
var
  Cmdout: ansistring;
  DNSServers: TStrings;
begin
  Cmdout := '';
  DNSServers := TStringList.Create();
  {$IFDEF Windows}
  //https://stackoverflow.com/questions/1677154/programmatically-changing-nameserver-in-windows-tcp-ip
  //netsh interface ip set dns name="Local Area Connection" source=static addr=...
  //RunCommand('netsh interface ip set dns name="Local Area Connection" source=static addr=',Cmdout);
  {$ENDIF}
  {$IFDEF Linux}
  //https://stackoverflow.com/questions/1677154/programmatically-changing-nameserver-in-windows-tcp-ip
  //netsh interface ip set dns name="Local Area Connection" source=static addr=...
  RunCommand('espeak hello', Cmdout);
  GetDNSServers(DNSServers);
  DNSServers.Free;
  {$ENDIF}
end;

// Returns true if the host named 'Name' has an ip address whose first
// byte is 'Num'. Returns false otherwise.
function HostAddrBegins(const Name: string; const Num: byte): boolean;
var
  Addr: TIPAddr = (0, 0, 0, 0);
  Err: string;

begin
  Err := '';
  if GetHostIP(Name, Addr, Err) then
  begin
    if Addr[1] = Num then
      Result := True
    else
      Result := False;
  end
  else
    Result := False;
end;

function isProtected(): boolean;
begin
  if HostAddrBegins('www.porn.com', 146) then
    Result := True
  else
    Result := False;
end;

function isProtectedStr(): string;
begin
  if isProtected() then
    Result := 'Your computer is protected.'
  else
    Result := 'Your computer is NOT protected';
end;

begin
end.
