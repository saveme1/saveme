unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Ipfilebroker, SynEdit, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, ComCtrls, StdCtrls,
  protection, content;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    IpFileDataProvider1: TIpFileDataProvider;
    IpHtmlPanel1: TIpHtmlPanel;
    IpHtmlPanel2: TIpHtmlPanel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
///////////////////  Libs
///////////////// Gui
procedure TForm1.FormCreate(Sender: TObject);
begin
  ShowContent(IpHtmlPanel1, 'whybelieve');
  StatusBar1.Panels[0].Text := isProtectedStr();
end;


procedure TForm1.Button1Click(Sender: TObject);
begin

  setsafedns;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IpHtmlPanel1.Free;
  IpHtmlPanel2.Free;
  IpFileDataProvider1.Free;
end;




end.

