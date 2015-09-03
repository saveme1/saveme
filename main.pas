unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, SynEdit, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, ComCtrls, StdCtrls, LCLIntf,
  protection, content, settings, working;

type

  { TMainForm }

  TMainForm = class(TForm)
    ApplicationProperties1: TApplicationProperties;
    ButtonSettings: TButton;
    Image1: TImage;
    IpFileDataProvider1: TIpFileDataProvider;
    IpHtmlPanelWhyChristian: TIpHtmlPanel;
    IpHtmlPanelWhyCatholic: TIpHtmlPanel;
    IpHtmlPanelWhyBelieve: TIpHtmlPanel;
    IpHtmlPanelHelpMe: TIpHtmlPanel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    TabSheet2: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TreeView1: TTreeView;
    procedure ButtonSettingsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure IpHtmlPanelHelpMeHotClick(Sender: TObject);
    procedure TreeView1SelectionChanged(Sender: TObject);
    procedure SetFont(const MainFont:TFont);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

const
  VERSION = '0.3';

implementation

{$R *.lfm}

{ TMainForm }
///////////////////  Libs
///////////////// Gui
procedure TMainForm.FormCreate(Sender: TObject);
begin
  //We first need to unpack the content to make it
  //available
  UnpackContentIfNeeded();

  //Populate why believe tab with its content
  ShowContent(IpHtmlPanelWhyBelieve, 'whybelieve');
  ShowContent(IpHtmlPanelWhyChristian, 'whychristian');
  ShowContent(IpHtmlPanelWhyCatholic, 'whycatholic');

  //Select help me node on tree
  TreeView1.Selected := TreeView1.Items.GetFirstNode;
  TreeView1.Selected.MakeVisible;

  //Show protection state and version in the status bar
  StatusBar1.Panels[0].Text := isProtectedStr();
  StatusBar1.Panels[1].Text := VERSION;
end;

procedure TMainForm.IpHtmlPanelHelpMeHotClick(Sender: TObject);
var
  NodeA : TIpHtmlNodeA;
  NewURL : String;
begin

  if TIpHtmlPanel(Sender).HotNode is TIpHtmlNodeA then
    begin
      ShowWorking();
      Application.ProcessMessages;
      NodeA := TIpHtmlNodeA(TIpHtmlPanel(Sender).HotNode);
      NewURL := NodeA.HRef;
      OpenURL(NewURL);
    end;
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

procedure TMainForm.ButtonSettingsClick(Sender: TObject);
begin
  FormSettings.Show;
  ShowContent(IpHtmlPanelWhyBelieve, 'whybelieve');
  setsafedns;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IpHtmlPanelWhyBelieve.Free;
  IpHtmlPanelWhyChristian.Free;
  IpHtmlPanelWhyCatholic.Free;
  IpHtmlPanelHelpMe.Free;
  IpFileDataProvider1.Free;
  CloseAction:= caFree;
end;

procedure TMainForm.SetFont(const MainFont: TFont);
begin
  IpHtmlPanelHelpMe.Font := Font;
end;

end.

