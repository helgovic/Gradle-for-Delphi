unit UFGetJars;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AdvSmoothProgressBar, AdvSmoothButton,
  Vcl.StdCtrls, ToolsAPI, Threading, Vcl.ExtCtrls,
  System.Zip, System.IOUtils, JclFileUtils,
  Vcl.ComCtrls, Vcl.WinXCtrls;

type
  TFGetJars = class(TForm)
    Label1: TLabel;
    MExclFinal: TMemo;
    MJars: TMemo;
    MAddJars: TMemo;
    Label2: TLabel;
    LEJobName: TLabeledEdit;
    Label3: TLabel;
    LEJ2OLoc: TLabeledEdit;
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
    Label6: TLabel;
    procedure BGoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CBProjJobsSelect(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure BNewJobClick(Sender: TObject);
    procedure BAddRepClick(Sender: TObject);
    procedure BDeleteClick(Sender: TObject);
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

implementation

uses
   JclSysUtils, Registry, UFAndroidManifest, JclStrings, IniFiles, UFRepositories;

{$R *.dfm}

var
   FileLines: TStringList;

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
   Result := '''' + Result + '''';
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
      SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
   end);

end;

function TFGetJars.SaveJob: Boolean;

var
   i: integer;

begin

   if Trim(LEJ2OLoc.Text) = ''
   then
      begin
         ShowMessage('Please enter location of Java2OP.exe');
         LEJ2OLoc.SetFocus;
         Exit(False);
      end;

   if not FileExists(Trim(LEJ2OLoc.Text) + '\Java2Op.exe')
   then
      begin
         ShowMessage('Java2OP.exe not found at ' + Trim(LEJ2OLoc.Text));
         LEJ2OLoc.SetFocus;
         Exit(False);
      end;

   with TRegIniFile.Create(REG_KEY) do
   try
      WriteString(REG_BUILD_OPTIONS, 'Java2op Location', LEJ2OLoc.Text);
   finally
      Free;
   end;

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

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      try
         if ReadString(LEJobName.Text, 'Repositories', '') = ''
         then
            WriteString(LEJobName.Text, 'Repositories', 'mavenCentral()¤google()¤jcenter()');
         WriteString(LEJobName.Text, 'Dependensies', MemoStrToIniStr(MJars.Lines.Text));
         WriteString(LEJobName.Text, 'AddDependensies', MemoStrToIniStr(MAddJars.Lines.Text));
         WriteString(LEJobName.Text, 'Excludes', MemoStrToIniStr(MExclJars.Lines.Text));
         WriteString(LEJobName.Text, 'FinalExcludes', MemoStrToIniStr(MExclFinal.Lines.Text));
         if Pos(LEJobName.Text, CBProjJobs.Items.Text) = 0
         then
            CBProjJobs.Items.Add(LEJobName.Text);
         WriteString('Project', 'Jobs', MemoStrToIniStr(CBProjJobs.Items.Text));
         UpdateFile;
      finally
         Free;
      end;
   Result := True;

end;

procedure TFGetJars.LoadJob(JobNam: String);
begin

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      try
         LEJobName.Text := JobNam;
         MJars.Lines.Text := IniStrToMemoStr(ReadString(LEJobName.Text, 'Dependensies', ''));
         MAddJars.Lines.Text := IniStrToMemoStr(ReadString(LEJobName.Text, 'AddDependensies', ''));
         MExclJars.Lines.Text := IniStrToMemoStr(ReadString(LEJobName.Text, 'Excludes', ''));
         MExclFinal.Lines.Text := IniStrToMemoStr(ReadString(LEJobName.Text, 'FinalExcludes', ''));
         CBProjJobs.Text := JobNam;
      finally
         Free;
      end;

end;

procedure TFGetJars.FormShow(Sender: TObject);
begin

   MStatus.Text := '';
   MJars.Text := '';
   MAddJars.Text := '';
   MExclJars.Text := '';
   LEJobName.Text := '';
   MJars.SetFocus;
   ASPB.Position := 0;

   with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
      try
         CBProjJobs.Items.Text := IniStrToMemoStr(ReadString('Project', 'Jobs', ''));

         if CBProjJobs.Items.Count > 0
         then
            LoadJob(CBProjJobs.Items[CBProjJobs.Items.Count - 1]);

      finally
         Free;
      end;
   with TRegIniFile.Create(REG_KEY) do
   try
      LEJ2OLoc.Text := ReadString(REG_BUILD_OPTIONS, 'Java2op Location', '');
   finally
      Free;
   end;

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
   RepStr: string;

begin

   if FRepositories.ShowModal = mrOk
   then
      begin

         RepStr := '';
         for i := 0 to FRepositories.CLBRepositories.Count - 1 do
            if FRepositories.CLBRepositories.Checked[i]
            then
               if RepStr = ''
               then
                  RepStr := FRepositories.CLBRepositories.Items[i]
               else
                  RepStr := RepStr + '¤' + FRepositories.CLBRepositories.Items[i];

         with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
            try
               WriteString(LEJobName.Text, 'Repositories', RepStr);
            finally
               Free;
            end;

      end;

end;

procedure TFGetJars.BDeleteClick(Sender: TObject);
begin

   if MessageDlg('Are you sure, you want to delete job ' + LEJobName.Text, mtConfirmation, [mbYes, mbNo], 0) = mrYes
   then
      with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
         try
            DeleteKey(LEJobName.Text, 'Repositories');
            DeleteKey(LEJobName.Text, 'Dependensies');
            DeleteKey(LEJobName.Text, 'AddDependensies');
            DeleteKey(LEJobName.Text, 'Excludes');
            CBProjJobs.Items.Delete(CBProjJobs.Items.IndexOf(LEJobName.Text));
            CBProjJobs.ItemIndex := CBProjJobs.Items.Count - 1;
            CBProjJobsSelect(CBProjJobs);

            WriteString('Project', 'Jobs', MemoStrToIniStr(CBProjJobs.Items.Text));
            UpdateFile;
         finally
            Free;
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

   TThread.CreateAnonymousThread(
   procedure

   var
      x, i: Integer;
      FileList: TArray<String>;
      zipFile: TZipFile;
      ManifestLines, Repos: TStringList;
      ProjDir, LibsDir, TmpDir: String;
      ExcludeFile: Boolean;
      Modul: IOTAModule;
      NestLevel: integer;
      Header: integer;
      Found: Boolean;

   begin

      try

         TThread.Synchronize(TThread.CurrentThread,
         procedure
         begin
            MStatus.Text := 'Building Gradle';
            MStatus.Lines.Add('');
         end);

         ProjDir := ExtractFilePath(GetCurrentProjectFileName);
         LibsDir := ProjDir + 'GradLibs';
         TmpDir := ProjDir + 'GradTmp';

         DeleteDirectory(LibsDir, False);
         DeleteDirectory(TmpDir, False);
         CreateDir(LibsDir);
         CreateDir(TmpDir);

         with BorlandIDEServices as IOTAModuleServices do
            Modul := FindModule(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');
         try

            if Assigned(Modul)
            then
               Modul.CloseModule(True);

         except
            ShowException(ExceptObject, ExceptAddr);
         end;

         if FileExists(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + 'Full.pas')
         then
            DeleteFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + 'Full.pas');

         FileLines := TStringList.Create;

         try

            Repos := TStringList.Create;
            Repos.Delimiter := '¤';
            Repos.StrictDelimiter := True;

            with TIniFile.Create(StrBefore('.dproj', GetCurrentProjectFileName) + '.ini') do
               try
                  Repos.DelimitedText := ReadString(LEJobName.Text, 'Repositories', '');
               finally
                  Free;
               end;
            FileLines.Add('repositories {');

            for i := 0 to Repos.Count - 1 do
               FileLines.Add('        ' + Repos[i]);

            Repos.Free;

            FileLines.Add('}');
            FileLines.Add('configurations {');
            FileLines.Add('');
            FileLines.Add('    myConfig');
            FileLines.Add('}');
            FileLines.Add('');
            FileLines.Add('dependencies {');

            for i := 0 to MJars.Lines.Count - 1 do
               FileLines.Add('    myConfig ' + MJars.Lines[i]);

            FileLines.Add('');
            FileLines.Add('}');
            FileLines.Add('');
            FileLines.Add('task getDeps(type: Copy) {');
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
               MStatus.Lines.Add('Running Task GetDeps');
               MStatus.Lines.Add('');
            end);

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
               MStatus.Lines.Add('Copying Additional dependensies');
               MStatus.Lines.Add('');
            end);

            ASPB.Max := MAddJars.Lines.Count;
            ASPB.Position := 0;

            for i := 0 to MAddJars.Lines.Count - 1 do
               begin

                  TThread.Synchronize(TThread.CurrentThread,
                  procedure
                  begin
                     MStatus.Lines.Add('Copying: ' + MAddJars.Lines[i]);
                     MStatus.Lines.Add('');
                     SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
                  end);

                  if not CopyFile(PChar(MAddJars.Lines[i]), PChar(LibsDir + '\' + EXtractFileName(MAddJars.Lines[i])), False)
                  then
                     TThread.Synchronize(TThread.CurrentThread,
                     procedure
                     begin
                        MStatus.Lines.Add('Error copying: ' + MAddJars.Lines[i]);
                        SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
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
                        SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
                     end);

                     zipFile.Open(FileList[x], zmRead);
                     zipFile.ExtractAll(LibsDir + '\' + StrBefore(ExtractFileExt(FileList[x]), ExtractFileName(FileList[x])));

                     TThread.Synchronize(TThread.CurrentThread,
                     procedure
                     begin
                        ASPB.Position := x + 1;
                     end);

                  end;

            FileList := TDirectory.GetFiles(LibsDir, '*.jar', TSearchOption.soAllDirectories);

            ASPB.Max := Length(FileList);

            for x := 0 to High(FileList) do
               begin

                  ExcludeFile := False;

                  for i := 0 to MExclJars.Lines.Count - 1 do
                     if Pos(AnsiLowerCase(MExclJars.Lines[i]), AnsiLowerCase(FileList[x])) > 0
                     then
                        begin
                           ExcludeFile := True;
                           Break;
                        end;

                  if ExcludeFile
                  then
                     Continue;

                  TThread.Synchronize(TThread.CurrentThread,
                  procedure
                  begin
                     MStatus.Lines.Add('Extracting: ' + FileList[x]);
                     MStatus.Lines.Add('');
                     SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
                  end);

                  if zipFile.IsValid(FileList[x])
                  then
                     begin

                        zipFile.Open(FileList[x], zmRead);
                        zipFile.ExtractAll(LibsDir + '\ExtractedClasses');

                     end;

                  TThread.Synchronize(TThread.CurrentThread,
                  procedure
                  begin
                     ASPB.Position := x + 1;
                  end);

               end;

            TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
               MStatus.Lines.Add('Classes Extracted');
               MStatus.Lines.Add('');
               MStatus.Lines.Add('Creating ' + LEJobName.Text + '.jar');
               MStatus.Lines.Add('');
               SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
            end);

            if FileExists(LibsDir + '\ExtractedClasses\module-info.class')
            then
               DeleteFile(LibsDir + '\ExtractedClasses\module-info.class');

            if DirectoryExists(LibsDir + '\ExtractedClasses\META-INF')
            then
               DeleteDirectory(LibsDir + '\ExtractedClasses\META-INF', False);

            FileList := TDirectory.GetFiles(LibsDir + '\ExtractedClasses', '*.*', TSearchOption.soTopDirectoryOnly);

            for i := 0 to High(FileList) do
               DeleteFile(FileList[i]);

            FileLines.Clear;

            FileLines.Add(ExtractFileDrive(LibsDir));
            FileLines.Add('cd "' + LibsDir + '\ExtractedClasses"');
            FileLines.Add('jar -cf ' + LEJobName.Text + '.jar *');
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
               MStatus.Lines.Add(LEJobName.Text + '.jar Created');
               MStatus.Lines.Add('');
               MStatus.Lines.Add('Creating unit AndroidApi.JNI.' + LEJobName.Text + '.pas');
               MStatus.Lines.Add('');
               SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
            end);

            DeleteFile(LEJ2OLoc.Text + '\' + LEJobName.Text + '.jar');
            MoveFile(PChar(LibsDir + '\ExtractedClasses\' + LEJobName.Text + '.jar'), PChar(LEJ2OLoc.Text + '\' + LEJobName.Text + '.jar'));

            FileLines.Clear;

            FileLines.Add(ExtractFileDrive(LEJ2OLoc.Text));
            FileLines.Add('cd "' + LEJ2OLoc.Text + '"');
            FileLines.Add('Java2OP -jar ' + LEJobName.Text + '.jar -unit AndroidApi.JNI.' + LEJobName.Text);
            FileLines.SaveToFile(TmpDir + '\Commands.bat');

            if Execute(TmpDir + '\Commands.bat', ExecOut) <> 0
            then
               begin
                  ShowMessage('There was an error running Java2OP on ' + LEJobName.Text + '.jar. Please check Output');
                  Exit;
               end;

            TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
               MStatus.Lines.Add('unit AndroidApi.JNI.' + LEJobName.Text + '.pas Created');
               MStatus.Lines.Add('');
               SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
            end);

            DeleteFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');
            MoveFile(PChar(LEJ2OLoc.Text + '\AndroidApi.JNI.' + LEJobName.Text + '.pas'), PChar(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas'));

            FileLines.LoadFromFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');

            for i := 0 to FileLines.Count - 1 do
               begin

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
                     (Pos('procedure -', FileLines[i]) > 0) or
                     (Pos('function -', FileLines[i]) > 0)
                  then
                     FileLines[i] := '//' + FileLines[i];

               end;

            FileLines.SaveToFile(ProjDir + 'AndroidApi.JNI.' + LEJobName.Text + '.pas');

            if not DirectoryExists(ProjDir + 'Libs')
            then
               CreateDir(ProjDir + 'Libs');

            DeleteDirectory(LibsDir + '\ExtractedClasses', False);

            FileList := TDirectory.GetFiles(LibsDir, '*.jar', TSearchOption.soAllDirectories);

            ASPB.Max := Length(FileList);

            for x := 0 to High(FileList) do
               begin

                  ExcludeFile := False;

                  for i := 0 to MExclFinal.Lines.Count - 1 do
                     if Pos(AnsiLowerCase(MExclFinal.Lines[i]), AnsiLowerCase(FileList[x])) > 0
                     then
                        begin
                           ExcludeFile := True;
                           Break;
                        end;

                  if ExcludeFile
                  then
                     Continue;

                  TThread.Synchronize(TThread.CurrentThread,
                  procedure
                  begin
                     MStatus.Lines.Add('Extracting: ' + FileList[x]);
                     MStatus.Lines.Add('');
                     SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
                  end);

                  if zipFile.IsValid(FileList[x])
                  then
                     begin

                        zipFile.Open(FileList[x], zmRead);
                        zipFile.ExtractAll(LibsDir + '\ExtractedClasses');

                     end;

                  TThread.Synchronize(TThread.CurrentThread,
                  procedure
                  begin
                     ASPB.Position := x + 1;
                  end);

               end;

            zipFile.Free;

            TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
               MStatus.Lines.Add('Classes Extracted');
               MStatus.Lines.Add('');
               MStatus.Lines.Add('Creating ' + LEJobName.Text + '.jar');
               MStatus.Lines.Add('');
               SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
            end);

            if FileExists(LibsDir + '\ExtractedClasses\module-info.class')
            then
               DeleteFile(LibsDir + '\ExtractedClasses\module-info.class');

            if DirectoryExists(LibsDir + '\ExtractedClasses\META-INF')
            then
               DeleteDirectory(LibsDir + '\ExtractedClasses\META-INF', False);

            FileList := TDirectory.GetFiles(LibsDir + '\ExtractedClasses', '*.*', TSearchOption.soTopDirectoryOnly);

            for i := 0 to High(FileList) do
               DeleteFile(FileList[i]);

            FileLines.Clear;

            FileLines.Add(ExtractFileDrive(LibsDir));
            FileLines.Add('cd "' + LibsDir + '\ExtractedClasses"');
            FileLines.Add('jar -cf ' + LEJobName.Text + '.jar *');
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
               MStatus.Lines.Add(LEJobName.Text + '.jar Created');
               MStatus.Lines.Add('');
               SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
            end);

            DeleteFile(ProjDir + 'Libs\' + LEJobName.Text + '.jar');
            MoveFile(PChar(LibsDir + '\ExtractedClasses\' + LEJobName.Text + '.jar'), PChar(ProjDir + 'Libs\' + LEJobName.Text + '.jar'));

            FileList := TDirectory.GetFiles(LibsDir, '*.xml', TSearchOption.soAllDirectories);

            ManifestLines := TStringList.Create;

            ASPB.Max := Length(FileList);
            ASPB.Position := 0;

            TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
               FManifest.MAndrMan.Text := '';;
            end);

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
                        SendMessage(MStatus.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
                     end);

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

            ManifestLines.Free;

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

           if not FoundInFile(GetCurrentProjectFileName, '<JavaReference Include="Libs\' + LEJobName.Text + '.jar">')
           then
              begin

                 FileLines.LoadFromFile(GetCurrentProjectFileName);

                 i := 0;

                 while  (i < Filelines.Count) and (Pos('<BuildConfiguration Include="Release">', FileLines[i]) = 0) do
                    Inc(i);

                 FileLines.Insert(i, '<JavaReference Include="Libs\' + LEJobName.Text + '.jar">');
                 Inc(i);
                 FileLines.Insert(i, '<ContainerId>ClassesdexFile64</ContainerId>');
                 Inc(i);
                 FileLines.Insert(i, ' <Disabled/>');
                 Inc(i);
                 FileLines.Insert(i, '</JavaReference>');

                 FileLines.SaveToFile(GetCurrentProjectFileName);

                 with BorlandIDEServices as IOTAModuleServices do
                    FindModule(GetCurrentProjectFileName).Refresh(True);

              end;

            DeleteDirectory(TmpDir, False);

            if TSKeepLibs.State = tssOff
            then
               DeleteDirectory(LibsDir, False);

         finally
            FileLines.Free;
         end;

      finally

         BClose.Enabled := True;
         BGo.Enabled := True;
         BAddRep.Enabled := True;
         BNewJob.Enabled := True;
         BSave.Enabled := True;
         BDelete.Enabled := True;

      end;

   end).Start;

end;

end.
