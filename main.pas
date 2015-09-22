unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, LCLIntf, Buttons, Menus, ActnList,
  IniPropStorage, protection, content, settings, working, lib, update,
  VersionSupport;

type

  { TMainForm }

  TMainForm = class(TForm)
    ActionRestoreDNS: TAction;
    ActionCopy: TAction;
    ActionList1: TActionList;
    ApplicationProperties1: TApplicationProperties;
    BitBtnSettings: TBitBtn;
    Image1: TImage;
    ImageList1: TImageList;
    IniPropStorage1: TIniPropStorage;
    IpFileDataProvider1: TIpFileDataProvider;
    IpHtmlPanelWhyChristian: TIpHtmlPanel;
    IpHtmlPanelWhyCatholic: TIpHtmlPanel;
    IpHtmlPanelWhyBelieve: TIpHtmlPanel;
    IpHtmlPanelHelpMe: TIpHtmlPanel;
    Memo1: TMemo;
    MenuItemCopy: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PopupMenuHtmlPanel: TPopupMenu;
    StatusBar1: TStatusBar;
    TabSheet2: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TimerAfterShow: TTimer;
    TreeView1: TTreeView;
    procedure ActionCopyExecute(Sender: TObject);
    procedure ActionRestoreDNSExecute(Sender: TObject);
    procedure BitBtnSettingsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IpHtmlPanelHelpMeHotClick(Sender: TObject);
    procedure TimerAfterShowTimer(Sender: TObject);
    procedure TreeView1SelectionChanged(Sender: TObject);
    procedure SetFont(const MainFont: TFont);
    procedure Restart();

  private
    { private declarations }
  public
    procedure UpdateStatusBar();
    function GetCurHtmlPanel(): TIpHtmlPanel;
    { public declarations }
  end;

var
  MainForm: TMainForm;
  VERSION: ansistring;
  DoRestart: boolean = False;

implementation

{$R *.lfm}

{ TMainForm }
///////////////////  Libs
///////////////// Gui
procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Get version from executable
  VERSION := GetFileVersion();

  //Switch to the config directory as the working dir
  //so that all html relative html links work properly
  ChDir(GetAppConfigDir(False));

  //We first need to unpack the content to make it
  //available
  UnpackContentIfNeeded();

  //Populate tabs with content
  ShowContent(IpHtmlPanelWhyBelieve, 'whybelieve');
  ShowContent(IpHtmlPanelWhyChristian, 'whychristian');
  ShowContent(IpHtmlPanelWhyCatholic, 'whycatholic');

  //Select help me node on tree
  TreeView1.Selected := TreeView1.Items.GetFirstNode;
  TreeView1.Selected.MakeVisible;

  //Store original dns servers (needed in windows only)
  {$IFDEF Windows}
  StoreOrigDNSServers();
  {$ENDIF}
end;

procedure TMainForm.Restart();
begin
  DoRestart:=True;
  Self.Close
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if DoRestart then
    RestartExe();
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  TimerAfterShow.Enabled := True;
  UpdateStatusBar();
end;

procedure TMainForm.IpHtmlPanelHelpMeHotClick(Sender: TObject);
var
  NodeA: TIpHtmlNodeA;
  NewURL: string;
begin

  if TIpHtmlPanel(Sender).HotNode is TIpHtmlNodeA then
  begin
    Screen.Cursor := crHourGlass;
    try
      ShowWorking();
      Application.ProcessMessages;
      NodeA := TIpHtmlNodeA(TIpHtmlPanel(Sender).HotNode);
      NewURL := NodeA.HRef;
      OpenURL(NewURL);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TMainForm.TimerAfterShowTimer(Sender: TObject);
var
  Res: integer;
begin
  //Timer needs to fire only once after show
  TimerAfterShow.Enabled := False;
  //we do this in FormShow to be able to safely call
  //MainForm.Close if update is needed
  if FormSettings.CheckBoxAutoUpdate.Checked then
    if UpdateIfNeeded() then
    begin
      DoRestart := True;
      Self.Close;
    end
    else
    begin
      DoRestart := False;
      //Protect computer if needed
      if not isProtected() and isNetworkUp() then
      begin
        Res := MessageDlg('Your computer is not protected. Click OK to protect it.',
          mtConfirmation, mbOKCancel, 0);
        if Res = mrOk then
        begin
          SetSafeDNS();
          TimerAfterShow.Enabled := True; //So that UpdateStatusBar gets called later
          {$IFDEF Linux}
          //In Linux we need to restart to recognize DNS change
          Restart();
          {$ENDIF}
        end;
      end;

      //Show protection state and version in the status bar
      UpdateStatusBar();
    end;
end;

function TMainForm.GetCurHtmlPanel(): TIpHtmlPanel;
var
  i: integer;
begin
  for i := 0 to PageControl1.ActivePage.ControlCount - 1 do
    if PageControl1.ActivePage.Controls[i] is TIpHtmlPanel then
      Result := TIpHtmlPanel(PageControl1.ActivePage.Controls[i]);
end;


procedure TMainForm.TreeView1SelectionChanged(Sender: TObject);
begin
  //Switch to the proper Tab if the treenode clicked
  //corresponds to one of the window Tabs
  if TreeView1.Selected.Text = TabSheet2.Caption then
    PageControl1.ActivePageIndex := 1
  else
  if TreeView1.Selected.Text = TabSheet3.Caption then
    PageControl1.ActivePageIndex := 2
  else
  if TreeView1.Selected.Text = TabSheet4.Caption then
    PageControl1.ActivePageIndex := 3
  else
    //Show the html document for the clicked tree node
    //if there is no window Tab for it
    ShowTreeContent(IpHtmlPanelHelpMe, TreeView1.Selected.Text);
end;


procedure TMainForm.BitBtnSettingsClick(Sender: TObject);
begin
  FormSettings.Show();
  UpdateStatusBar();
end;

procedure TMainForm.ActionCopyExecute(Sender: TObject);
begin
  GetCurHtmlPanel().CopyToClipboard;
end;

procedure TMainForm.ActionRestoreDNSExecute(Sender: TObject);
var
  Res: integer;
begin
  Res := MessageDlg('Are you sure?', mtWarning, mbYesNoCancel, 0);
  if Res = mrYes then
    SetDNSServers(['dhcp']);
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IpHtmlPanelWhyBelieve.Free;
  IpHtmlPanelWhyChristian.Free;
  IpHtmlPanelWhyCatholic.Free;
  IpHtmlPanelHelpMe.Free;
  IpFileDataProvider1.Free;
  CloseAction := caFree;
end;

procedure TMainForm.SetFont(const MainFont: TFont);
begin
  IpHtmlPanelHelpMe.Font := MainFont;
  IpHtmlPanelHelpMe.DefaultTypeFace := MainFont.Name;
  IpHtmlPanelHelpMe.DefaultFontSize := MainFont.Size;
  IpHtmlPanelHelpMe.Repaint;
end;

procedure TMainForm.UpdateStatusBar();
begin
  StatusBar1.Panels[0].Text := isProtectedStr();
  StatusBar1.Panels[1].Text := VERSION + '     ';
end;

end.
