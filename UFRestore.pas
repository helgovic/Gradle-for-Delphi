unit UFRestore;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Stan.Def, FireDAC.VCLUI.Wait,
  FireDAC.Phys.IBWrapper, FireDAC.Phys.FBDef, FireDAC.Phys, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.DBCtrls, System.Rtti, System.Bindings.Outputs,
  Vcl.Bind.Editors, Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, Vcl.CheckLst, FireDAC.UI.Intf, FireDAC.Stan.Pool,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, System.DateUtils;

type
  TFRestore = class(TForm)
    Label1: TLabel;
    BERestoreFile: TButtonedEdit;
    ImageList1: TImageList;
    Panel1: TPanel;
    BOK: TButton;
    Button1: TButton;
    LRestoreStatus: TLabel;
    FileOpenDialog: TFileOpenDialog;
    QJobs: TFDQuery;
    Panel2: TPanel;
    LBJobs: TCheckListBox;
    FDCBackUp: TFDConnection;
    QGetJobs: TFDQuery;
    procedure BOKClick(Sender: TObject);
    procedure BERestoreFileRightButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FRestore: TFRestore;

implementation

uses
   UFGetJars, BrandingAPI;

{$R *.dfm}

procedure TFRestore.BERestoreFileRightButtonClick(Sender: TObject);
begin

   try

      FileOpenDialog.DefaultFolder := ExtractFileDir(GetCurrentProjectFileName);

      if FileOpenDialog.Execute
      then
         begin

            BERestoreFile.Text := FileOpenDialog.FileName;
            FDCBackUp.Connected := False;
            FDCBackUp.Params.Database := BERestoreFile.Text;
            FDCBackUp.Connected := True;
            QJobs.Close;
            QJobs.Open;

            LBJobs.Clear;

            while not QJobs.Eof do
               begin

                  LBJobs.Items.Add(QJobs.FieldByName('JobName').AsString);
                  QJobs.Next;

               end;
         end;

   except on E: Exception do
      begin
         MessageDlg('Exception = ' + E.Message, mtInformation, [mbOK], 0);
         Exit;
      end;
   end;

end;

procedure TFRestore.BOKClick(Sender: TObject);

var
   i: integer;

begin

   LRestoreStatus.Caption := 'Importing settings';

   for i := 0 to LBJobs.Items.Count - 1 do
      if LBJobs.Checked[i]
      then
         begin

            FGetJars.QGetJobByName.Close;
            FGetJars.QGetJobByName.ParamByName('JobName').AsString := LBJobs.Items[i];
            FGetJars.QGetJobByName.Open;

            if FGetJars.QGetJobByName.IsEmpty
            then
               begin

                  FGetJars.QGetID.Close;
                  FGetJars.QGetID.Open;

                  FGetJars.TJobs.InsertRecord([FGetJars.QGetID.FieldByName('NewID').AsInteger, LBJobs.Items[i]]);

               end;

            QGetJobs.Close;
            QGetJobs.ParamByName('JobName').AsString := LBJobs.Items[i];
            QGetJobs.Open;

            while not QGetJobs.Eof do
            begin

               FGetJars.QInsHist.ParamByName('JobName').AsString := Trim(LBJobs.Items[i]);
               FGetJars.QInsHist.ParamByName('SaveDate').AsDateTime := IncMilliSecond(QGetJobs.FieldByName('SaveDate').AsDateTime, 100);
               FGetJars.QInsHist.ParamByName('Dependencies').AsString := QGetJobs.FieldByName('Dependencies').AsString;
               FGetJars.QInsHist.ParamByName('AddDependencies').AsString := QGetJobs.FieldByName('AddDependencies').AsString;
               FGetJars.QInsHist.ParamByName('ExclJNI').AsString := QGetJobs.FieldByName('ExclJNI').AsString;
               FGetJars.QInsHist.ParamByName('ExclFinal').AsString := QGetJobs.FieldByName('ExclFinal').AsString;
               FGetJars.QInsHist.ParamByName('InclRes').AsBoolean := QGetJobs.FieldByName('InclRes').AsBoolean;
               FGetJars.QInsHist.ParamByName('Active').AsBoolean := QGetJobs.FieldByName('Active').AsBoolean;

               FGetJars.QInsHist.ExecSQL;

               QGetJobs.Next;

            end;

         end;

   Self.Close;

end;

procedure TFRestore.FormShow(Sender: TObject);
begin

   LBJobs.Color := Themeproperties.Background2;
   LBJobs.Font.Color := Themeproperties.NCActiveFontColor;

end;

end.
