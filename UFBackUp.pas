unit UFBackUp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, FireDAC.Stan.Def, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef;

type
  TFBackUp = class(TForm)
    BEBackUpFile: TButtonedEdit;
    Label1: TLabel;
    ImageList1: TImageList;
    Panel1: TPanel;
    BOK: TButton;
    Button1: TButton;
    LStatus: TLabel;
    FileOpenDialog: TFileOpenDialog;
    FDSQLiteBackup: TFDSQLiteBackup;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure BOKClick(Sender: TObject);
    procedure BEBackUpFileRightButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FBackUp: TFBackUp;

implementation

uses
   UFGetJars;

{$R *.dfm}

procedure TFBackUp.BEBackUpFileRightButtonClick(Sender: TObject);
begin

   FileOpenDialog.DefaultFolder := ExtractFileDir(GetCurrentProjectFileName);

   if FileOpenDialog.Execute
   then
      BEBackUpFile.Text := FileOpenDialog.FileName;

end;

procedure TFBackUp.BOKClick(Sender: TObject);
begin

   try
      FDSQLiteBackup.Database := FGetJars.FDCJobs.Params.Database;
      FDSQLiteBackup.DestDatabase := BEBackUpFile.Text;
      FDSQLiteBackup.Backup;
   except on E: Exception do
      begin
         MessageDlg('Exception = ' + E.Message, mtInformation, [mbOK], 0);
         Exit;
      end;
   end;

   Self.Close;

end;

end.
