unit protection;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, lib;

const
  //Open DNS safe servers
  Safedns1 = '208.67.222.123';
  Safedns2 = '208.67.220.123';

procedure SetSafeDNS();
function isProtectedStr(): string;
function isProtected(): boolean;

implementation


procedure SetSafeDNS();
begin
  SetDNSServers([Safedns1, Safedns2]);
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
  if isNetworkUp() and isProtected() then
    Result := 'Your computer is protected.'
  else
  if isNetworkUp() then
    Result := 'Your computer is NOT protected.'
  else
    Result := 'Network is down.';
end;

begin
end.
