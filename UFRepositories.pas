unit UFRepositories;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AdvSmoothButton, Vcl.StdCtrls,
  Vcl.CheckLst, Registry, Vcl.ExtCtrls;

type
  TFRepositories = class(TForm)
    CLBRepositories: TCheckListBox;
    Label1: TLabel;
    BCancel: TPanel;
    BOK: TPanel;
    BAddRepos: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BAddReposClick(Sender: TObject);
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
   UFGetJars, IniFiles, JCLStrings, UAddRep;

{$R *.dfm}

procedure TFRepositories.BAddReposClick(Sender: TObject);

var
   RepStr: String;

begin

   if FAddRep.ShowModal = mrOK
   then
      if FAddRep.LERepository.Text <> ''
      then
         begin

            with TRegIniFile.Create(REG_KEY) do
            try
               RepStr := ReadString(REG_BUILD_OPTIONS, 'Repositories', '');
               RepStr := RepStr + '¤' + FAddRep.LERepository.Text;
               WriteString(REG_BUILD_OPTIONS, 'Repositories', RepStr);
            finally
               Free;
            end;

            CLBRepositories.AddItem(FAddRep.LERepository.Text, nil);
            CLBRepositories.Checked[CLBRepositories.Count - 1] := True;

         end;

end;

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

var
   i, x: integer;
   ProjRep: TStringList;

begin

   with TRegIniFile.Create(REG_KEY) do
   try
      Repositories.DelimitedText := ReadString(REG_BUILD_OPTIONS, 'Repositories', '');
   finally
      Free;
   end;

   CLBRepositories.Items.Clear;

   for i := 0 to Repositories.Count - 1 do
      CLBRepositories.AddItem(Repositories[i], nil);

   ProjRep := TStringList.Create;
   ProjRep.Delimiter := '¤';
   ProjRep.StrictDelimiter := True;

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      try

         ProjRep.DelimitedText := ReadString(FGetJars.LEJobName.Text, 'Repositories', '');

         for i := 0 to ProjRep.Count - 1 do
            for x := 0 to CLBRepositories.Count - 1 do
               if ProjRep[i] = CLBRepositories.Items[x]
               then
                  CLBRepositories.Checked[x] := True;

      finally
         Free;
      end;

      ProjRep.Free;

end;

end.
