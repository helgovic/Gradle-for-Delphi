unit UFGenAndrJNI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Mask;

type
  TFGenAndrJNI = class(TForm)
    Panel1: TPanel;
    BGo: TButton;
    BClose: TButton;
    BEAndroidJar: TButtonedEdit;
    ImageList1: TImageList;
    Memo1: TMemo;
    LEClasses: TLabeledEdit;
    LEOutFile: TLabeledEdit;
    MOutput: TMemo;
    FileOpenDialog: TFileOpenDialog;
    procedure BCloseClick(Sender: TObject);
    procedure BGoClick(Sender: TObject);
    procedure BEAndroidJarRightButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ExecOut(const Text: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FGenAndrJNI: TFGenAndrJNI;

implementation

{$R *.dfm}

uses
   JclSysUtils, UFGetJars;

procedure TFGenAndrJNI.BCloseClick(Sender: TObject);
begin
   Self.Close;
end;

procedure TFGenAndrJNI.ExecOut(const Text: string);
begin

   TThread.Synchronize(TThread.CurrentThread,
   procedure
   begin
      MOutput.Text := MOutput.Text + Text;
      SendMessage(MOutput.Handle, WM_VSCROLL, SB_BOTTOM, 0);
   end);

end;

procedure TFGenAndrJNI.FormShow(Sender: TObject);
begin

   BEAndroidJar.Text := '';
   LEClasses.Text := '';
   LEOutFile.Text := '';

end;

procedure TFGenAndrJNI.BEAndroidJarRightButtonClick(Sender: TObject);
begin

   if FileOpenDialog.Execute
   then
      begin

         BEAndroidJar.Text := FileOpenDialog.FileName;

      end;

end;

procedure TFGenAndrJNI.BGoClick(Sender: TObject);

var
   FileLines: TStringList;
   ProjDir: String;

begin

   if BEAndroidJar.Text = ''
   then
      begin
         MessageDlg('Please enter jar location', mtError, [mbOK], 0);
         BEAndroidJar.SetFocus;
         Exit;
      end;

   if not FileExists(BEAndroidJar.Text + '\android.jar')
   then
      begin
         MessageDlg('android.jar not found at this locationlocation', mtError, [mbOK], 0);
         BEAndroidJar.SetFocus;
         Exit;
      end;

   if LEClasses.Text = ''
   then
      begin
         MessageDlg('Please enter classes to process', mtError, [mbOK], 0);
         LEClasses.SetFocus;
         Exit;
      end;

   if LEOutFile.Text = ''
   then
      begin
         MessageDlg('Please enter unit name', mtError, [mbOK], 0);
         LEOutFile.SetFocus;
         Exit;
      end;

   ProjDir := ExtractFilePath(GetCurrentProjectFileName);

   FileLines := TStringList.Create;

   FileLines.Add(ExtractFileDrive(ConverterPath));
   FileLines.Add('cd "' + ConverterPath + '"');
   FileLines.Add('Java2OP.exe -classes ' + LEClasses.Text + ' ' + BEAndroidjar.Text + ' -unit AndroidApi.JNI.' + LEOutFile.Text);
   FileLines.SaveToFile(ProjDir + '\RunCmd.bat');

   if Execute(ProjDir + '\RunCmd.bat', ExecOut) <> 0
   then
      ShowMessage('There was an error running the task. Please check Output')
   else
      begin
         MoveFile(PChar(ConverterPath + '\AndroidApi.JNI.' + LEOutFile.Text + '.pas'), PChar(ProjDir + '\AndroidApi.JNI.' + LEOutFile.Text + '.pas'));
         ShowMessage('Task completed successfully.');
      end;

   FileLines.Free;

   DeleteFile(ProjDir + '\RunCmd.bat');

end;

end.
