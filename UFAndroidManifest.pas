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
    BDissMiss: TButton;
    BSaveToClipb: TButton;
    BAddManifest: TButton;
    procedure BSaveToClipbClick(Sender: TObject);
    procedure BDissMissClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
   FManifest: TFManifest;

implementation

uses
   UFGetJars;

{$R *.dfm}

procedure TFManifest.BDissMissClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TFManifest.BSaveToClipbClick(Sender: TObject);
begin
   Clipboard.AsText := MAndrMan.Text;
end;

procedure TFManifest.FormShow(Sender: TObject);
begin
   Self.Left := FGetJars.Left + ((FGetJars.Width - Self.Width) div 2);
   Self.Top := FGetJars.Top + (FGetJars.Height - Self.Height) - 70;
end;

end.
