unit lib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs
  {$IFDEF Windows}
  , WinSock
  {$ENDIF}
  {$IFDEF Linux}
  , netdb
  {$ENDIF};


type
  TIPAddr = array[1..4] of byte;

function GetHostIP(const HostName: ansistring; var s_byte: TIPAddr;
  var Err: string): boolean;



implementation

function GetHostIP(const HostName: ansistring; var s_byte: TIPAddr;
  var Err: string): boolean;
{$IFDEF Windows}
//We use winsock for windows
var
  HEnt: pHostEnt;
  WSAData: TWSAData;
  i: integer;
begin
  Result := False;
  if WSAStartup($0101, WSAData) <> 0 then
  begin
    Err := 'Socket does not respond!"';
    Exit;
  end;
  Err := '';
  HEnt := GetHostByName(PChar(HostName));
  if HEnt <> nil then
  begin
    for i := 0 to HEnt^.h_length - 1 do
    begin
      s_byte[i + 1] := Ord(HEnt^.h_addr_list^[i]);
    end;
    Result := True;
  end
  else
  begin
    case WSAGetLastError of
      WSANOTINITIALISED: Err := 'WSANotInitialised';
      WSAENETDOWN: Err := 'WSAENetDown';
      WSAEINPROGRESS: Err := 'WSAEInProgress';
    end;
    s_byte[1] := 0;
    s_byte[2] := 0;
    s_byte[3] := 0;
    s_byte[4] := 0;
    Result := False;
  end;

  WSACleanup;
end;
{$ENDIF}
{$IFDEF Linux}
//We use netdb for unix
var
  H: THostEntry;

begin
  Err := '';
  if ResolveHostByName(HostName, H) then
  begin
    s_byte := H.Addr.s_bytes;
    Result := True
  end
  else
    Result := False;
end;
{$ENDIF}

end.
