unit lib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Process, Regexpr
  {$IFDEF Windows}
  , Windows, WinSock
  {$ENDIF}
  {$IFDEF Linux}
  , netdb
  {$ENDIF};

{$IFDEF Windows}
// Constants found in manual on non-officially documented M$ Winsock functions
const
  SIO_GET_INTERFACE_LIST = $4004747F;
  IFF_UP = $00000001;
  IFF_BROADCAST = $00000002;
  IFF_LOOPBACK = $00000004;
  IFF_POINTTOPOINT = $00000008;
  IFF_MULTICAST = $00000010;
{$ENDIF}


type

  TIPAddr = array[1..4] of byte;


  {$IFDEF Windows}
  SockAddr_Gen = packed record
    AddressIn: SockAddr_In;
    Padding: packed array [0..7] of byte;
  end;

  Interface_Info = record
    iiFlags: u_Long;
    iiAddress: SockAddr_Gen;
    iiBroadcastAddress: SockAddr_Gen;
    iiNetmask: SockAddr_Gen;
  end;

  tNetworkInterface = record
    ComputerName: string;
    AddrIP: string;
    SubnetMask: string;
    AddrNet: string;
    AddrLimitedBroadcast: string;
    AddrDirectedBroadcast: string;
    IsInterfaceUp: boolean;
    BroadcastSupport: boolean;
    IsLoopback: boolean;
  end;

  tNetworkInterfaceList = array of tNetworkInterface;

function WSAIoctl(aSocket: TSocket; aCommand: DWord; lpInBuffer: Pointer;
  dwInBufferLen: DWord; lpOutBuffer: Pointer; dwOutBufferLen: DWord;
  lpdwOutBytesReturned: LPDWord; lpOverLapped: Pointer;
  lpOverLappedRoutine: Pointer): integer;
  stdcall; external 'WS2_32.DLL';

function GetNetworkInterfaces(
  var aNetworkInterfaceList: tNetworkInterfaceList): boolean;
function NetInterfaceForDNSServer(DNSServer: string): string;
 {$ENDIF}


function RunCmd(const Cmd: string; var Output: string): integer;
function GetDNSServer(): string;
procedure SetDNSServers(const IPAddr: array of string);
function GetDNSServers(var DNSServers: TStrings): boolean;
function GetHostIP(const HostName: ansistring; var s_byte: TIPAddr;
  var Err: string): boolean;
function isNetworkUp(): boolean;


implementation

function RunCmd(const Cmd: string; var Output: string): integer;
var
  Out: TStrings;
  AProcess: TProcess;
begin
  AProcess := TProcess.Create(nil);
  Out := TStringList.Create;
  try
    AProcess.CommandLine := Cmd;
    AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes,
      poNoConsole, poStderrToOutPut];
    AProcess.Execute;
    Out.BeginUpdate;
    Out.Clear;
    Out.LoadFromStream(AProcess.Output);
    Out.EndUpdate;
    Output := Out.Text;
    Result := AProcess.ExitStatus;
  finally
    if Assigned(AProcess) then
      FreeAndNil(AProcess);
    if Assigned(Out) then
      FreeAndNil(Out);
  end;
end;

function MatchRegex(const RegExpr: string; const Text: string;
  var Matches: TStrings): boolean;
var
  Regex: TRegExpr;
begin
  Regex := TRegExpr.Create;
  try
    with Regex do
    begin
      Expression := RegExpr;
      //We have a match
      if Exec(Text) then
      begin
        //Add all matches
        repeat
          begin
            Matches.Add(Match[1]);
          end
        until not ExecNext;
        Result := True;
      end
      else
        Result := False;
    end;
  finally
    if Assigned(Regex) then
      FreeAndNil(Regex);
  end;
end;

{$IFDEF Windows}
function GetHostIP(const HostName: ansistring; var s_byte: TIPAddr;
  var Err: string): boolean;

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
      else
        Err := 'Winsock error';
    end;
    s_byte[1] := 0;
    s_byte[2] := 0;
    s_byte[3] := 0;
    s_byte[4] := 0;
    Result := False;
  end;

  WSACleanup;
end;


{ Function to identify the network interfaces
  This code requires at least Win98/ME/2K, 95 OSR 2 or NT service pack #3
  as WinSock 2 is used (WS2_32.DLL) }

function GetNetworkInterfaces(
  var aNetworkInterfaceList: tNetworkInterfaceList): boolean;
  // Returns a complete list the of available network interfaces on a system (IPv4)
  // Copyright by Dr. Jan Schulz, 23-26th March 2007
  // This version can be used for free and non-profit projects. In any other case get in contact
  // Written with information retrieved from MSDN
  // www.code10.net
var
  aSocket: TSocket;
  aWSADataRecord: WSAData;
  NoOfInterfaces: integer;
  NoOfBytesReturned: u_Long;
  InterfaceFlags: u_Long;
  NameLength: DWord;
  pAddrIP: SockAddr_In;
  pAddrSubnetMask: SockAddr_In;
  pAddrBroadcast: Sockaddr_In;
  DirBroadcastDummy: In_Addr;
  NetAddrDummy: In_Addr;
  Buffer: array [0..30] of Interface_Info;
  i: integer;
begin
  Result := False;
  SetLength(aNetworkInterfaceList, 0);

  // Startup of old the WinSock
  // WSAStartup ($0101, aWSADataRecord);

  // Startup of WinSock2
  WSAStartup(MAKEWORD(2, 0), aWSADataRecord);

  // Open a socket
  aSocket := Socket(AF_INET, SOCK_STREAM, 0);

  // If impossible to open a socket, not worthy to go any further
  if (aSocket = INVALID_SOCKET) then
    Exit;

  try
    if WSAIoCtl(aSocket, SIO_GET_INTERFACE_LIST, nil, 0, @Buffer,
      1024, @NoOfBytesReturned, nil, nil) <> SOCKET_ERROR then
    begin
      NoOfInterfaces := NoOfBytesReturned div SizeOf(Interface_Info);
      SetLength(aNetworkInterfaceList, NoOfInterfaces);

      // For each of the identified interfaces get:
      for i := 0 to NoOfInterfaces - 1 do
      begin

        with aNetworkInterfaceList[i] do
        begin

          // Get the name of the machine
          NameLength := MAX_COMPUTERNAME_LENGTH + 1;
          SetLength(ComputerName, NameLength);
          if not GetComputerName(PChar(Computername), NameLength) then
            ComputerName := '';

          // Get the IP address
          pAddrIP := Buffer[i].iiAddress.AddressIn;
          AddrIP := string(inet_ntoa(pAddrIP.Sin_Addr));

          // Get the subnet mask
          pAddrSubnetMask := Buffer[i].iiNetMask.AddressIn;
          SubnetMask := string(inet_ntoa(pAddrSubnetMask.Sin_Addr));

          // Get the limited broadcast address
          pAddrBroadcast := Buffer[i].iiBroadCastAddress.AddressIn;
          AddrLimitedBroadcast := string(inet_ntoa(pAddrBroadcast.Sin_Addr));

          // Calculate the net and the directed broadcast address
          NetAddrDummy.S_addr := Buffer[i].iiAddress.AddressIn.Sin_Addr.S_Addr;
          NetAddrDummy.S_addr :=
            NetAddrDummy.S_addr and Buffer[i].iiNetMask.AddressIn.Sin_Addr.S_Addr;
          DirBroadcastDummy.S_addr :=
            NetAddrDummy.S_addr or not Buffer[i].iiNetMask.AddressIn.Sin_Addr.S_Addr;

          AddrNet := string(inet_ntoa((NetAddrDummy)));
          AddrDirectedBroadcast := string(inet_ntoa((DirBroadcastDummy)));

          // From the evaluation of the Flags we receive more information
          InterfaceFlags := Buffer[i].iiFlags;

          // Is the network interface up or down ?
          if (InterfaceFlags and IFF_UP) = IFF_UP then
            IsInterfaceUp := True
          else
            IsInterfaceUp := False;

          // Does the network interface support limited broadcasts ?
          if (InterfaceFlags and IFF_BROADCAST) = IFF_BROADCAST then
            BroadcastSupport := True
          else
            BroadcastSupport := False;

          // Is the network interface a loopback interface ?
          if (InterfaceFlags and IFF_LOOPBACK) = IFF_LOOPBACK then
            IsLoopback := True
          else
            IsLoopback := False;
        end;
      end;
    end;
  except
    Result := False;
  end;

  // Cleanup the mess
  CloseSocket(aSocket);
  WSACleanUp;
  Result := True;
end;

function NetInterfaceForDNSServer(DNSServer: string): string;
var
  IFaces: TStrings;
  Expression, Netshout: ansistring;

begin
  Netshout := '';
  IFaces := TStringList.Create;
  try
    RunCmd('netsh interface ip show dns', Netshout);
    Expression := '.*for interface "(.*?)".*?DNS.*?:\s+' + DNSServer;
    if MatchRegex(Expression, Netshout, IFaces) then
      Result := IFaces[0]
    else
      Result := '';
  finally
    if Assigned(IFaces) then
      FreeAndNil(IFaces);
  end;
end;

{$ENDIF}

function ExtractDNSServers(const Text: string; var DNSServers: TStrings): boolean;
var
  Expression: ansistring;
begin
  {$IFDEF Linux}
  //Regex for "cat /etc/resolv.conf"
  Expression := 'nameserver\s+(\d+\.\d+\.\d+\.\d+)';
  {$ENDIF}
  {$IFDEF Windows}
  //Regex for "nslookup www.ibm.com"
  Expression := '(?s)Server:\s+.*?Address:\s+(\d+\.\d+\.\d+\.\d+)';
  {$ENDIF}
  if MatchRegex(Expression, Text, DNSServers) then
    Result := True
  else
    Result := False;
end;



function GetDNSServers(var DNSServers: TStrings): boolean;
var
  S: ansistring;
begin
  S := '';
  {$IFDEF Linux}
  RunCmd('cat /etc/resolv.conf', S);
  {$ENDIF}
  {$IFDEF Windows}
  RunCmd('nslookup www.ibm.com', S);
  {$ENDIF}
  Result := ExtractDNSServers(S, DNSServers);
end;

function GetDNSServer(): string;
var
  Servers: TStrings;
begin
  Servers := TStringList.Create;
  try
    if GetDNSServers(Servers) then
      Result := Servers[0]
    else
      Result := '';
  finally
    if Assigned(Servers) then
      FreeAndNil(Servers);
  end;
end;

procedure SetDNSServers(const IPAddr: array of string);
var
  Cmd, DNSServer, IFace, NSStr, OutStr: ansistring;
  i: integer;
begin
  DNSServer := '';
  IFace := '';
  OutStr := '';

  {$IFDEF Windows}
  DNSServer := GetDNSServer();
  IFace := NetInterfaceForDNSServer(DNSServer);
  if IPAddr[0] = 'dhcp' then
  begin
    //Enable dhcp servers
    Cmd := Format('netsh interface ip set dnsservers name="%s" source=dhcp', [IFace]);
    RunCmd(Cmd, OutStr);
  end
  else
    //Add static servers in list
  begin
    //First server
    Cmd := Format('netsh interface ip set dns name="%s" static %s',
      [IFace, IPAddr[0]]);
    if RunCmd(Cmd, OutStr) <> 0 then
      begin
        OutStr := 'Error protecting computer:' + LineEnding + OutStr + LineEnding +
          'You need administrative permissions to perform this action.' + LineEnding;
        ShowMessage(OutStr);
      end;

    //Additional servers
    for i := 1 to Length(IPAddr) - 1 do
    begin
      Cmd := Format('netsh interface ip add dns name="%s" %s index=%d',
        [IFace, IPAddr[i], i + 1]);
      if RunCmd(Cmd, OutStr) <> 0 then
      begin
        OutStr := 'Error protecting computer:' + LineEnding + OutStr + LineEnding +
          'You need administrative permissions to perform this action.' + LineEnding;
        ShowMessage(OutStr);
      end;
    end;
  end;
  {$ENDIF}

  {$IFDEF Linux}
  Cmd := 'sudo sed -i ''1s/^/nameserver ' + IPAddr[0] + '\n/'' /etc/resolv.conf';
  if RunCmd(Cmd, OutStr) <> 0 then
  begin
    OutStr := 'Error protecting computer:' + LineEnding + OutStr + LineEnding +
      'You need sudo permissions to perform this action.' + LineEnding;
    ShowMessage(OutStr);
  end;
  {$ENDIF}

end;

function isNetworkUp(): boolean;
{$IFDEF Windows}
var
  NetIfList: tNetworkInterfaceList;
  IfInfo: tNetworkInterface;
{$ENDIF}
begin
  Result := False;

  {$IFDEF Windows}
  GetNetworkInterfaces(NetIfList);
  for IfInfo in NetIfList do
    Result := Result or (not IfInfo.IsLoopback and IfInfo.IsInterfaceUp);
  {$ENDIF}

  {$IFDEF Linux}
  //FIXME
  Result := True;
  {$ENDIF}

end;

{$IFDEF Linux}
function GetHostIP(const HostName: ansistring; var s_byte: TIPAddr;
  var Err: string): boolean;
  //We use netdb for unix
var
  H: THostEntry;

begin
  Err := '';
  if ResolveHostByName(HostName, H) then
  begin
    s_byte := H.Addr.s_bytes;
    Result := True;
  end
  else
    Result := False;
end;

{$ENDIF}

end.
