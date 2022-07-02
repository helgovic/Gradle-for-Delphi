unit UFHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DateUtils;

type
  TFHistory = class(TForm)
    LBHistory: TListBox;
    BRevert: TButton;
    BClose: TButton;
    procedure FormShow(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
    procedure LBHistoryClick(Sender: TObject);
    procedure BRevertClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TDTObj = class
     DT: TDateTime;
  end;

var
  FHistory: TFHistory;

implementation

uses
   UFGetJars;

{$R *.dfm}

procedure TFHistory.BCloseClick(Sender: TObject);
begin

   Self.Close;

end;

procedure TFHistory.BRevertClick(Sender: TObject);
begin

   if LBHistory.ItemIndex >= 0
   then
      begin

         FGetJars.QGetJobByDate.Close;
         FGetJars.QGetJobByDate.ParamByName('JobName').AsString := FGetJars.LeJobName.Text;
         FGetJars.QGetJobByDate.ParamByName('Date').AsDateTime := TDTObj(LBHistory.Items.Objects[LBHistory.ItemIndex]).DT;
         FGetJars.QGetJobByDate.Open;

         FGetJars.QInsHist.ParamByName('JobName').AsString := FGetJars.LeJobName.Text;
         FGetJars.QInsHist.ParamByName('SaveDate').AsDateTime := Now;
         FGetJars.QInsHist.ParamByName('Dependencies').AsString := FGetJars.QGetJobByDate.FieldByName('Dependencies').AsString;
         FGetJars.QInsHist.ParamByName('AddDependencies').AsString := FGetJars.QGetJobByDate.FieldByName('AddDependencies').AsString;
         FGetJars.QInsHist.ParamByName('ExclJNI').AsString :=  FGetJars.QGetJobByDate.FieldByName('ExclJNI').AsString;
         FGetJars.QInsHist.ParamByName('ExclFinal').AsString :=  FGetJars.QGetJobByDate.FieldByName('ExclFinal').AsString;
         FGetJars.QInsHist.ExecSQL;

      end;

end;

procedure TFHistory.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

   FGetJars.QGetCurrJob.Close;
   FGetJars.QGetCurrJob.ParamByName('JobName').AsString := FGetJars.LEJobName.Text;
   FGetJars.QGetCurrJob.Open;

   FGetJars.MJars.Lines.Text := IniStrToMemoStr(FGetJars.QGetCurrJob.FieldByName('Dependencies').AsString);
   FGetJars.MAddJars.Lines.Text := IniStrToMemoStr(FGetJars.QGetCurrJob.FieldByName('AddDependencies').AsString);
   FGetJars.MExclJars.Lines.Text := IniStrToMemoStr(FGetJars.QGetCurrJob.FieldByName('ExclJNI').AsString);
   FGetJars.MExclFinal.Lines.Text := IniStrToMemoStr(FGetJars.QGetCurrJob.FieldByName('ExclFinal').AsString);

   CanClose := True;

end;

procedure TFHistory.FormShow(Sender: TObject);

var
   DTO: TDTObj;

begin

   LBHistory.Items.Clear;

   FGetJars.QGetJobs.Close;
   FGetJars.QGetJobs.ParamByName('JobName').AsString := FGetJars.LeJobName.Text;
   FGetJars.QGetJobs.Open;

   while not FGetJars.QGetJobs.Eof do
      begin

         DTO := TDTObj.Create;
         DTO.DT := FGetJars.QGetJobs.FieldByName('SaveDate').AsDateTime;
         LBHistory.AddItem(DatetimeToStr(FGetJars.QGetJobs.FieldByName('SaveDate').AsDateTime), DTO);
         FGetJars.QGetJobs.Next;

      end;

end;

procedure TFHistory.LBHistoryClick(Sender: TObject);
begin

   FGetJars.QGetJobByDate.Close;
   FGetJars.QGetJobByDate.ParamByName('JobName').AsString := FGetJars.LeJobName.Text;
   FGetJars.QGetJobByDate.ParamByName('Date').AsDateTime := TDTObj(LBHistory.Items.Objects[LBHistory.ItemIndex]).DT;
   FGetJars.QGetJobByDate.Open;

   FGetJars.MJars.Lines.Text := IniStrToMemoStr(FGetJars.QGetJobByDate.FieldByName('Dependencies').AsString);
   FGetJars.MAddJars.Lines.Text := IniStrToMemoStr(FGetJars.QGetJobByDate.FieldByName('AddDependencies').AsString);
   FGetJars.MExclJars.Lines.Text := IniStrToMemoStr(FGetJars.QGetJobByDate.FieldByName('ExclJNI').AsString);
   FGetJars.MExclFinal.Lines.Text := IniStrToMemoStr(FGetJars.QGetJobByDate.FieldByName('ExclFinal').AsString);

end;

end.
