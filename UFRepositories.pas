unit UFRepositories;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.CheckLst, Registry, Vcl.ExtCtrls;

type
  TFRepositories = class(TForm)
    Label1: TLabel;
    BCancel: TButton;
    BOK: TButton;
    MRepositeries: TMemo;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BCancelClick(Sender: TObject);
    procedure BOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FRepositories: TFRepositories;
  Repositories: TStringList;

implementation

uses
   UFGetJars, IniFiles, JCLStrings;

{$R *.dfm}

procedure TFRepositories.BCancelClick(Sender: TObject);
begin
   Self.ModalResult := mrCancel;
end;

procedure TFRepositories.BOKClick(Sender: TObject);
begin
   Self.ModalResult := mrOK;
end;

procedure TFRepositories.FormCreate(Sender: TObject);
begin
   Repositories := TStringList.Create;
   Repositories.Delimiter := '¤';
   Repositories.StrictDelimiter := True;
end;

procedure TFRepositories.FormDestroy(Sender: TObject);
begin
   Repositories.Free;
end;

procedure TFRepositories.FormShow(Sender: TObject);
begin

   MRepositeries.Text := '';

   FGetJars.TRepositoriesNew.First;

   if not FGetJars.TRepositoriesNew.IsEmpty
   then
      MRepositeries.Text := FGetJars.TRepositoriesNew.FieldByName('RepositoriesDefs').AsString;

end;

end.
