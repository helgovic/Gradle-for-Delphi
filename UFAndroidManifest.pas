unit UFAndroidManifest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Clipbrd,
  Vcl.ExtCtrls;

type
  TFManifest = class(TForm)
    Label3: TLabel;
    MAndrMan: TMemo;
    BDissMiss: TPanel;
    BSaveToClipb: TPanel;
    BAddManifest: TPanel;
    procedure BSaveToClipbClick(Sender: TObject);
    procedure BDissMissClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
   FManifest: TFManifest;

implementation

{$R *.dfm}

procedure TFManifest.BDissMissClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TFManifest.BSaveToClipbClick(Sender: TObject);
begin
   Clipboard.AsText := MAndrMan.Text;
end;

end.
