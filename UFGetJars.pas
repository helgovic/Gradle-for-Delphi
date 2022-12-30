unit UFGetJars;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, ToolsAPI, Threading, Vcl.ExtCtrls,
  MyZip, System.IOUtils, JclFileUtils,
  Vcl.ComCtrls, Vcl.WinXCtrls, PlatformAPI, Vcl.Mask, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.Client, Data.DB,
  FireDAC.Comp.DataSet, Vcl.Menus;

type
  TFGetJars = class(TForm)
    Label1: TLabel;
    MExclFinal: TMemo;
    MJars: TMemo;
    MAddJars: TMemo;
    Label2: TLabel;
    LEJobName: TLabeledEdit;
    Label3: TLabel;
    Label4: TLabel;
    MExclJars: TMemo;
    CBProjJobs: TComboBox;
    Label5: TLabel;
    ASPB: TProgressBar;
    TSKeepLibs: TToggleSwitch;
    BGo: TButton;
    BAddRep: TButton;
    BClose: TButton;
    BNewJob: TButton;
    BSave: TButton;
    BDelete: TButton;
    MStatus: TMemo;
    BCompileAll: TButton;
    LStatus: TLabel;
    FDCJobs: TFDConnection;
    QGetJobs: TFDQuery;
    TJobs: TFDTable;
    THistory: TFDTable;
    QDefDB: TFDQuery;
    QGetCurrJob: TFDQuery;
    TRepositories: TFDTable;
    QInsHist: TFDQuery;
    QGetID: TFDQuery;
    BHistory: TButton;
    QGetJobByDate: TFDQuery;
    QGetJobByName: TFDQuery;
    TParms: TFDTable;
    QDelRepositories: TFDQuery;
    Button1: TButton;
    TSInclRes: TToggleSwitch;
    MMFGetJars: TMainMenu;
    MISettings: TMenuItem;
    procedure BGoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CBProjJobsSelect(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure BNewJobClick(Sender: TObject);
    procedure BAddRepClick(Sender: TObject);
    procedure BDeleteClick(Sender: TObject);
    procedure BCompileAllClick(Sender: TObject);
    procedure BHistoryClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure MISettingsClick(Sender: TObject);
  private
    procedure ExecOut(const Text: string);
    procedure LoadJob(JobNam: String);
    function SaveJob: Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

const
  REG_KEY = '\Software\SoftMagical\Experts';
  REG_BUILD_OPTIONS = 'GradleDelphi';

var
  FGetJars: TFGetJars;

function GetProjectGroup: IOTAProjectGroup;
function GetCurrentProject: IOTAProject;
function GetCurrentProjectFileName: string;
function IniStrToMemoStr(InStr: string): string;
function MemoStrToIniStr(InStr: string): string;

implementation

uses
   JclSysUtils, Registry, UFAndroidManifest, JclStrings, IniFiles, UFRepositories, UFHistory, DCCStrs, UFSettings;

{$R *.dfm}

var
   FileLines: TStringList;
   NoClose: Boolean = False;
   UseJava2OP: Boolean = True;
   ConverterPath: String;

function RemoveComm(InString: String; var OutString: String): Boolean;
begin

   if Trim(Instring).StartsWith('//')
   then
      begin
         Result := False;
         Exit;
      end;

   if Pos('//', Instring) > 0
   then
      OutString := Trim(StrBefore('//', Instring))
   else
      OutString := InString;

   if Trim(OutString) = ''
   then
      Result := False
   else
      Result := True;

end;

function IniStrToMemoStr(InStr: string): string;
begin
   Result := StringReplace(InStr, '\n', #10, [rfReplaceAll]);
   Result := StringReplace(Result, '\r', #13, [rfReplaceAll]);
   Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);
end;

function MemoStrToIniStr(InStr: string): string;
begin

   Result := StringReplace(InStr, '\', '\\', [rfReplaceAll]);
   Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
   Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);

end;

function StrInArray(const Value : String;const ArrayOfString : Array of String) : Boolean;
var
 Loop : String;
begin
  for Loop in ArrayOfString do
  begin
    if Value = Loop then
    begin
       Exit(true);
    end;
  end;
  result := false;
end;

function FoundInFile(FilePath, SearchStr: string): Boolean;

var
  sl: TStringList;
  line: string;

begin

   Result := False;
   sl := TStringList.Create;

   try

      sl.LoadFromFile(FilePath);

      for line in sl do
        if Pos(AnsiLowerCase(SearchStr), AnsiLowerCase(Line)) <> 0
        then
           begin
             Result := True;
             Break;
           end;

   finally
      sl.Free;
   end;

end;

function GetProjectGroup: IOTAProjectGroup;

var
   IModuleServices: IOTAModuleServices;
   IModule: IOTAModule;
   i: Integer;

begin

   IModuleServices := BorlandIDEServices as IOTAModuleServices;

   Result := nil;

   for i := 0 to IModuleServices.ModuleCount - 1 do
      begin

         IModule := IModuleServices.Modules[i];

         if IModule.QueryInterface(IOTAProjectGroup, Result) = S_OK
         then
            Break;

      end;

end;

function GetCurrentProject: IOTAProject;

var
   Project: IOTAProject;
   ProjectGroup: IOTAProjectGroup;

begin

   Result := nil;

   ProjectGroup := GetProjectGroup;

   if Assigned(ProjectGroup)
   then
      begin

         Project := ProjectGroup.ActiveProject;

         if Assigned(Project)
         then
            Result := Project;

      end;

end;

function GetCurrentProjectFileName: string;

var
  IProject: IOTAProject;
begin
  Result := '';

  IProject := GetCurrentProject;
  if Assigned(IProject) then
  begin
    Result := IProject.FileName;
  end;
end;

procedure TFGetJars.BNewJobClick(Sender: TObject);
begin

   MJars.Text := '';
   MAddJars.Text := '';
   MExclJars.Text := '';
   MExclFinal.Text := '';
   MStatus.Text := '';

   LEJobName.Text := '';

end;

procedure TFGetJars.BSaveClick(Sender: TObject);
begin
   SaveJob;
end;

procedure TFGetJars.Button1Click(Sender: TObject);

var
   PlatformSDKServices: IOTAPlatformSDKServices;
   AndroidSDK: IOTAPlatformSDKAndroid;
   AaptPath: string;
   BuildToolsVer: string;
   ProjectOptionsConfigurations: IOTAProjectOptionsConfigurations;
   x, i, y: integer;
   TmpStr: String;
   Found: Boolean;

begin

   If Supports(GetActiveProject.ProjectOptions, IOTAProjectOptionsConfigurations, ProjectOptionsConfigurations)
   Then
      begin

         Found := False;

         for x := 0 to ProjectOptionsConfigurations.ConfigurationCount - 1 do
            begin

              ShowMessage(ProjectOptionsConfigurations.Configurations[x].Name);

              if ProjectOptionsConfigurations.Configurations[x].Name = GetCurrentProject.CurrentConfiguration
              then
                 begin

                    if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform] <> nil
                    then
                       begin

                          ShowMessage(GetCurrentProject.CurrentPlatform);

                          for y := 0 to ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].PropertyCount - 1 do
                             begin

                                if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y] = 'VerInfo_Keys'
                                then
                                   begin

                                      Found := True;

                                      ShowMessage(ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y]);
                                      TmpStr := StrBefore(';', StrAfter('package=', ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].GetValue(ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y], True)));

                                      if Pos('$(MSBuildProjectName)', TmpStr) > 0
                                      then
                                         TmpStr := StringReplace(TmpStr, '$(MSBuildProjectName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);

                                      if Pos('$(ModuleName)', TmpStr) > 0
                                      then
                                         TmpStr := StringReplace(TmpStr, '$(ModuleName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);

                                      ShowMessage(TmpStr);
            //                                   FileLines.Add('        package="' + TmpStr + '">')

                                      Break;

                                   end;

                             end;

                       end;

                    Break;

                 end;
            end;

         if not Found
         then
            for x := 0 to ProjectOptionsConfigurations.ConfigurationCount - 1 do
            begin

              ShowMessage(ProjectOptionsConfigurations.Configurations[x].Name);

              if ProjectOptionsConfigurations.Configurations[x].Name = 'Base'
              then
                 begin

                    if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform] <> nil
                    then
                       begin

                          ShowMessage(GetCurrentProject.CurrentPlatform);

                          for y := 0 to ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].PropertyCount - 1 do
                             begin

                                if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y] = 'VerInfo_Keys'
                                then
                                   begin

                                      ShowMessage(ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y]);
                                      TmpStr := StrBefore(';', StrAfter('package=', ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].GetValue(ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y], True)));

                                      if Pos('$(MSBuildProjectName)', TmpStr) > 0
                                      then
                                         TmpStr := StringReplace(TmpStr, '$(MSBuildProjectName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);

                                      if Pos('$(ModuleName)', TmpStr) > 0
                                      then
                                         TmpStr := StringReplace(TmpStr, '$(ModuleName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);

                                      ShowMessage(TmpStr);
            //                                   FileLines.Add('        package="' + TmpStr + '">')

                                      Break;

                                   end;

                             end;

                       end;

                    Break;

                 end;
            end;

      end;
//  PlatformSDKServices := (BorlandIDEServices as IOTAPlatformSDKServices);
//  AndroidSDK := PlatformSDKServices.GetDefaultForPlatform('Android') as IOTAPlatformSDKAndroid;
//  AaptPath := '"' + AndroidSDK.SDKAaptPath + '"';
//  BuildToolsVer := StrRestOf(ExtractFileDir(AaptPath), StrLastPos('\', ExtractFileDir(AaptPath)) + 1);
//  ShowMessage(BuildToolsVer);
end;

procedure TFGetJars.CBProjJobsSelect(Sender: TObject);
begin

   LoadJob(CBProjJobs.Items[CBProjJobs.ItemIndex]);

end;

procedure TFGetJars.ExecOut(const Text: string);
begin

   TThread.Synchronize(TThread.CurrentThread,
   procedure
   begin
      MStatus.Text := MStatus.Text + Text;
      SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
   end);

end;

function TFGetJars.SaveJob: Boolean;

var
   i: integer;

begin

   if (Trim(MJars.Text) = '') and
      (Trim(MAddJars.Text) = '')
   then
      begin
         ShowMessage('Please enter dependencies');
         MJars.SetFocus;
         Exit(False);
      end;

   if Trim(LEJobName.Text) = ''
   then
      begin
         ShowMessage('Please enter JobName');
         LEJobName.SetFocus;
         Exit(False);
      end;

   for i := 0 to MJars.Lines.Count - 1 do
      begin
         MJars.Lines[i] := StringReplace(MJars.Lines[i], 'compile ', '', [rfIgnoreCase]);
         MJars.Lines[i] := StringReplace(MJars.Lines[i], 'implementation ', '', [rfIgnoreCase]);
      end;

   QGetJobByName.Close;
   QGetJobByName.ParamByName('JobName').AsString := Trim(LEJobName.Text);
   QGetJobByName.Open;

   if QGetJobByName.isEmpty
   then
      begin

        TJobs.Insert;

        QGetID.Close;
        QGetID.Open;

        if QGetID.FieldByName('NewID').IsNull
        then
           TJobs.FieldByName('ID').AsInteger := 1
        else
           TJobs.FieldByName('ID').AsInteger := QGetID.FieldByName('NewID').AsInteger;

        TJobs.FieldByName('JobName').AsString :=  Trim(LEJobName.Text);

        TJobs.Post;


      end;

   if TRepositories.RecordCount = 0
   then
      begin
         TRepositories.InsertRecord(['mavenCentral', 'mavenCentral()']);
         TRepositories.InsertRecord(['google', 'google()']);
         TRepositories.InsertRecord(['jcenter', 'jcenter()']);
      end;

   QGetCurrJob.Close;
   QGetCurrJob.ParamByName('JobName').AsString := Trim(LEJobName.Text);
   QGetCurrJob.Open;

   if ((QGetCurrJob.RecordCount > 0) and
      ((MJars.Lines.Text <> QGetCurrJob.FieldByName('Dependencies').AsString) or
       (MJars.Lines.Text <> QGetCurrJob.FieldByName('AddDependencies').AsString) or
       (MJars.Lines.Text <> QGetCurrJob.FieldByName('ExclJNI').AsString) or
       (MJars.Lines.Text <> QGetCurrJob.FieldByName('ExclFinal').AsString))) or
     (QGetCurrJob.RecordCount = 0)
   then
      begin

         QInsHist.ParamByName('JobName').AsString := Trim(LEJobName.Text);
         QInsHist.ParamByName('SaveDate').AsDateTime := Now;
         QInsHist.ParamByName('Dependencies').AsString := MJars.Lines.Text;
         QInsHist.ParamByName('AddDependencies').AsString := MAddJars.Lines.Text;
         QInsHist.ParamByName('ExclJNI').AsString := MExclJars.Lines.Text;
         QInsHist.ParamByName('ExclFinal').AsString := MExclFinal.Lines.Text;

         if TSInclRes.State = tssOn
         then
            QInsHist.ParamByName('InclRes').AsBoolean := True
         else
            QInsHist.ParamByName('InclRes').AsBoolean := False;

         QInsHist.ExecSQL;

      end;

   if QGetCurrJob.RecordCount = 0
   then
      begin

         CBProjJobs.Items.Text := '';

         TJobs.First;

         while not TJobs.Eof do
            begin
               CBProjJobs.Items.Add(TJobs.FieldByName('JobName').AsString);
               TJobs.Next;
            end;

         if CBProjJobs.Items.Count > 0
         then
            LoadJob(CBProjJobs.Items[CBProjJobs.Items.Count - 1]);

      end;

  Result := True;

end;

procedure TFGetJars.MISettingsClick(Sender: TObject);
begin

   with TRegIniFile.Create(REG_KEY) do
   try
      FSettings.BEJ2OPath.Text := ReadString(REG_BUILD_OPTIONS, 'Java2op Location', '');
      FSettings.BEJIPath.Text := ReadString(REG_BUILD_OPTIONS, 'JavaImport Location', '');
      FSettings.RBJava2OP.Checked := ReadBool(REG_BUILD_OPTIONS, 'Java2OP', True);
      FSettings.RbJavaImport.Checked := not ReadBool(REG_BUILD_OPTIONS, 'Java2OP', True);
   finally
      Free;
   end;

   if FSettings.ShowModal = mrOK
   then
      with TRegIniFile.Create(REG_KEY) do
      try

         UseJava2OP := FSettings.RBJava2OP.Checked;

         if UseJava2OP
         then
            ConverterPath := FSettings.BEJ2OPath.Text
         else
            ConverterPath := FSettings.BEJIPath.Text;

      finally
         Free;
      end;

end;

procedure TFGetJars.LoadJob(JobNam: String);
begin

   LEJobName.Text := JobNam;

   QGetCurrJob.Close;
   QGetCurrJob.ParamByName('JobName').AsString := JobNam;
   QGetCurrJob.Open;

   MJars.Lines.Text := QGetCurrJob.FieldByName('Dependencies').AsString;
   MAddJars.Lines.Text := QGetCurrJob.FieldByName('AddDependencies').AsString;
   MExclJars.Lines.Text := QGetCurrJob.FieldByName('ExclJNI').AsString;
   MExclFinal.Lines.Text := QGetCurrJob.FieldByName('ExclFinal').AsString;
   CBProjJobs.Text := JobNam;

   if QGetCurrJob.FieldByName('InclRes').AsBoolean
   then
      TSInclRes.State := tssOn
   else
      TSInclRes.State := tssOff;

end;

procedure TFGetJars.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

   if NoClose
   then
      CanClose := False;

end;

procedure TFGetJars.FormShow(Sender: TObject);
begin

   with TRegIniFile.Create(REG_KEY) do
   try

      UseJava2OP := ReadBool(REG_BUILD_OPTIONS, 'Java2OP', True);

      if UseJava2OP
      then
         ConverterPath := ReadString(REG_BUILD_OPTIONS, 'Java2op Location', '')
      else
         ConverterPath := ReadString(REG_BUILD_OPTIONS, 'JavaImport Location', '');

   finally
      Free;
   end;

   FDCJobs.Connected := False;

   if not FileExists(StrBefore('.dproj', GetCurrentProjectFileName) + 'GJ.db')
   then
      begin
         FDCJobs.Params.Database := StrBefore('.dproj', GetCurrentProjectFileName) + 'GJ.db';
         FDCJobs.Connected := True;
         QDefDB.ExecSQL;
      end
   else
      begin
         FDCJobs.Params.Database := StrBefore('.dproj', GetCurrentProjectFileName) + 'GJ.db';
         FDCJobs.Connected := True;
      end;

   TJobs.Active := True;
   THistory.Active := True;
   TRepositories.Active := True;
   TParms.Active := True;

   MStatus.Text := '';
   MJars.Text := '';
   MAddJars.Text := '';
   MExclJars.Text := '';
   LEJobName.Text := '';
   MJars.SetFocus;
   ASPB.Position := 0;

   CBProjJobs.Items.Text := '';

   TJobs.First;

   while not TJobs.Eof do
      begin
         CBProjJobs.Items.Add(TJobs.FieldByName('JobName').AsString);
         TJobs.Next;
      end;

   if CBProjJobs.Items.Count > 0
   then
      LoadJob(CBProjJobs.Items[CBProjJobs.Items.Count - 1]);

end;

function PosHeader(Head: string): integer;

var
   z: integer;

begin

   Result := -1;

   for z := 0 to FileLines.Count - 1 do
      if Pos(Head, FileLines[z]) > 0
      then
         begin
            Result := z;
            Exit;
         end;

end;

procedure TFGetJars.BAddRepClick(Sender: TObject);

var
   i: integer;

begin

   if FRepositories.ShowModal = mrOk
   then
      begin

         QDelRepositories.ExecSQL;

         for i := 0 to FRepositories.CLBRepositories.Count - 1 do
            if FRepositories.CLBRepositories.Checked[i]
            then
               begin

                  TRepositories.InsertRecord([StrBefore(' ', FRepositories.CLBRepositories.Items[i]), StrAfter(' ', FRepositories.CLBRepositories.Items[i])]);

               end;

      end;

end;

function EditorAsString(SourceEditor : IOTASourceEditor) : String;

Const
  iBufferSize : Integer = 1024;

Var
  Reader : IOTAEditReader;
  iRead : Integer;
  iPosition : Integer;
  strBuffer : AnsiString;

Begin
  Result := '';
  Reader := SourceEditor.CreateReader;
  Try
    iPosition := 0;
    Repeat
      SetLength(strBuffer, iBufferSize);
      iRead := Reader.GetText(iPosition, PAnsiChar(strBuffer), iBufferSize);
      SetLength(strBuffer, iRead);
      Result := Result + String(strBuffer);
      Inc(iPosition, iRead);
    Until iRead < iBufferSize;
  Finally
    Reader := Nil;
  End;

End;


procedure TFGetJars.BCompileAllClick(Sender: TObject);
begin

   BClose.Enabled := False;
   BGo.Enabled := False;
   BAddRep.Enabled := False;
   BNewJob.Enabled := False;
   BSave.Enabled := False;
   BDelete.Enabled := False;
   BCompileAll.Enabled := False;
   BHistory.Enabled := False;
   NoClose := True;

   TThread.CreateAnonymousThread(
   procedure

   var
      x, i, y, z: Integer;
      FileList, DirList, DirList2: TArray<String>;
      zipFile: TZipFile;
      ManifestLines: TStringList;
      ProjDir, LibsDir, TmpDir, ResDir, MergResDir: String;
      ExcludeFile: Boolean;
      NestLevel: integer;
      Header: integer;
      Found: Boolean;
      TmpStr, TmpStr2: String;
      SLJobs, SLJars, SLAddJars, SLExclJars, CopyFiles: TStringList;
      ProjectOptionsConfigurations: IOTAProjectOptionsConfigurations;
      ShortName: string;
      PlatformSDKServices: IOTAPlatformSDKServices;
      AndroidSDK: IOTAPlatformSDKAndroid;
      AaptPath: string;
      JDKPath: string;
      SDKApiLevelPath: string;
      BuildToolsVer: string;
      PackName: string;
      MinSDK, TargetSDK: String;
      Errors: Boolean;
      SavedFile: String;
      ProjFileLinesIn: TStringList;
      ProjFileLinesOut: TStringList;
      IDEHandle: HWND;
      IDEThread: DWORD;
      OtherHandle: HWND;
      OtherThread: DWORD;
      ProjPackage: String;

   begin

      if not DirectoryExists(ExtractFilePath(GetCurrentProjectFileName) + 'Archive')
      then
         if not CreateDir(ExtractFilePath(GetCurrentProjectFileName) + 'Archive')
         then
           begin
              ShowMessage('There was an error creating Archive Folder');
              Exit;
           end;

      SavedFile := ExtractFilePath(GetCurrentProjectFileName) + 'Archive\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + 'GJ' + FormatDateTime('yyyymmddhhnnss', Now) + '.dproj';

      if not CopyFile(PChar(GetCurrentProjectFileName), PChar(SavedFile), False)
      then
        begin
           ShowMessage('There was an error making a backup of the projectfile');
           Exit;
        end;

      MStatus.Lines.Text := '';
      LStatus.Font.Color := clGreen;

      Errors := False;

      FileLines := TStringList.Create;

      SLJobs := TStringList.Create;
      SLJars := TStringList.Create;
      SLAddJars := TStringList.Create;
      SLExclJars := TStringList.Create;

      try

         try

           ProjDir := ExtractFilePath(GetCurrentProjectFileName);
           LibsDir := ProjDir + 'GradLibs';
           ResDir := ProjDir + 'GradRes';
           MergResDir := ProjDir + 'MergedRes';
           TmpDir := ProjDir + 'GradTmp';

           if DirectoryExists(LibsDir)
           then
              if not DeleteDirectory(LibsDir, False)
              then
                 begin
                    Errors := True;
                    ShowMessage('There was an error deleting GradLibs Folder');
                    Exit;
                 end;

           if DirectoryExists(LibsDir + '\Resources')
           then
              if not DeleteDirectory(LibsDir + '\Resources', False)
              then
                 begin
                    Errors := True;
                    ShowMessage('There was an error deleting GradLibs\Resources Folder');
                    Exit;
                 end;

           if DirectoryExists(ResDir)
           then
              if not DeleteDirectory(ResDir, False)
              then
                 begin
                    Errors := True;
                    ShowMessage('There was an error deleting GradRes Folder');
                    Exit;
                 end;

           if DirectoryExists(TmpDir)
           then
              if not DeleteDirectory(TmpDir, False)
              then
                 begin
                    Errors := True;
                    ShowMessage('There was an error deleting GradTmp Folder');
                    Exit;
                 end;

           if DirectoryExists(MergResDir)
           then
              if not DeleteDirectory(MergResDir, False)
              then
                 begin
                    Errors := True;
                    ShowMessage('There was an error deleting MergedRes Folder');
                    Exit;
                 end;

            if not DirectoryExists(ProjDir + 'Libs')
            then
               if not CreateDir(ProjDir + 'Libs')
               then
                  begin
                     Errors := True;
                     ShowMessage('There was an error creating ' + ProjDir + 'Libs Folder');
                     Exit;
                  end;

//            if not DirectoryExists(ProjDir + 'res')
//            then
//               if not CreateDir(ProjDir + 'res')
//               then
//                  begin
//                     Errors := True;
//                     ShowMessage('There was an error creating ' + ProjDir + 'res Folder');
//                     Exit;
//                  end;

           if not CreateDir(LibsDir)
           then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating GradLib Folder');
                 Exit;
              end;

           if not CreateDir(LibsDir + '\Resources')
           then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating GradLib\Resources Folder');
                 Exit;
              end;

           if not CreateDir(ResDir)
           then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating GradRes Folder');
                 Exit;
              end;

            if not CreateDir(MergResDir)
            then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating MergedRes Folder');
                 Exit;
              end;

            if not CreateDir(ResDir + '\src')
            then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating GradRes\src Folder');
                 Exit;
              end;

            if not CreateDir(ResDir + '\src\main')
            then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating GradRes\src\main Folder');
                 Exit;
              end;

            if not CreateDir(ResDir + '\src\main\res')
            then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating GradRes\src\main\res Folder');
                 Exit;
              end;

            if not CreateDir(LibsDir + '\R')
            then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating ' + LibsDir + '\R Folder');
                 Exit;
              end;

           if not CreateDir(TmpDir)
           then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating GradTmp Folder');
                 Exit;
              end;

           FileLines.Add('repositories {');

           TRepositories.First;

           while not TRepositories.Eof do
              begin
                 FileLines.Add('        ' + TRepositories.FieldByName('Link').AsString);
                 TRepositories.Next;
              end;

           FileLines.Add('}');
           FileLines.Add('configurations {');
           FileLines.Add('');
           FileLines.Add('    myConfig');
           FileLines.Add('}');
           FileLines.Add('');
           FileLines.Add('dependencies {');

           TThread.Synchronize(TThread.CurrentThread,
           procedure
           begin
              LStatus.Caption := 'Building Gradle';
           end);

           TJobs.First;

           while not TJobs.Eof do
              begin
                 SLJobs.Add(TJobs.FieldByName('JobName').AsString);
                 TJobs.Next;
              end;

           for i := 0 to SLJobs.Count - 1 do
              begin

                 QGetCurrJob.Close;
                 QGetCurrJob.ParamByName('JobName').AsString := SLJobs[i];
                 QGetCurrJob.Open;

                 SLJars.Text := QGetCurrJob.FieldByName('Dependencies').AsString;

                 for x := 0 to SLJars.count - 1 do
                    begin

                       if not RemoveComm(SLJars[x], TmpStr)
                       then
                          Continue;

                       Found := False;

                       for y := 0 to FileLines.count - 1 do
                          if Pos(TmpStr, FileLines[y]) > 0
                          then
                             Found := True;

                       if Found
                       then
                          Continue;

                       ExcludeFile := False;

                       for z := 0 to SLJobs.Count - 1 do
                          begin

                             QGetCurrJob.Close;
                             QGetCurrJob.ParamByName('JobName').AsString := SLJobs[z];
                             QGetCurrJob.Open;

                             SLExclJars.Text := QGetCurrJob.FieldByName('ExclFinal').AsString;

                             for y := 0 to SLExclJars.count - 1 do
                                begin

                                   if not RemoveComm(SLExclJars[y], TmpStr2)
                                   then
                                      Continue;

                                   if (TmpStr2[1] <> '/') and
                                      (TmpStr2[1] <> '¤')
                                   then
                                      if Pos(AnsiLowerCase(TmpStr2), AnsiLowerCase(FileList[x])) > 0
                                      then
                                         begin
                                            ExcludeFile := True;
                                            Break;
                                         end;

                                end;

                          end;

                       if ExcludeFile
                       then
                          Continue;

                       FileLines.Add('    myConfig ' + TmpStr);

                    end;

              end;

              FileLines.Add('');
              FileLines.Add('}');
              FileLines.Add('');
              FileLines.Add('task getDeps(type: Copy) {');
              FileLines.Add('    duplicatesStrategy = ''include''');
              FileLines.Add('    from configurations.myConfig');
              FileLines.Add('    into ''' + StringReplace(LibsDir, '\', '/', [rfReplaceAll]) + '''');
              FileLines.Add('}');

              FileLines.SaveToFile(TmpDir + '\Build.gradle');

              FileLines.Clear;

              FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
              FileLines.Add('cd "' + TmpDir + '"');
              FileLines.Add('Gradle');
              FileLines.SaveToFile(TmpDir + '\Commands.bat');

              if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
              then
                 begin
                    Errors := True;
                    ShowMessage('There was an error running Gradle on Build.gradle. Please check Output');
                    Exit;
                 end;

              TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                 MStatus.Lines.Add('');
                 LStatus.Caption := 'Downloading libraries.';
                 SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
              end);

              FileLines.DisposeOf;
              FileLines := TStringList.Create;
              FileLines.Clear;

              FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
              FileLines.Add('cd "' + TmpDir + '"');
              FileLines.Add('Gradle -q getDeps');
              FileLines.SaveToFile(TmpDir + '\Commands.bat');

              if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
              then
                 begin
                    Errors := True;
                    ShowMessage('There was an error running download task. Please check Output');
                    Exit;
                 end;

              TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                 MStatus.Lines.Add('');
                 LStatus.Caption := 'Copying Additional Dependencies';
                 SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
              end);

           CopyFiles := TStringList.Create;

           for i := 0 to SLJobs.Count - 1 do
              begin

                 QGetCurrJob.Close;
                 QGetCurrJob.ParamByName('JobName').AsString := SLJobs[i];
                 QGetCurrJob.Open;

                 SLAddJars.Text := QGetCurrJob.FieldByName('AddDependencies').AsString;

                 for x := 0 to SLAddJars.count - 1 do
                    begin

                       if not RemoveComm(SLAddJars[x], TmpStr)
                       then
                          Continue;

                       if not FileExists(TmpStr)
                       then
                          begin
                             ShowMessage('File ' + TmpStr + ' not found');
                             Exit;
                          end;

                       CopyFiles.Add(TmpStr);

                    end;

              end;

              ASPB.Max := CopyFiles.Count;
              ASPB.Position := 0;

              for x := 0 to CopyFiles.Count - 1 do
                 begin

                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       MStatus.Lines.Add('Copying: ' + CopyFiles[x]);
                       MStatus.Lines.Add('');
                       SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                    end);

                    if not CopyFile(PChar(CopyFiles[x]), PChar(LibsDir + '\' + EXtractFileName(CopyFiles[x])), False)
                    then
                       TThread.Synchronize(TThread.CurrentThread,
                       procedure
                       begin
                          MStatus.Lines.Add('Error copying: ' + CopyFiles[x]);
                          SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                          Exit;
                       end);

                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       ASPB.Position := x + 1;
                    end);

                 end;

              CopyFiles.DisposeOf;

              FileList := nil;
              FileList := TDirectory.GetFiles(LibsDir, '*.aar', TSearchOption.soTopDirectoryOnly);

              ASPB.Max := Length(FileList);

              zipFile := TZipFile.Create;

              LStatus.Caption := 'Extracting libraries.';

              for x := 0 to High(FileList) do
                 if zipFile.IsValid(FileList[x])
                 then
                    begin

                       TThread.Synchronize(TThread.CurrentThread,
                       procedure
                       begin
                          MStatus.Lines.Add('Extracting: ' + FileList[x]);
                          MStatus.Lines.Add('');
                          SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                       end);

                       try
                          zipFile.Open(FileList[x], zmRead);
                          zipFile.ExtractAll(LibsDir + '\' + StrBefore(ExtractFileExt(FileList[x]), ExtractFileName(FileList[x])));
                       except

                           on E: Exception do
                              begin
                                 Errors := True;
                                 ShowMessage(E.Message);
                                 Exit;
                              end;

                       end;

                       TThread.Synchronize(TThread.CurrentThread,
                       procedure
                       begin
                          ASPB.Position := x + 1;
                       end);

                    end;

              FileList := nil;
              FileList := TDirectory.GetFiles(LibsDir, '*.jar', TSearchOption.soAllDirectories);

              ASPB.Max := Length(FileList);

              for x := 0 to High(FileList) do
                 begin

                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       MStatus.Lines.Add('Extracting: ' + FileList[x]);
                       MStatus.Lines.Add('');
                       SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                    end);

                    if zipFile.IsValid(FileList[x])
                    then
                       begin

                          try
                             zipFile.Open(FileList[x], zmRead);
                             zipFile.ExtractAll(LibsDir + '\ExtractedClasses');
                          except

                              on E: Exception do
                                 begin
                                    Errors := True;
                                    ShowMessage(E.Message);
                                    Exit;
                                 end;

                          end;

                       end;

                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       ASPB.Position := x + 1;
                    end);

                 end;

              zipFile.Close;

              TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                 MStatus.Lines.Add('Classes Extracted');
                 MStatus.Lines.Add('');
                 LStatus.Caption := 'Creating ' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar';
                 MStatus.Lines.Add('Creating ' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar');
                 MStatus.Lines.Add('');
                 SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
              end);

              for i := 0 to SLJobs.Count - 1 do
                 begin

                    QGetCurrJob.Close;
                    QGetCurrJob.ParamByName('JobName').AsString := SLJobs[i];
                    QGetCurrJob.Open;

                    SLExclJars.Text := QGetCurrJob.FieldByName('ExclFinal').AsString;

                    for x := 0 to SLExclJars.count - 1 do
                       begin

                          if not RemoveComm(SLExclJars[x], TmpStr)
                          then
                             Continue;

                          if TmpStr[1] = '/'
                          then
                             DeleteDirectory(LibsDir + '\ExtractedClasses\' + StrAfter('/',  TmpStr), False);

                       end;

                    for x := 0 to SLExclJars.count - 1 do
                       begin

                          if not RemoveComm(SLExclJars[x], TmpStr)
                          then
                             Continue;

                          if TmpStr[1] = '¤'
                          then
                             DeleteFile(LibsDir + '\ExtractedClasses\' + StrAfter('¤',  TmpStr));

                       end;

                 end;

              FileList := nil;
              FileList := TDirectory.GetFiles(LibsDir + '\ExtractedClasses', '*.*', TSearchOption.soTopDirectoryOnly);

              for i := 0 to High(FileList) do
                 DeleteFile(FileList[i]);

              FileLines.DisposeOf;
              FileLines := TStringList.Create;

              FileLines.Add(ExtractFileDrive(LibsDir));
              FileLines.Add('cd "' + LibsDir + '\ExtractedClasses"');
              FileLines.Add('jar -cf ' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar *');
              FileLines.SaveToFile(TmpDir + '\Commands.bat');

              if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
              then
                 begin

                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       Errors := True;
                       ShowMessage('There was an error creating' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar. Please check Output');
                       Exit;
                    end);

                 end;

              TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                 MStatus.Lines.Add(StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar Created');
                 MStatus.Lines.Add('');
                 SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
              end);

            LStatus.Caption := 'Processing Resources.';

           for i := 0 to SLJobs.Count - 1 do
              begin

                 QGetCurrJob.Close;
                 QGetCurrJob.ParamByName('JobName').AsString := SLJobs[i];
                 QGetCurrJob.Open;

                 if QGetCurrJob.FieldByName('InclRes').AsBoolean
                 then
                    begin

                       SLAddJars.Text := QGetCurrJob.FieldByName('AddDependencies').AsString;

                       for x := 0 to SLAddJars.count - 1 do
                          begin

                             if not RemoveComm(SLAddJars[x], TmpStr)
                             then
                                Continue;

                             if not FileExists(TmpStr)
                             then
                                begin
                                   ShowMessage('File ' + TmpStr + ' not found');
                                   Exit;
                                end;

                             if ExtractFileExt(AnsiLowerCase(TmpStr)) = '.aar'
                             then
                                if not CopyFile(PChar(TmpStr), PChar(LibsDir + '\Resources\' + EXtractFileName(TmpStr)), False)
                                then
                                   TThread.Synchronize(TThread.CurrentThread,
                                   procedure
                                   begin
                                      MStatus.Lines.Add('Error copying: ' + TmpStr);
                                      SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                                      Exit;
                                   end);

                          end;

                       FileLines.DisposeOf;
                       FileLines := TStringList.Create;

                       FileLines.Add('repositories {');

                       TRepositories.First;

                       while not TRepositories.Eof do
                          begin
                             FileLines.Add('        ' + TRepositories.FieldByName('Link').AsString);
                             TRepositories.Next;
                          end;

                       FileLines.Add('}');
                       FileLines.Add('configurations {');
                       FileLines.Add('');
                       FileLines.Add('    myConfig');
                       FileLines.Add('}');
                       FileLines.Add('');
                       FileLines.Add('dependencies {');

                       SLJars.Text := QGetCurrJob.FieldByName('Dependencies').AsString;

                       for x := 0 to SLJars.count - 1 do
                          begin

                             if not RemoveComm(SLJars[x], TmpStr)
                             then
                                Continue;

                             Found := False;

                             for y := 0 to FileLines.count - 1 do
                                if Pos(TmpStr, FileLines[y]) > 0
                                then
                                   Found := True;

                             if Found
                             then
                                Continue;

                             ExcludeFile := False;

                             for z := 0 to SLJobs.Count - 1 do
                                begin

                                   QGetCurrJob.Close;
                                   QGetCurrJob.ParamByName('JobName').AsString := SLJobs[z];
                                   QGetCurrJob.Open;

                                   SLExclJars.Text := QGetCurrJob.FieldByName('ExclFinal').AsString;

                                   for y := 0 to SLExclJars.count - 1 do
                                      begin

                                         if not RemoveComm(SLExclJars[y], TmpStr2)
                                         then
                                            Continue;

                                         if (TmpStr2[1] <> '/') and
                                            (TmpStr2[1] <> '¤')
                                         then
                                            if Pos(AnsiLowerCase(TmpStr2), AnsiLowerCase(FileList[x])) > 0
                                            then
                                               begin
                                                  ExcludeFile := True;
                                                  Break;
                                               end;

                                      end;

                                end;

                             if ExcludeFile
                             then
                                Continue;

                             FileLines.Add('    myConfig ' + TmpStr);

                          end;

                       FileLines.Add('');
                       FileLines.Add('}');
                       FileLines.Add('');
                       FileLines.Add('task getDeps(type: Copy) {');
                       FileLines.Add('    duplicatesStrategy = ''include''');
                       FileLines.Add('    from configurations.myConfig');
                       FileLines.Add('    into ''' + StringReplace(LibsDir + '\Resources', '\', '/', [rfReplaceAll]) + '''');
                       FileLines.Add('}');

                       FileLines.SaveToFile(TmpDir + '\Build.gradle');

                       FileLines.DisposeOf;
                       FileLines := TStringList.Create;

                       FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
                       FileLines.Add('cd "' + TmpDir + '"');
                       FileLines.Add('Gradle');
                       FileLines.SaveToFile(TmpDir + '\Commands.bat');

                       if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
                       then
                          begin
                             Errors := True;
                             ShowMessage('There was an error running Gradle on Build.gradle. Please check Output');
                             Exit;
                          end;

                       FileLines.DisposeOf;
                       FileLines := TStringList.Create;
                       FileLines.Clear;

                       FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
                       FileLines.Add('cd "' + TmpDir + '"');
                       FileLines.Add('Gradle -q getDeps');
                       FileLines.SaveToFile(TmpDir + '\Commands.bat');

                       if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
                       then
                          begin
                             Errors := True;
                             ShowMessage('There was an error running download task. Please check Output');
                             Exit;
                          end;

                    end;

              end;

           FileList := nil;
           FileList := TDirectory.GetFiles(LibsDir + '\Resources', '*.aar', TSearchOption.soTopDirectoryOnly);

           ASPB.Max := Length(FileList);

           zipFile := TZipFile.Create;

           for y := 0 to High(FileList) do
              if zipFile.IsValid(FileList[y])
              then
                 begin

                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       MStatus.Lines.Add('Extracting: ' + FileList[y]);
                       MStatus.Lines.Add('');
                       SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                    end);

                    try
                       zipFile.Open(FileList[y], zmRead);
                       zipFile.ExtractAll(LibsDir + '\Resources\' + StrBefore(ExtractFileExt(FileList[y]), ExtractFileName(FileList[y])));
                    except

                        on E: Exception do
                           begin
                              Errors := True;
                              ShowMessage(E.Message);
                              Exit;
                           end;

                    end;

                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       ASPB.Position := y + 1;
                    end);

                 end;

            zipFile.Close;

            ProjFileLinesIn := TStringList.Create;
            ProjFileLinesOut := TStringList.Create;

            FileLines.DisposeOf;
            FileLines := TStringList.Create;
            FileLines.LoadFromFile(ExtractFilePath(GetCurrentProjectFileName) + 'AndroidManifest.template.xml');

            if FileExists(ProjDir + 'Libs\R.jar')
            then
               DeleteFile(ProjDir + 'Libs\R.jar');


           PlatformSDKServices := (BorlandIDEServices as IOTAPlatformSDKServices);
           AndroidSDK := PlatformSDKServices.GetDefaultForPlatform('Android') as IOTAPlatformSDKAndroid;
           AaptPath := '"' + AndroidSDK.SDKAaptPath + '"';
           BuildToolsVer := StrBefore('\', StrAfter('build-tools\', AndroidSDK.SDKAaptPath));
           SDKApiLevelPath := '"' + AndroidSDK.SDKApiLevel + '\Android.jar"';
           JDKPath := AndroidSDK.JDKPath;

           i := 0;
           while Pos('<uses-sdk android:minSdkVersion=', FileLines[i]) = 0 do
              Inc(i);

            if StrBefore('" android:targetSdkVersion=', StrAfter('<uses-sdk android:minSdkVersion="', FileLines[i])) = '%minSdkVersion%'
            then
               MinSDK := '23'
            else
               MinSDK := StrBefore('" android:targetSdkVersion=', StrAfter('<uses-sdk android:minSdkVersion="', FileLines[i]));

            if StrBefore('" />', StrAfter('android:targetSdkVersion="', FileLines[i])) = '%targetSdkVersion%'
            then
               TargetSDK := '32'
            else
               TargetSDK := StrBefore('" />', StrAfter('android:targetSdkVersion="', FileLines[i]));

           FileLines.DisposeOf;
           FileLines := TStringList.Create;
           FileLines.Clear;

           FileLines.Add('buildscript {');
           FileLines.Add('    repositories {');

           TRepositories.First;

           while not TRepositories.Eof do
              begin
                 FileLines.Add('        ' + TRepositories.FieldByName('Link').AsString);
                 TRepositories.Next;
              end;

           FileLines.Add('    }');
           FileLines.Add('');
           FileLines.Add('    dependencies {');
           FileLines.Add('        classpath "com.android.tools.build:gradle:4.1.3"');
           FileLines.Add('    }');
           FileLines.Add('}');
           FileLines.Add('');
           FileLines.Add('apply plugin: ''com.android.application'';');
           FileLines.Add('');
           FileLines.Add('android {');
           FileLines.Add('    compileSdkVersion ' + TargetSDK);
           FileLines.Add('    buildToolsVersion "' + BuildToolsVer + '"');
           FileLines.Add('');
           FileLines.Add('    defaultConfig {');
           FileLines.Add('        minSdkVersion ' + MinSDK);
           FileLines.Add('        targetSdkVersion ' + TargetSDK);
           FileLines.Add('        versionCode 1');
           FileLines.Add('        versionName "1.0"');
           FileLines.Add('        multiDexEnabled true');
           FileLines.Add('    }');
           FileLines.Add('');
           FileLines.Add('    buildTypes {');
           FileLines.Add('        release {');
           FileLines.Add('            minifyEnabled false');
           FileLines.Add('        }');
           FileLines.Add('        debug {');
           FileLines.Add('            minifyEnabled false');
           FileLines.Add('        }');
           FileLines.Add('    }');
           FileLines.Add('');
           FileLines.Add('    packagingOptions {');
           FileLines.Add('        exclude ''META-INF/DEPENDENCIES''');
           FileLines.Add('    }');
           FileLines.Add('');
           FileLines.Add('    compileOptions {');
           FileLines.Add('        sourceCompatibility JavaVersion.VERSION_1_8');
           FileLines.Add('        targetCompatibility JavaVersion.VERSION_1_8');
           FileLines.Add('    }');
           FileLines.Add('');
           FileLines.Add('    buildFeatures {');
           FileLines.Add('        viewBinding = true');
           FileLines.Add('    }');
           FileLines.Add('');
           FileLines.Add('    repositories {');

           TRepositories.First;

           while not TRepositories.Eof do
              begin
                 FileLines.Add('        ' + TRepositories.FieldByName('Link').AsString);
                 TRepositories.Next;
              end;

           FileLines.Add('    }');
           FileLines.Add('');
           FileLines.Add('}');
           FileLines.Add('');
           FileLines.Add('dependencies {');

           for i := 0 to SLJobs.Count - 1 do
              begin

                 QGetCurrJob.Close;
                 QGetCurrJob.ParamByName('JobName').AsString := SLJobs[i];
                 QGetCurrJob.Open;

                 if QGetCurrJob.FieldByName('InclRes').AsBoolean
                 then
                    begin

                       SLAddJars.Text := QGetCurrJob.FieldByName('AddDependencies').AsString;

                       for x := 0 to SLAddJars.count - 1 do
                          begin

                             if not RemoveComm(SLAddJars[x], TmpStr)
                             then
                                Continue;

                             if not FileExists(TmpStr)
                             then
                                begin
                                   ShowMessage('File ' + TmpStr + ' not found');
                                   Exit;
                                end;

                             if ExtractFileExt(AnsiLowerCase(TmpStr)) = '.aar'
                             then
                                FileLines.Add('    implementation files(''' + StringReplace(TmpStr, '\', '/', [rfReplaceAll]) + ''')');

                          end;

                       SLJars.Text := QGetCurrJob.FieldByName('Dependencies').AsString;

                       for x := 0 to SLJars.count - 1 do
                          begin

                             if not RemoveComm(SLJars[x], TmpStr)
                             then
                                Continue;

                             ExcludeFile := False;

                             for z := 0 to SLJobs.Count - 1 do
                                begin

                                   QGetCurrJob.Close;
                                   QGetCurrJob.ParamByName('JobName').AsString := SLJobs[z];
                                   QGetCurrJob.Open;

                                   SLExclJars.Text := QGetCurrJob.FieldByName('ExclFinal').AsString;

                                   for y := 0 to SLExclJars.count - 1 do
                                      begin

                                         if not RemoveComm(SLExclJars[y], TmpStr2)
                                         then
                                            Continue;

                                         if (TmpStr2[1] <> '/') and
                                            (TmpStr2[1] <> '¤')
                                         then
                                            if Pos(AnsiLowerCase(TmpStr2), AnsiLowerCase(FileList[x])) > 0
                                            then
                                               begin
                                                  ExcludeFile := True;
                                                  Break;
                                               end;

                                      end;

                                end;

                             if ExcludeFile
                             then
                                Continue;

                             Found := False;

                             for y := 0 to FileLines.count - 1 do
                                if Pos(TmpStr, FileLines[y]) > 0
                                then
                                   Found := True;

                             if not Found
                             then
                                FileLines.Add('    implementation ' + TmpStr);

                          end;

                    end;
              end;

           FileLines.Add('}');

           FileLines.SaveToFile(ResDir + '\Build.Gradle');

           FileLines.DisposeOf;
           FileLines := TStringList.Create;
           FileLines.Clear;

           FileLines.Add('<?xml version="1.0" encoding="utf-8"?>');
           FileLines.Add('<manifest xmlns:android="http://schemas.android.com/apk/res/android"');

            If Supports(GetActiveProject.ProjectOptions, IOTAProjectOptionsConfigurations, ProjectOptionsConfigurations)
            Then
               begin

                  Found := False;

                  for x := 0 to ProjectOptionsConfigurations.ConfigurationCount - 1 do
                     begin

                       if ProjectOptionsConfigurations.Configurations[x].Name = GetCurrentProject.CurrentConfiguration
                       then
                          begin

                             if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform] <> nil
                             then
                                begin

                                   for y := 0 to ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].PropertyCount - 1 do
                                      begin

                                         if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y] = 'VerInfo_Keys'
                                         then
                                            begin

                                               Found := True;

                                               ProjPackage := StrBefore(';', StrAfter('package=', ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].GetValue(ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y], True)));

                                               if Pos('$(MSBuildProjectName)', ProjPackage) > 0
                                               then
                                                  ProjPackage := StringReplace(ProjPackage, '$(MSBuildProjectName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);

                                               if Pos('$(ModuleName)', ProjPackage) > 0
                                               then
                                                  ProjPackage := StringReplace(ProjPackage, '$(ModuleName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);;

                                               FileLines.Add('        package="' + ProjPackage + '">');

                                               Break;

                                            end;

                                      end;

                                end;

                             Break;

                          end;
                     end;

                  if not Found
                  then
                     for x := 0 to ProjectOptionsConfigurations.ConfigurationCount - 1 do
                     begin

                       if ProjectOptionsConfigurations.Configurations[x].Name = 'Base'
                       then
                          begin

                             if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform] <> nil
                             then
                                begin

                                   for y := 0 to ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].PropertyCount - 1 do
                                      begin

                                         if ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y] = 'VerInfo_Keys'
                                         then
                                            begin

                                               TmpStr := StrBefore(';', StrAfter('package=', ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].GetValue(ProjectOptionsConfigurations.Configurations[x].PlatformConfiguration[GetCurrentProject.CurrentPlatform].Properties[y], True)));

                                               if Pos('$(MSBuildProjectName)', TmpStr) > 0
                                               then
                                                  TmpStr := StringReplace(TmpStr, '$(MSBuildProjectName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);

                                               if Pos('$(ModuleName)', TmpStr) > 0
                                               then
                                                  TmpStr := StringReplace(TmpStr, '$(ModuleName)', StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)), []);

                                               FileLines.Add('        package="' + TmpStr + '">');

                                               Break;

                                            end;

                                      end;

                                end;

                             Break;

                          end;
                     end;

               end;

           FileLines.Add('  <application');
           FileLines.Add('      android:allowBackup="true"');
           FileLines.Add('      android:supportsRtl="true"/>');

           FileLines.Add('</manifest>');

           FileLines.SaveToFile(ResDir + '\src\main\AndroidManifest.xml');

           FileLines.DisposeOf;
           FileLines := TStringList.Create;
           FileLines.Clear;

           FileLines.Add('sdk.dir=' + StringReplace(StrBefore('\platforms', AndroidSDK.SDKApiLevel), '\', '\\', [rfReplaceAll]));
           FileLines.SaveToFile(ResDir + '\local.properties');

           FileLines.DisposeOf;
           FileLines := TStringList.Create;
           FileLines.Clear;

           FileLines.Add('org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8');
           FileLines.Add('android.useAndroidX=true');
           FileLines.Add('android.enableJetifier=true');
           FileLines.Add('android.enableResourceOptimizations=false');
           FileLines.SaveToFile(ResDir + '\gradle.properties');

           if DirectoryExists(ProjDir + '\res')
           then
              TDirectory.Copy(ProjDir + '\res', ResDir + '\src\main\res');

           FileLines.DisposeOf;
           FileLines := TStringList.Create;
           FileLines.Clear;

           FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
           FileLines.Add('cd "' + ResDir + '"');
           FileLines.Add('Gradle wrapper');
           FileLines.SaveToFile(TmpDir + '\Commands.bat');

           if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
           then
              begin
                 Errors := True;
                 ShowMessage('There was an error running resource task. Please check Output');
                 Exit;
              end;

           TThread.Synchronize(TThread.CurrentThread,
           procedure
           begin
              SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
           end);

           FileLines.DisposeOf;
           FileLines := TStringList.Create;
           FileLines.Clear;

           FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
           FileLines.Add('cd "' + ResDir + '"');

           if GetCurrentProject.CurrentConfiguration = 'Debug'
           then
              FileLines.Add('Gradlew mergeDebugResources')
           else
              FileLines.Add('Gradlew mergeReleaseResources');

           FileLines.SaveToFile(TmpDir + '\Commands.bat');

           if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
           then
              begin
                 ShowMessage('There was an error running resource task. Please check Output');
                 Exit;
              end;

           TThread.Synchronize(TThread.CurrentThread,
           procedure
           begin
              SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
           end);

           FileLines.DisposeOf;
           FileLines := TStringList.Create;
           FileLines.Clear;

           FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
           FileLines.Add('cd "' + ResDir + '"');

           if GetCurrentProject.CurrentConfiguration = 'Debug'
           then
              FileLines.Add('Gradlew processDebugResources')
           else
              FileLines.Add('Gradlew processReleaseResources');

           FileLines.SaveToFile(TmpDir + '\Commands.bat');

           if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
           then
              begin
                 Errors := True;
                 ShowMessage('There was an error running resource task. Please check Output');
                 Exit;
              end;

           TThread.Synchronize(TThread.CurrentThread,
           procedure
           begin
              SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
           end);

           if GetCurrentProject.CurrentConfiguration = 'Debug'
           then
              TDirectory.Copy(ResDir + '\build\intermediates\incremental\mergeDebugResources\merged.dir', MergResDir)
           else
              TDirectory.Copy(ResDir + '\build\intermediates\incremental\mergeReleaseResources\merged.dir', MergResDir);

           DirList := TDirectory.GetDirectories(LibsDir + '\Resources', 'res', TSearchOption.soAllDirectories);

           if not CreateDir(LibsDir + '\R\Obj')
           then
              begin
                 Errors := True;
                 ShowMessage('There was an error creating ' + LibsDir + '\R\Obj Folder');
                 Exit;
              end;

           for x := 0 to High(DirList) do
              begin

                 DirList2 := TDirectory.GetDirectories(DirList[x], '*', TSearchOption.soAllDirectories);

                 for y := 0 to High(DirList2) do
                    begin

                       if Pos('values', DirList2[y]) = 0
                       then
                          begin

                             TmpStr := StrRestOf(DirList2[y], StrLastPos('\', DirList2[y]) + 1);

                             TDirectory.Copy(DirList2[y], MergResDir + '\' + TmpStr);

                          end;

                    end;

                 if not TDirectory.IsEmpty(DirList[x])
                 then
                    begin

                       FileList := nil;
                       FileList := TDirectory.GetFiles(DirList[x], '*.xml', TSearchOption.soAllDirectories);

                       for y := 0 to High(FileList) do
                          begin
                             FileLines.LoadFromFile(FileList[y]);
                             FileLines.Text := StringReplace(FileLines.Text, 'xmlns:app="http://schemas.android.com/apk/res-auto"', 'xmlns:app="http://schemas.android.com/apk/lib-auto"', []);
                             FileLines.SaveToFile(FileList[y]);
                          end;

                       if DirectoryExists(LibsDir + '\R\Src')
                       then
                          if not DeleteDirectory(LibsDir + '\R\Src', False)
                          then
                             begin
                                Errors := True;
                                ShowMessage('There was an error deleting ' + LibsDir + '\R\Src Folder');
                                Exit;
                             end;

                       if not CreateDir(LibsDir + '\R\Src')
                       then
                          begin
                             Errors := True;
                             ShowMessage('There was an error creating ' + LibsDir + '\R\Src Folder');
                             Exit;
                          end;

                       FileLines.DisposeOf;
                       FileLines := TStringList.Create;
                       FileLines.Clear;

                       FileLines.LoadFromFile(StrLeft(DirList[x], StrILastPos('\', DirList[x])) + 'AndroidManifest.xml');

                       y := 0;

                       while Pos('package="', FileLines[y]) = 0 do
                          Inc(y);

                       PackName := Trim(StrBefore('"', StrAfter('package="', FileLines[y])));
                       PackName := StringReplace(PackName, '.', '\', [rfReplaceAll]);

                       y := 0;

                       while (y < FileLines.Count) and (Pos('android:targetSdkVersion="', FileLines[y]) = 0) do
                          Inc(y);

                       if y = FileLines.Count
                       then
                          TmpStr2 := SDKApiLevelPath
                       else
                          begin
                             TargetSDK := Trim(StrBefore('"', StrAfter('android:targetSdkVersion="', FileLines[y])));
                             TmpStr2 := StrBefore('platforms\', SDKApiLevelPath) + 'platforms\android-' + TargetSDK + '\Android.jar"';
                          end;

                       FileLines.Text := StringReplace(FileLines.Text, '${applicationId}', ProjPackage, [rfReplaceAll]);
                       FileLines.SaveToFile(StrLeft(DirList[x], StrILastPos('\', DirList[x])) + 'AndroidManifest.xml');

                       FileLines.DisposeOf;
                       FileLines := TStringList.Create;
                       FileLines.Clear;

                       TmpStr := AaptPath +
                                ' package -f -m -M ' +
                                '"' + StrLeft(DirList[x], StrILastPos('\', DirList[x])) + 'AndroidManifest.xml"' +
                                ' -I ' +
                                TmpStr2 +
                                ' -S ' +
                                '"' + DirList[x] + '"' +
                                ' -J ' +
                                '"' + LibsDir + '\R\Src"';

                       FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
                       FileLines.Add('cd "' + ResDir + '"');
                       FileLines.Add(TmpStr);

                       FileLines.SaveToFile(TmpDir + '\Commands.bat');

                       TThread.Synchronize(TThread.CurrentThread,
                       procedure
                       begin
                          MStatus.Lines.Add('');
                          SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                       end);

                       if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
                       then
                          begin

                             Errors := True;

                             TThread.Synchronize(TThread.CurrentThread,
                             procedure
                             begin
                                MStatus.Lines.Add('');
                                MStatus.Lines.Add('Step failed');
                                SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                             end);

                          end;

                       if FileExists(LibsDir + '\R\Src\' + StringReplace(PackName, '.', '\', [rfReplaceAll]) + '\R.java')
                       then
                          begin

                             FileLines.DisposeOf;
                             FileLines := TStringList.Create;
                             FileLines.Clear;

                             TmpStr := '"' + JDKPath + '\bin\javac"' +
                                       ' -verbose -d ' +
                                       '"' + LibsDir + '\R\Obj"' +
                                       ' -classpath ' +
                                       TmpStr2 +
                                       ';"' + LibsDir + '\R\Obj"' +
                                       ' -sourcepath "' + LibsDir + '\R\Src" "' + LibsDir + '\R\Src\' + StringReplace(PackName, '.', '\', [rfReplaceAll]) + '\R.java"';

                             FileLines.Add(TmpStr);

                             FileLines.SaveToFile(TmpDir + '\Commands.bat');

                             if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
                             then
                                begin
                                   Errors := True;
                                end;

                             TThread.Synchronize(TThread.CurrentThread,
                             procedure
                             begin
                                SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                             end);

                          end;
                    end;

              end;

           if not TDirectory.IsEmpty(LibsDir + '\R\Obj')
           then
              begin

                 FileLines.DisposeOf;
                 FileLines := TStringList.Create;
                 FileLines.Clear;

                 FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
                 FileLines.Add('cd "' + LibsDir + '\R\Obj"');
                 FileLines.Add('jar -cf R.jar *');
                 FileLines.SaveToFile(TmpDir + '\Commands.bat');

                 if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
                 then
                    begin
                       Errors := True;
                       ShowMessage('There was an error creating R.jar. Please check Output');
                       Exit;
                    end;

                 TThread.Synchronize(TThread.CurrentThread,
                 procedure
                 begin
                    SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                 end);

                 if not MoveFile(PChar(LibsDir + '\R\Obj\R.jar'), PChar(ProjDir + '\Libs\R.jar'))
                 then
                    begin
                       Errors := True;
                       ShowMessage('Could not move file R.jar to ' + ProjDir + '\Libs');
                       Exit;
                    end;

              end;

            ProjFileLinesIn.LoadFromFile(GetCurrentProjectFileName);

              i := 0;

              while  (i < ProjFileLinesIn.Count) and (Pos('<BuildConfiguration', ProjFileLinesIn[i]) = 0) do
              begin

                 if Pos('<JavaReference Include="Libs\R.jar">' , ProjFileLinesIn[i]) > 0
                 then
                    begin

                       while Pos('</JavaReference>', ProjFileLinesIn[i]) = 0 do
                          Inc(i);

                       Inc(i);

                    end;

                 ProjFileLinesOut.Add(ProjFileLinesIn[i]);
                 Inc(i);

              end;

              if FileExists(ProjDir + 'Libs\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar')
              then
                 if not DeleteFile(ProjDir + 'Libs\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar')
                 then
                    begin
                       ShowMessage('Could not delete ' + LibsDir + '\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar.');
                       Exit;
                    end;

              if not CopyFile(PChar(LibsDir + '\ExtractedClasses\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar'), PChar(ProjDir + 'Libs\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar'), True)
              then
                 TThread.Synchronize(TThread.CurrentThread,
                 procedure
                 begin
                    MStatus.Lines.Add('Error copying: ' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar');
                    SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                    Exit;
                 end);

             if not FoundInFile(GetCurrentProjectFileName, '<JavaReference Include="Libs\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar">')
             then
                begin

                    ProjFileLinesOut.Add('                <JavaReference Include="Libs\' + StrBefore('.dproj', ExtractFileName(GetCurrentProjectFileName)) + '.jar">');
                    ProjFileLinesOut.Add('                    <ContainerId>ClassesdexFile64</ContainerId>');
                    ProjFileLinesOut.Add('                    <Disabled/>');
                    ProjFileLinesOut.Add('                </JavaReference>');

                end;

            FileList := nil;

           if FileExists(ProjDir + 'Libs\R.jar')
           then
              begin

                 ProjFileLinesOut.Add('                <JavaReference Include="Libs\R.jar">');
                 ProjFileLinesOut.Add('                    <ContainerId>ClassesdexFile64</ContainerId>');
                 ProjFileLinesOut.Add('                    <Disabled/>');
                 ProjFileLinesOut.Add('                </JavaReference>');

              end;

            FileList := TDirectory.GetFiles(MergResDir, '*.*', TSearchOption.soAllDirectories);

           ProjFileLinesOut.Add(ProjFileLinesIn[i]);
           Inc(i);

           while  (i < ProjFileLinesIn.Count) and (Pos('<Deployment Version="', ProjFileLinesIn[i]) = 0) do
              begin

                 ProjFileLinesOut.Add(ProjFileLinesIn[i]);
                 Inc(i);

              end;

           ProjFileLinesOut.Add(ProjFileLinesIn[i]);

           if (FileList <> nil) and
              (Length(FileList) > 0)
           then
              begin

                 for x := 0 to High(FileList) do
                    begin

                       ShortName := StrAfter(ProjDir, FileList[x]);

                       TmpStr := StrLeft(FileList[x], StrLastPos('\', FileList[x]) - 1);
                       TmpStr := StrRestOf(TmpStr, StrLastPos('\', TmpStr) + 1);
                       TmpStr := '.\res\' + TmpStr;

                       ProjFileLinesOut.Add('                <DeployFile LocalName="' + ShortName + '" Configuration="Debug" Class="File">');
                       ProjFileLinesOut.Add('                    <Platform Name="Android">');
                       ProjFileLinesOut.Add('                        <RemoteDir>' + TmpStr + '</RemoteDir>');
                       ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>');
                       ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                       ProjFileLinesOut.Add('                    </Platform>');
                       ProjFileLinesOut.Add('                </DeployFile>');
                       ProjFileLinesOut.Add('                <DeployFile LocalName="' + ShortName + '" Configuration="Release" Class="File">');
                       ProjFileLinesOut.Add('                    <Platform Name="Android">');
                       ProjFileLinesOut.Add('                        <RemoteDir>' + TmpStr + '</RemoteDir>');
                       ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>');
                       ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                       ProjFileLinesOut.Add('                    </Platform>');
                       ProjFileLinesOut.Add('                </DeployFile>');
                       ProjFileLinesOut.Add('                <DeployFile LocalName="' + ShortName + '" Configuration="Debug" Class="File">');
                       ProjFileLinesOut.Add('                    <Platform Name="Android64">');
                       ProjFileLinesOut.Add('                        <RemoteDir>' + TmpStr + '</RemoteDir>');
                       ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>');
                       ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                       ProjFileLinesOut.Add('                    </Platform>');
                       ProjFileLinesOut.Add('                </DeployFile>');
                       ProjFileLinesOut.Add('                <DeployFile LocalName="' + ShortName + '" Configuration="Release" Class="File">');
                       ProjFileLinesOut.Add('                    <Platform Name="Android64">');
                       ProjFileLinesOut.Add('                        <RemoteDir>' + TmpStr + '</RemoteDir>');
                       ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(ShortName) + '</RemoteName>');
                       ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                       ProjFileLinesOut.Add('                    </Platform>');
                       ProjFileLinesOut.Add('                </DeployFile>');

                    end;

              end;

           FileList := nil;
           FileList := TDirectory.GetFiles(LibsDir, '*.so', TSearchOption.soAllDirectories);

           if Length(FileList) > 0
           then
              begin

                 if not DirectoryExists(ProjDir + 'Libs\SoFiles')
                 then
                    begin
                       CreateDir(ProjDir + 'Libs\SoFiles');
                       CreateDir(ProjDir + 'Libs\SoFiles\32');
                       CreateDir(ProjDir + 'Libs\SoFiles\64');
                    end;

                 for x := 0 to High(FileList) do
                    begin

                       if Pos('armeabi-v7a', FileList[x]) > 0
                       then
                          begin

                             if FileExists(ProjDir + 'Libs\SoFiles\32\' + ExtractFileName(FileList[x]))
                             then
                                DeleteFile(ProjDir + 'Libs\SoFiles\32\' + ExtractFileName(FileList[x]));

                             CopyFile(PChar(FileList[x]), PChar(ProjDir + 'Libs\SoFiles\32\' + ExtractFileName(FileList[x])), False);

                             if not FoundInFile(GetCurrentProjectFileName, '<DeployFile LocalName="Libs\SoFiles\32\' + ExtractFileName(FileList[x]))
                             then
                               begin

                                  ProjFileLinesOut.Add('                <DeployFile LocalName="Libs\SoFiles\32\' + ExtractFileName(FileList[x]) + '" Configuration="Release" Class="File">');
                                  ProjFileLinesOut.Add('                    <Platform Name="Android">');
                                  ProjFileLinesOut.Add('                        <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>');
                                  ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(FileList[x]) + '</RemoteName>');
                                  ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                                  ProjFileLinesOut.Add('                    </Platform>');
                                  ProjFileLinesOut.Add('                </DeployFile>');

                                  ProjFileLinesOut.Add('                <DeployFile LocalName="Libs\SoFiles\32\' + ExtractFileName(FileList[x]) + '" Configuration="Debug" Class="File">');
                                  ProjFileLinesOut.Add('                    <Platform Name="Android">');
                                  ProjFileLinesOut.Add('                        <RemoteDir>library\lib\armeabi-v7a\</RemoteDir>');
                                  ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(FileList[x]) + '</RemoteName>');
                                  ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                                  ProjFileLinesOut.Add('                    </Platform>');
                                  ProjFileLinesOut.Add('                </DeployFile>');

                               end;

                          end;

                       if Pos('arm64-v8a', FileList[x]) > 0
                       then
                          begin

                             if FileExists(ProjDir + 'Libs\SoFiles\64\' + ExtractFileName(FileList[x]))
                             then
                                DeleteFile(ProjDir + 'Libs\SoFiles\64\' + ExtractFileName(FileList[x]));

                             CopyFile(PChar(FileList[x]), PChar(ProjDir + 'Libs\SoFiles\64\' + ExtractFileName(FileList[x])), False);

                             if not FoundInFile(GetCurrentProjectFileName, '<DeployFile LocalName="Libs\SoFiles\64\' + ExtractFileName(FileList[x]))
                             then
                               begin

                                  ProjFileLinesOut.Add('                <DeployFile LocalName="Libs\SoFiles\64\' + ExtractFileName(FileList[x]) + '" Configuration="Release" Class="File">');
                                  ProjFileLinesOut.Add('                    <Platform Name="Android64">');
                                  ProjFileLinesOut.Add('                        <RemoteDir>library\lib\arm64-v8a\</RemoteDir>');
                                  ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(FileList[x]) + '</RemoteName>');
                                  ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                                  ProjFileLinesOut.Add('                    </Platform>');
                                  ProjFileLinesOut.Add('                </DeployFile>');

                                  ProjFileLinesOut.Add('                <DeployFile LocalName="Libs\SoFiles\64\' + ExtractFileName(FileList[x]) + '" Configuration="Debug" Class="File">');
                                  ProjFileLinesOut.Add('                    <Platform Name="Android64">');
                                  ProjFileLinesOut.Add('                        <RemoteDir>library\lib\arm64-v8a\</RemoteDir>');
                                  ProjFileLinesOut.Add('                        <RemoteName>' + ExtractFileName(FileList[x]) + '</RemoteName>');
                                  ProjFileLinesOut.Add('                        <Overwrite>true</Overwrite>');
                                  ProjFileLinesOut.Add('                    </Platform>');
                                  ProjFileLinesOut.Add('                </DeployFile>');

                               end;

                          end;

                    end;

              end;

           Inc(i);

           while  i < ProjFileLinesIn.Count do
              begin

                 if (Pos('<DeployFile LocalName="MergedRes\', ProjFileLinesIn[i]) > 0) or
                    (Pos('<DeployFile LocalName="res\', ProjFileLinesIn[i]) > 0) or
                    (Pos('<DeployFile LocalName="Res\', ProjFileLinesIn[i]) > 0)
                 then
                    begin

                       while Pos('</DeployFile>', ProjFileLinesIn[i]) = 0 do
                          Inc(i);

                    end
                 else
                    ProjFileLinesOut.Add(ProjFileLinesIn[i]);

                 Inc(i);

              end;

           ProjFileLinesOut.SaveToFile(GetCurrentProjectFileName);

           TThread.Synchronize(TThread.CurrentThread,
           procedure
           begin

              OtherHandle := FindWindow('Shell_TrayWnd', nil);
              SetForegroundWindow(OtherHandle);
              IDEHandle := FindWindow('TAppBuilder', nil);
              SetForegroundWindow(IDEHandle);

           end);

           ProjFileLinesIn.DisposeOf;
           ProjFileLinesOut.DisposeOf;

           FileList := nil;
           FileList := TDirectory.GetFiles(LibsDir, '*.xml', TSearchOption.soAllDirectories);

           SetLength(FileList, Length(FileList) + 1);

           if GetCurrentProject.CurrentConfiguration = 'Debug'
           then
              FileList[High(FileList)] := ResDir + '\build\intermediates\merged_manifest\debug\out\AndroidManifest.xml'
           else
              FileList[High(FileList)] := ResDir + '\build\intermediates\merged_manifest\release\out\AndroidManifest.xml';

           ManifestLines := TStringList.Create;

           ASPB.Max := Length(FileList);
           ASPB.Position := 0;

           TThread.Synchronize(TThread.CurrentThread,
           procedure
           begin
              FManifest.MAndrMan.Text := '';;
           end);

           LStatus.Caption := 'Processing Manifest files.';

           for x := 0 to High(FileList) do
              begin

                 if AnsiLowerCase(ExtractFileName(FileList[x])) <> 'androidmanifest.xml'
                 then
                    begin

                       TThread.Synchronize(TThread.CurrentThread,
                       procedure
                       begin
                          ASPB.Position := x + 1;
                       end);

                       Continue;

                    end
                 else
                    TThread.Synchronize(TThread.CurrentThread,
                    procedure
                    begin
                       MStatus.Lines.Add('Extracting: ' + FileList[x]);
                       MStatus.Lines.Add('');
                       SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                    end);

                 ManifestLines.DisposeOf;
                 ManifestLines := TStringList.Create;
                 ManifestLines.LoadFromFile(FileList[x]);

                 i := 0;

                 while (i <= ManifestLines.Count - 1) and (Pos('<application', ManifestLines[i]) = 0) do
                    Inc(i);

                 if i = ManifestLines.Count - 1
                 then
                    Continue;

                 Inc(i);

                 while (i <= ManifestLines.Count - 1) and (Pos('</application', ManifestLines[i]) = 0) do
                    begin

                       if Pos('</manifest>', ManifestLines[i]) > 0
                       then
                          Break;

                       TThread.Synchronize(TThread.CurrentThread,
                       procedure
                       begin
                          FManifest.MAndrMan.Lines.Add(ManifestLines[i]);
                       end);

                       Inc(i);

                    end;

                 TThread.Synchronize(TThread.CurrentThread,
                 procedure
                 begin
                    ASPB.Position := x + 1;
                 end);

              end;

           ManifestLines.DisposeOf;

           if FManifest.MAndrMan.Lines.Count > 0
           then
              TThread.Synchronize(TThread.CurrentThread,
              procedure

              var
                 x: integer;

              begin

                 if FManifest.ShowModal = mrOK
                 then
                    begin

                       FileLines.DisposeOf;
                       FileLines := TStringList.Create;
                       FileLines.LoadFromFile(ProjDir + 'AndroidManifest.template.xml');

                       i := -1;

                       while i <= FManifest.MAndrMan.Lines.Count - 1 do
                          begin

                             Inc(i);

                             if Pos('<activity', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin

                                   Header := PosHeader('%receivers%');
                                   FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                   Inc(Header);

                                   if (Pos('/>', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                   then
                                      begin

                                         Inc(i);

                                         NestLevel := 1;

                                         while NestLevel > 0 do
                                            begin

                                               FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                               Inc(Header);

                                               if (Pos('<', FManifest.MAndrMan.Lines[i]) > 0) and
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                               then
                                                  Inc(NestLevel);

                                               if (Pos('/>', FManifest.MAndrMan.Lines[i]) > 0) or
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) > 0)
                                               then
                                                  Dec(NestLevel);

                                               if NestLevel > 0
                                               then
                                                  Inc(i);

                                            end;

                                         continue;

                                      end;

                                end;

                             if Pos('<service', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin

                                   Header := PosHeader('%activity%');
                                   FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                   Inc(Header);

                                   if (Pos('/>', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                   then
                                      begin

                                         Inc(i);

                                         NestLevel := 1;

                                         while NestLevel > 0 do
                                            begin

                                               FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                               Inc(Header);

                                               if (Pos('<', FManifest.MAndrMan.Lines[i]) > 0) and
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                               then
                                                  Inc(NestLevel);

                                               if (Pos('/>', FManifest.MAndrMan.Lines[i]) > 0) or
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) > 0)
                                               then
                                                  Dec(NestLevel);

                                               if NestLevel > 0
                                               then
                                                  Inc(i);

                                            end;

                                         continue;

                                      end;

                                end;

                             if Pos('<meta-data', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin

                                   Header := PosHeader('<%services%>');
                                   FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                   Inc(Header);

                                   if (Pos('/>', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                   then
                                      begin

                                         Inc(i);

                                         NestLevel := 1;

                                         while NestLevel > 0 do
                                            begin

                                               FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                               Inc(Header);

                                               if (Pos('<', FManifest.MAndrMan.Lines[i]) > 0) and
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                               then
                                                  Inc(NestLevel);

                                               if (Pos('/>', FManifest.MAndrMan.Lines[i]) > 0) or
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) > 0)
                                               then
                                                  Dec(NestLevel);

                                               if NestLevel > 0
                                               then
                                                  Inc(i);

                                            end;

                                         continue;

                                      end;

                                end;

                             if Pos('<provider', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin

                                   Header := PosHeader('</application>');
                                   FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                   Inc(Header);

                                   if (Pos('/>', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                   then
                                      begin

                                         Inc(i);

                                         NestLevel := 1;

                                         while NestLevel > 0 do
                                            begin

                                               FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                               Inc(Header);

                                               if (Pos('<', FManifest.MAndrMan.Lines[i]) > 0) and
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                               then
                                                  Inc(NestLevel);

                                               if (Pos('/>', FManifest.MAndrMan.Lines[i]) > 0) or
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) > 0)
                                               then
                                                  Dec(NestLevel);

                                               if NestLevel > 0
                                               then
                                                  Inc(i);

                                            end;

                                         continue;

                                      end;

                                end;

                             if Pos('<receiver', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin

                                   Header := PosHeader('</application>');
                                   FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                   Inc(Header);

                                   if (Pos('/>', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                   then
                                      begin

                                         Inc(i);

                                         NestLevel := 1;

                                         while NestLevel > 0 do
                                            begin

                                               FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                               Inc(Header);

                                               if (Pos('<', FManifest.MAndrMan.Lines[i]) > 0) and
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) = 0)
                                               then
                                                  Inc(NestLevel);

                                               if (Pos('/>', FManifest.MAndrMan.Lines[i]) > 0) or
                                                  (Pos('</', FManifest.MAndrMan.Lines[i]) > 0)
                                               then
                                                  Dec(NestLevel);

                                               if NestLevel > 0
                                               then
                                                  Inc(i);

                                            end;

                                         continue;

                                      end;

                                end;

                             if Pos('<uses-permission', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin
                                   Header := PosHeader('<application');
                                   FileLines.Insert(Header, FManifest.MAndrMan.Lines[i]);
                                   continue;
                                end;

                             if Pos('<!--', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin

                                   while Pos('-->', FManifest.MAndrMan.Lines[i]) = 0 do
                                      Inc(i);

                                   continue;

                                end;

                             if Pos('android:', FManifest.MAndrMan.Lines[i]) > 0
                             then
                                begin

                                   Found := False;

                                   x := PosHeader('<application');

                                   while Pos('>', FileLines[x]) = 0 do
                                      if Pos(Trim(FManifest.MAndrMan.Lines[i]), FileLines[x]) > 0
                                      then
                                         begin
                                            Found := True;
                                            Break;
                                         end
                                      else
                                         Inc(x);

                                   if Found
                                   then
                                      Continue;

                                   if (Pos('android:persistent', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:restoreAnyVersion', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:label', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:restoreAnyVersion', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:debuggable', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:largeHeap', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:icon', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:theme', FManifest.MAndrMan.Lines[i]) = 0) and
                                      (Pos('android:hardwareAccelerated', FManifest.MAndrMan.Lines[i]) = 0)
                                   then
                                      begin

                                         x := PosHeader('<application');

                                         while Pos('>', FileLines[x]) = 0 do
                                            Inc(x);

                                         FileLines[x] := StringReplace(FileLines[x], '>', '', []);
                                         FileLines.Insert(x + 1, StringReplace(FManifest.MAndrMan.Lines[i], '>', '', []) + '>');
                                         continue;

                                      end;

                                end;
                          end;

                       FileLines.SaveToFile(ProjDir + 'AndroidManifest.template.xml');

                    end;

              end);

            LStatus.Caption := 'Cleaning...';

         except

            on E: Exception do
               begin
                  ShowMessage(E.Message);
                  Exit;
               end;

         end;

      finally

         if TSKeepLibs.State = tssOff
         then
            begin

               DeleteDirectory(TmpDir, False);
               DeleteDirectory(LibsDir, False);

               if DirectoryExists(ResDir)
               then
                  DeleteDirectory(ResDir, False);

            end;

         if Errors
         then
            begin
               LStatus.Caption := 'Task completed. There were errors. Please see output. Backup of project file located in ' + SavedFile;
               LStatus.Font.Color := clRed;
            end
         else
            LStatus.Caption := 'Task completed succesfully. Backup of project file located in ' + SavedFile;

         NoClose := False;
         BClose.Enabled := True;
         BGo.Enabled := True;
         BAddRep.Enabled := True;
         BNewJob.Enabled := True;
         BSave.Enabled := True;
         BDelete.Enabled := True;
         BCompileAll.Enabled := True;
         BHistory.Enabled := True;
         SLJars.DisposeOf;
         SLAddJars.DisposeOf;
         CopyFiles.DisposeOf;
         FileLines.DisposeOf;

      end;

   end).Start;

end;

procedure TFGetJars.BDeleteClick(Sender: TObject);
begin

   if MessageDlg('Are you sure, you want to delete job ' + LEJobName.Text, mtConfirmation, [mbYes, mbNo], 0) = mrYes
   then
      begin

         QGetJobByName.Close;
         QGetJobByName.ParamByName('JobName').AsString := Trim(LEJobName.Text);
         QGetJobByName.Open;

         TJobs.FindKey([QGetJobByName.FieldByName('ID').AsInteger]);
         TJobs.Delete;

         CBProjJobs.Items.Text := '';

         TJobs.First;

         while not TJobs.Eof do
            begin
               CBProjJobs.Items.Add(TJobs.FieldByName('JobName').AsString);
               TJobs.Next;
            end;

         if CBProjJobs.Items.Count > 0
         then
            LoadJob(CBProjJobs.Items[CBProjJobs.Items.Count - 1]);

      end;

end;

procedure TFGetJars.BGoClick(Sender: TObject);
begin

   if not SaveJob
   then
      Exit;

   BClose.Enabled := False;
   BGo.Enabled := False;
   BAddRep.Enabled := False;
   BNewJob.Enabled := False;
   BSave.Enabled := False;
   BDelete.Enabled := False;
   BCompileAll.Enabled := False;
   BHistory.Enabled := False;
   NoClose := True;

   TThread.CreateAnonymousThread(
   procedure

   var
      x, i, y: Integer;
      FileList: TArray<String>;
      zipFile: TZipFile;
      ProjDir, LibsDir, TmpDir: String;
      ExcludeFile: Boolean;
      Modul: IOTAModule;
      TmpStr: String;
      Found: Boolean;

   begin

      try
         try

            if ConverterPath = ''
            then
               begin
                  ShowMessage('You need to set path to converter (Java2OP/JavaImport) in Settings menu');
                  Exit;
               end;

            MStatus.Lines.Text := '';
            LStatus.Font.Color := clGreen;

            TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
               LStatus.Caption := 'Building Gradle';
            end);

            ProjDir := ExtractFilePath(GetCurrentProjectFileName);
            LibsDir := ProjDir + 'GradLibs';
            TmpDir := ProjDir + 'GradTmp';

            if not DirectoryExists(ProjDir + 'Libs')
            then
               CreateDir(ProjDir + 'Libs');

            if DirectoryExists(LibsDir)
            then
               if not DeleteDirectory(LibsDir, False)
               then
                  begin
                     ShowMessage('There was an error deleting GradLibs Folder');
                     Exit;
                  end;

            if DirectoryExists(TmpDir)
            then
               if not DeleteDirectory(TmpDir, False)
               then
                  begin
                     ShowMessage('There was an error deleting GradTmp Folder');
                     Exit;
                  end;

            if not CreateDir(LibsDir)
            then
               begin
                  ShowMessage('There was an error creating GradLib Folder');
                  Exit;
               end;

            if not CreateDir(TmpDir)
            then
               begin
                  ShowMessage('There was an error creating GradTmp Folder');
                  Exit;
               end;

            try

               with BorlandIDEServices as IOTAModuleServices do
                  Modul := FindModule(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');

               try

                  if Assigned(Modul)
                  then
                     begin

                        Modul.Save(False, True);

                        if not Modul.CloseModule(True)
                        then
                           begin
                              ShowMessage('There was an error closing module ' + ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');
                              Exit;
                           end;

                     end;

               except

                  on E: Exception do
                     begin
                        ShowMessage(E.Message);
                        Exit;
                     end;

               end;

            except

               on E: Exception do
                  begin
                     ShowMessage(E.Message);
                     Exit;
                  end;

            end;

            if FileExists(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + 'Full.pas')
            then
               DeleteFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + 'Full.pas');

            FileLines := TStringList.Create;

            try

               FileLines.Add('repositories {');

              TRepositories.First;

              while not TRepositories.Eof do
                 begin
                    FileLines.Add('        ' + TRepositories.FieldByName('Link').AsString);
                    TRepositories.Next;
                 end;

               FileLines.Add('}');
               FileLines.Add('configurations {');
               FileLines.Add('');
               FileLines.Add('    myConfig');
               FileLines.Add('}');
               FileLines.Add('');
               FileLines.Add('dependencies {');

               for i := 0 to MJars.Lines.Count - 1 do
                  begin

                     if not RemoveComm(MJars.Lines[i], TmpStr)
                     then
                        Continue;

                     Found := False;

                     for y := 0 to FileLines.count - 1 do
                        if Pos(TmpStr, FileLines[y]) > 0
                        then
                           Found := True;

                     if Found
                     then
                        Continue;

                     FileLines.Add('    myConfig ' + TmpStr);

                  end;

               FileLines.Add('');
               FileLines.Add('}');
               FileLines.Add('');
               FileLines.Add('task getDeps(type: Copy) {');
               FileLines.Add('    duplicatesStrategy = ''include''');
               FileLines.Add('    from configurations.myConfig');
               FileLines.Add('    into ''' + StringReplace(LibsDir, '\', '/', [rfReplaceAll]) + '''');
               FileLines.Add('}');

               FileLines.SaveToFile(TmpDir + '\Build.gradle');

               FileLines.Clear;

               FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
               FileLines.Add('cd "' + TmpDir + '"');
               FileLines.Add('Gradle');
               FileLines.SaveToFile(TmpDir + '\Commands.bat');

               if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
               then
                  begin
                     ShowMessage('There was an error running Gradle on Build.gradle. Please check Output');
                     Exit;
                  end;

               TThread.Synchronize(TThread.CurrentThread,
               procedure
               begin
                  MStatus.Lines.Add('');
                  LStatus.Caption := 'Downloading libraries';
                  SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
               end);

               FileLines.DisposeOf;
               FileLines := TStringList.Create;
               FileLines.Clear;

               FileLines.Add(ExtractFileDrive(GetCurrentProjectFileName));
               FileLines.Add('cd "' + TmpDir + '"');
               FileLines.Add('Gradle -q getDeps');
               FileLines.SaveToFile(TmpDir + '\Commands.bat');

               if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
               then
                  begin
                     ShowMessage('There was an error running download task. Please check Output');
                     Exit;
                  end;

               TThread.Synchronize(TThread.CurrentThread,
               procedure
               begin
                  MStatus.Lines.Add('');
                  MStatus.Lines.Add('Libraries downloaded');
                  MStatus.Lines.Add('');
                  LStatus.Caption := 'Copying Additional Dependencies';
                  SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
               end);

               ASPB.Max := MAddJars.Lines.Count;
               ASPB.Position := 0;

               for i := 0 to MAddJars.Lines.Count - 1 do
                  begin

                     if not RemoveComm(MAddJars.Lines[i], TmpStr)
                     then
                        Continue;

                     if not FileExists(TmpStr)
                     then
                        begin
                           ShowMessage('File ' + TmpStr + ' not found');
                           Exit;
                        end;

                     TThread.Synchronize(TThread.CurrentThread,
                     procedure
                     begin
                        MStatus.Lines.Add('Copying: ' + TmpStr);
                        MStatus.Lines.Add('');
                        SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                     end);

                     if not CopyFile(PChar(TmpStr), PChar(LibsDir + '\' + EXtractFileName(TmpStr)), False)
                     then
                        TThread.Synchronize(TThread.CurrentThread,
                        procedure
                        begin
                           MStatus.Lines.Add('Error copying: ' + MAddJars.Lines[i]);
                           SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                           Exit;
                        end);

                     TThread.Synchronize(TThread.CurrentThread,
                     procedure
                     begin
                        ASPB.Position := i + 1;
                     end);

                  end;

               FileList := TDirectory.GetFiles(LibsDir, '*.aar', TSearchOption.soTopDirectoryOnly);

               ASPB.Max := Length(FileList);

               LStatus.Caption := 'Extracting libraries';

               zipFile := TZipFile.Create;

               for x := 0 to High(FileList) do
                  if zipFile.IsValid(FileList[x])
                  then
                     begin

                        TThread.Synchronize(TThread.CurrentThread,
                        procedure
                        begin
                           MStatus.Lines.Add('Extracting: ' + FileList[x]);
                           MStatus.Lines.Add('');
                           SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                        end);

                        try
                           zipFile.Open(FileList[x], zmRead);
                           zipFile.ExtractAll(LibsDir + '\' + StrBefore(ExtractFileExt(FileList[x]), ExtractFileName(FileList[x])));
                        except

                           on E: Exception do
                              begin
                                 ShowMessage(E.Message);
                                 Exit;
                              end;

                        end;

                        TThread.Synchronize(TThread.CurrentThread,
                        procedure
                        begin
                           ASPB.Position := x + 1;
                        end);

                     end;

               FileList := nil;
               FileList := TDirectory.GetFiles(LibsDir, '*.jar', TSearchOption.soAllDirectories);

               ASPB.Max := Length(FileList);

               for x := 0 to High(FileList) do
                  begin

                     ExcludeFile := False;

                     for i := 0 to MExclJars.Lines.Count - 1 do
                        begin

                           if not RemoveComm(MExclJars.Lines[i], TmpStr)
                           then
                              Continue;

                           if (TmpStr[1] <> '/') and
                              (TmpStr[1] <> '¤')
                           then
                              if Pos(AnsiLowerCase(TmpStr), AnsiLowerCase(FileList[x])) > 0
                              then
                                 begin
                                    ExcludeFile := True;
                                    Break;
                                 end;

                        end;

                     if ExcludeFile
                     then
                        Continue;

                     TThread.Synchronize(TThread.CurrentThread,
                     procedure
                     begin
                        MStatus.Lines.Add('Extracting: ' + FileList[x]);
                        MStatus.Lines.Add('');
                        SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
                     end);

                     if zipFile.IsValid(FileList[x])
                     then
                        begin

                           try
                              zipFile.Open(FileList[x], zmRead);
                              zipFile.ExtractAll(LibsDir + '\ExtractedClasses');
                           except

                              on E: Exception do
                                 begin
                                    ShowMessage(E.Message);
                                    Exit;
                                 end;

                           end;

                        end;

                     TThread.Synchronize(TThread.CurrentThread,
                     procedure
                     begin
                        ASPB.Position := x + 1;
                     end);

                  end;

               zipFile.Close;

               TThread.Synchronize(TThread.CurrentThread,
               procedure
               begin
                  MStatus.Lines.Add('Classes Extracted');
                  MStatus.Lines.Add('');
                  SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
               end);

               if FileExists(LibsDir + '\ExtractedClasses\module-info.class')
               then
                  DeleteFile(LibsDir + '\ExtractedClasses\module-info.class');

               if DirectoryExists(LibsDir + '\ExtractedClasses\META-INF')
               then
                  DeleteDirectory(LibsDir + '\ExtractedClasses\META-INF', False);

               FileList := nil;
               FileList := TDirectory.GetFiles(LibsDir + '\ExtractedClasses', '*.*', TSearchOption.soTopDirectoryOnly);

               for i := 0 to High(FileList) do
                  DeleteFile(FileList[i]);

               FileLines.DisposeOf;
               FileLines := TStringList.Create;

               for i := 0 to MExclJars.Lines.Count - 1 do
                  begin

                     if not RemoveComm(MExclJars.Lines[i], TmpStr)
                     then
                        Continue;

                     if TmpStr[1] = '/'
                     then
                        DeleteDirectory(LibsDir + '\ExtractedClasses\' + StrAfter('/',  TmpStr), False);

                  end;

               for i := 0 to MExclJars.Lines.Count - 1 do
                  begin

                     if not RemoveComm(MExclJars.Lines[i], TmpStr)
                     then
                        Continue;

                     if TmpStr[1] = '¤'
                     then
                        DeleteFile(LibsDir + '\ExtractedClasses\' + StrAfter('¤',  TmpStr));

                  end;

               LStatus.Caption := 'Creating ' + LEJobName.Text + '.jar';

               FileLines.Add(ExtractFileDrive(LibsDir));
               FileLines.Add('cd "' + LibsDir + '\ExtractedClasses"');
               FileLines.Add('jar -cf ' + 'AndroidApi.JNI.' + LEJobName.Text + '.jar *');
               FileLines.SaveToFile(TmpDir + '\Commands.bat');

               if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
               then
                  begin
                     ShowMessage('There was an error creating' + LEJobName.Text + '.jar. Please check Output');
                     Exit;
                  end;

               TThread.Synchronize(TThread.CurrentThread,
               procedure
               begin
                  MStatus.Lines.Add(LEJobName.Text + 'AndroidApi.JNI.' +  LEJobName.Text + '.jar Created');
                  MStatus.Lines.Add('');
                  LStatus.Caption := 'Creating unit AndroidApi.JNI.' + LEJobName.Text + '.pas';
                  SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
               end);

               DeleteFile(ConverterPath + '\AndroidApi.JNI.' + LEJobName.Text + '.jar');
               MoveFile(PChar(LibsDir + '\ExtractedClasses\AndroidApi.JNI.' + LEJobName.Text + '.jar'), PChar(ConverterPath + '\AndroidApi.JNI.' + LEJobName.Text + '.jar'));

               FileLines.DisposeOf;
               FileLines := TStringList.Create;

               FileLines.Add(ExtractFileDrive(ConverterPath));
               FileLines.Add('cd "' + ConverterPath + '"');

               if UseJava2OP
               then
                  FileLines.Add('Java2OP -jar AndroidApi.JNI.' + LEJobName.Text + '.jar -unit AndroidApi.JNI.' + LEJobName.Text)
               else
                  FileLines.Add('JavaImport AndroidApi.JNI.' + LEJobName.Text + '.jar');

               FileLines.SaveToFile(TmpDir + '\Commands.bat');

               if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
               then
                  begin
                     ShowMessage('There was an error creating JNI file. Please check output');
                     Exit;
                  end;

               TThread.Synchronize(TThread.CurrentThread,
               procedure
               begin
                  MStatus.Lines.Add('unit AndroidApi.JNI.' + LEJobName.Text + '.pas Created');
                  MStatus.Lines.Add('');
                  SendMessage(MStatus.Handle, WM_VSCROLL, SB_BOTTOM, 0);
               end);

               DeleteFile(ConverterPath + '\\AndroidApi.JNI.' + LEJobName.Text + '.jar');
               DeleteFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');
               MoveFile(PChar(ConverterPath + '\AndroidApi.JNI.' + LEJobName.Text + '.pas'), PChar(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas'));

               FileLines.DisposeOf;
               FileLines := TStringList.Create;
               FileLines.LoadFromFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');

               for i := 0 to FileLines.Count - 1 do
                  begin

                     FileLines[i] := StringReplace(FileLines[i], 'procedure implementation(', '//procedure implementation(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'function implementation(', '//function implementation(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'procedure initialization(', '//procedure initialization(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'function initialization(', '//function initialization(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'procedure finalization(', '//procedure initialization(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'function finalization(', '//function initialization(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'function SHR(', '//function SHR(', [rfReplaceAll, rfIgnoreCase]);                  FileLines[i] := StringReplace(FileLines[i], 'function SHR(', '//function SHR(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'function SHL(', '//function SHL(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'procedure SHR(', '//procedure SHR(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'procedure SHL(', '//procedure SHL(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'function INLINE(', '//function INLINE(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'procedure INLINE(', '//procedure INLINE(', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], 'function _Getthis$', '//function _Getthis$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'property this$', '//property this$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'function _Get.', '//function _Get.', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'procedure _Set.', '//procedure _Set.', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'property .', '//property .', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'function _Getval$', '//function _Getval$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'property val$', '//property val$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'property $', '//property $', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'function _Get$', '//function _Get$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'function then(', '//function then(', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'property class$', '//property class$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'procedure _Setclass$', '//procedure _Setclass$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'function _Getclass$', '//function _Getclass$', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], 'property library', '//property library', [rfReplaceAll, rfIgnoreCase]);
                     FileLines[i] := StringReplace(FileLines[i], '//function getResult: J; cdecl; overload;', 'function getResult: JObject; cdecl; overload;', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], '//function getResult: J; cdecl; overload;', 'function getResult: JObject; cdecl; overload;', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], '//function getResult(P1: Jlang_Class): J; cdecl; overload;', 'function getResult(P1: Jlang_Class): JObject; cdecl; overload;', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], '//procedure onSuccess(P1: J); cdecl;', 'procedure onSuccess(P1: JObject); cdecl;', [rfReplaceAll]);
                     FileLines[i] := StringReplace(FileLines[i], '//Deprecated', '', [rfReplaceAll]);

                     if Pos('(.', FileLines[i]) > 0
                     then
                        FileLines[i] := '//' + FileLines[i];

                     if Pos(': JOffsetDateTime', FileLines[i]) > 0
                     then
                        FileLines[i] := StringReplace(FileLines[i], '//', '', []);

                     if ((Pos(': J;', FileLines[i]) > 0) or
                         (Pos(': J)', FileLines[i]) > 0))
                     then
                        begin
                           FileLines[i] := StringReplace(FileLines[i], ': J;', ': JObject;', [rfReplaceAll]);
                           FileLines[i] := StringReplace(FileLines[i], ': J)', ': JObject)', [rfReplaceAll]);
                           FileLines[i] := StringReplace(FileLines[i], '//', '', []);
                        end;

                     if (Pos('(1: J', FileLines[i]) > 0) or
                        (Pos('(2: J', FileLines[i]) > 0) or
                        (Pos('(3: J', FileLines[i]) > 0) or
                        (Pos('(4: J', FileLines[i]) > 0) or
                        (Pos('(5: J', FileLines[i]) > 0) or
                        (Pos('(6: J', FileLines[i]) > 0) or
                        (Pos('(7: J', FileLines[i]) > 0) or
                        (Pos('(8: J', FileLines[i]) > 0) or
                        (Pos('(9: J', FileLines[i]) > 0) or
                        (Pos('(0: J', FileLines[i]) > 0) or
                        (Pos(' 1: J', FileLines[i]) > 0) or
                        (Pos(' 2: J', FileLines[i]) > 0) or
                        (Pos(' 3: J', FileLines[i]) > 0) or
                        (Pos(' 4: J', FileLines[i]) > 0) or
                        (Pos(' 5: J', FileLines[i]) > 0) or
                        (Pos(' 6: J', FileLines[i]) > 0) or
                        (Pos(' 7: J', FileLines[i]) > 0) or
                        (Pos(' 8: J', FileLines[i]) > 0) or
                        (Pos(' 9: J', FileLines[i]) > 0) or
                        (Pos(' 0: J', FileLines[i]) > 0) or
                        (Pos(' 0: J', FileLines[i]) > 0) or
                        (Pos('(init: ', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' inline:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' inline;', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos('(inline:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' inline(', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' inherited:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' inherited;', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' inherited(', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos('(inherited:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' shr:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' shr;', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' shr(', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos('(shr:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' shl:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' shl;', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' shl(', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos('(shl:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' implementation:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' implementation;', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' initialzation:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' initialzation;', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' finalization:', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos(' finalization;', AnsiLowerCase(FileLines[i])) > 0) or
                        (Pos('procedure -', FileLines[i]) > 0) or
                        (Pos('function -', FileLines[i]) > 0)
                     then
                        FileLines[i] := '//' + FileLines[i];

                  end;

               FileLines.SaveToFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');

               DeleteDirectory(TmpDir, False);

               if TSKeepLibs.State = tssOff
               then
                  DeleteDirectory(LibsDir, False);

            finally
               FileLines.DisposeOf;
            end;

         finally

            LStatus.Caption := 'Task completed successfully.';

            NoClose := False;
            BClose.Enabled := True;
            BGo.Enabled := True;
            BAddRep.Enabled := True;
            BNewJob.Enabled := True;
            BSave.Enabled := True;
            BDelete.Enabled := True;
            BCompileAll.Enabled := True;
            BHistory.Enabled := True;

         end;

      except

         on E: Exception do
            begin
               ShowMessage(E.Message);
               Exit;
            end;

      end;

   end).Start;

end;

procedure TFGetJars.BHistoryClick(Sender: TObject);
begin
   FHistory.Show;
end;

end.
