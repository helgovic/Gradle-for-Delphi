unit UAddRep;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFAddRep = class(TForm)
    LERepository: TLabeledEdit;
    BOK: TButton;
    BCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure BOKClick(Sender: TObject);
    procedure BCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FAddRep: TFAddRep;

implementation

uses
   UFGetJars, UFRepositories;

{$R *.dfm}

procedure TFAddRep.BCancelClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TFAddRep.BOKClick(Sender: TObject);

var i: integer;

begin

   if LERepository.Text = ''
   then
      begin
         ShowMessage('Please enter repository');
         Exit;
      end;

   for i := 0 to Repositories.Count - 1 do
      if Repositories[i] = LERepository.Text
      then
      begin
         ShowMessage('Repository already exists');
         Exit;
      end;

   Self.ModalResult := mrOK;

end;

procedure TFAddRep.FormShow(Sender: TObject);
begin
   LERepository.Text := '';
   LERepository.SetFocus;
end;

end.
