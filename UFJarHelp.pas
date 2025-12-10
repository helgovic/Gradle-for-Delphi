unit UFJarHelp;

interface

uses
  Winapi.Windows, WinApi.ShellApi, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TFJarHelp = class(TForm)
    ScrollBox1: TScrollBox;
    Panel1: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    LinkLabel1: TLinkLabel;
    HTMLabel1: TMemo;
    HTMLabel2: TMemo;
    HTMLabel3: TMemo;
    HTMLabel4: TMemo;
    HTMLabel5: TMemo;
    LinkLabel2: TLinkLabel;
    procedure LinkLabel2LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure FormCreate(Sender: TObject);
  private
    procedure ScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FJarHelp: TFJarHelp;

implementation

{$R *.dfm}

procedure TFJarHelp.FormCreate(Sender: TObject);
begin
   ScrollBox1.OnMouseWheel := ScrollBoxMouseWheel;
end;

procedure TFJarHelp.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
   ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TFJarHelp.LinkLabel2LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
   ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TFJarHelp.ScrollBoxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

var
   ScrollBox: TScrollBox;
   R: TRect;

begin

   ScrollBox := TScrollBox(Sender);
   R := ScrollBox.ClientToScreen(ScrollBox.ClientRect);

   if PtInRect(R, MousePos)
   then
      begin
         ScrollBox.VertScrollBar.Position := ScrollBox.VertScrollBar.Position - WheelDelta;
         Handled := True;
      end;

end;

end.
