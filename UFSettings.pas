unit UFSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, System.Win.Registry;

type
  TFSettings = class(TForm)
    FileOpenDialog: TFileOpenDialog;
    ImageList1: TImageList;
    Panel1: TPanel;
    BOK: TButton;
    Button1: TButton;
    GroupBox1: TGroupBox;
    RBJava2OP: TRadioButton;
    RbJavaImport: TRadioButton;
    BEJ2OPath: TButtonedEdit;
    BEJIPath: TButtonedEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BEJDKHome: TButtonedEdit;
    Label4: TLabel;
    BEBuildToolsPath: TButtonedEdit;
    procedure BEJ2OPathRightButtonClick(Sender: TObject);
    procedure BEJIPathRightButtonClick(Sender: TObject);
    procedure BOKClick(Sender: TObject);
    procedure BEJDKHomeRightButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSettings: TFSettings;

implementation

uses
   UFGetJars;

{$R *.dfm}

procedure TFSettings.BEJ2OPathRightButtonClick(Sender: TObject);
begin

   if FileOpenDialog.Execute
   then
      begin

         BEJ2OPath.Text := FileOpenDialog.FileName;

      end;

end;

procedure TFSettings.BEJDKHomeRightButtonClick(Sender: TObject);
begin

   if FileOpenDialog.Execute
   then
      begin

         BEJDKHome.Text := FileOpenDialog.FileName;

      end;

end;

procedure TFSettings.BEJIPathRightButtonClick(Sender: TObject);
begin

   if FileOpenDialog.Execute
   then
      begin

         BEJIPath.Text := FileOpenDialog.FileName;

      end;

end;

procedure TFSettings.BOKClick(Sender: TObject);
begin


   if RBJava2OP.Checked
   then
      begin

         if BEJ2OPath.Text = ''
         then
            begin
               ShowMessage('Please enter path to Java2OP.exe');
               BEJ2OPath.SetFocus;
               Exit;
            end;

         if not FileExists(BEJ2OPath.Text + '\java2op.exe')
         then
            begin
               ShowMessage('File ' + BEJIPath.Text + '\java2op.exe does not exist');
               BEJ2OPath.SetFocus;
               Exit;
            end;

      end
   else
      begin

         if BEJIPath.Text = ''
         then
            begin
               ShowMessage('Please enter path to javaimport.exe');
               BEJIPath.SetFocus;
               Exit;
            end;

         if not FileExists(BEJIPath.Text + '\javaimport.exe')
         then
            begin
               ShowMessage('File ' + BEJIPath.Text + '\javaimport.exe does not exist');
               BEJIPath.SetFocus;
               Exit;
            end;

      end;

   if BEJDKHome.Text = ''
   then
      begin
         ShowMessage('Please enter path to JDK');
         BEJDKHome.SetFocus;
         Exit;
      end;

   if not DirectoryExists(BEJDKHome.Text)
   then
      begin
         ShowMessage('Directory ' + BEJDKHome.Text + ' does not exist');
         BEJDKHome.SetFocus;
         Exit;
      end;

   if BEBuildToolsPath.Text = ''
   then
      begin
         ShowMessage('Please enter path to Build Tools');
         BEBuildToolsPath.SetFocus;
         Exit;
      end;

   if not DirectoryExists(BEBuildToolsPath.Text)
   then
      begin
         ShowMessage('Directory ' + BEBuildToolsPath.Text + ' does not exist');
         BEBuildToolsPath.SetFocus;
         Exit;
      end;

   with TRegIniFile.Create(REG_KEY) do
   try
      WriteString(REG_BUILD_OPTIONS, 'Java2op Location', BEJ2OPath.Text);
      WriteString(REG_BUILD_OPTIONS, 'JavaImport Location', BEJIPath.Text);
      WriteString(REG_BUILD_OPTIONS, 'JDK Location', BEJDKHome.Text);
      WriteString(REG_BUILD_OPTIONS, 'Build Tools Location', BEBuildToolsPath.Text);
      WriteBool(REG_BUILD_OPTIONS, 'Java2OP', RBJava2OP.Checked);
   finally
      Free;
   end;

   ModalResult := mrOK;

end;

end.
