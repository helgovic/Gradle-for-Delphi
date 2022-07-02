unit UGetJars;

interface

uses
  Windows, SysUtils, Classes, vcl.Menus, vcl.ActnList, ToolsAPI, vcl.ComCtrls, vcl.ExtCtrls, vcl.Graphics, vcl.Controls,
  System.IOUtils, vcl.Dialogs, Threading, System.Win.Registry, Vcl.Forms;

type

  TBADIToolsAPIFunctions = record
     Class Procedure RegisterFormClassForTheming(Const AFormClass : TCustomFormClass;
        Const Component : TComponent = Nil); static;
  end;

  TGetJarsExpert = class(TObject)
  private
    { Private declarations }
    FProjectMenu,
    FMenuGetJars: TMenuItem;
    FActionGetJars: TAction;
    procedure GetJarsExecute(Sender: TObject);
  protected
    { Protected declarations }
    function AddAction(ACaption, AHint, AName : String; AExecuteEvent,
      AUpdateEvent : TNotifyEvent) : TAction;
    procedure RemoveAction(AAction: TAction; AToolbar: TToolbar);
    procedure RemoveActionFromToolbar(AAction: TAction);
  public
    { Public declarations }
    constructor Create; virtual;
    destructor Destroy; override;
    class function Instance: TGetJarsExpert;
  public
  end;

//  TIDENotifier = class(TInterfacedObject, IOTAIDENotifier)
//  protected
//    procedure FileNotification(NotifyCode: TOTAFileNotification;
//      const FileName: string; var Cancel: Boolean);
//    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
//    procedure AfterCompile(Succeeded: Boolean); overload;
//    procedure AfterSave;
//    procedure BeforeSave;
//    procedure Destroyed;
//    procedure Modified;
//  end;

  function GetJarsExpert: TGetJarsExpert;

implementation

uses
   JclStrings, UFGetJars, UFAndroidManifest, UFRepositories, UAddRep, UFHistory;

var
   FGetJarsExpert: TGetJarsExpert;
//   IDENot: Integer;

function FindMenuItem(MenuCaptions: String): TMenuItem;

var
   Captions: TStringList;
   NTAServices: INTAServices;
   y, i: integer;
   MenuItems: TMenuItem;
   Caption: String;
   Found: Boolean;

begin

   Result := nil;

   if Supports(BorlandIDEServices, INTAServices, NTAServices)
   then
      begin

         Captions := TStringList.Create;
         Captions.Delimiter := ';';
         Captions.StrictDelimiter := True;
         Captions.DelimitedText := MenuCaptions;

         MenuItems := NTAServices.MainMenu.Items;

         for y := 0 to Captions.Count - 1 do
            begin

               Found := False;

               for i := 0 to MenuItems.Count - 1 do
                  begin

                     Caption := StringReplace(MenuItems.Items[i].Caption, '&', '', []);

                     if Uppercase(Caption) = Uppercase(Captions[y])
                     then
                        begin
                           MenuItems := MenuItems.Items[i];
                           Found := True;
                           Break;
                        end;

                  end;

               if not Found
               then
                  begin
                     Captions.DisposeOf;
                     Exit;
                  end;

            end;

         Result := MenuItems;
         Captions.DisposeOf;

      end;

end;

function GetJarsExpert: TGetJarsExpert;
begin
  Result := TGetJarsExpert.Instance;
end;

class function TGetJarsExpert.Instance: TGetJarsExpert;
begin
  if FGetJarsExpert = nil then
    FGetJarsExpert := TGetJarsExpert.Create;
  Result := FGetJarsExpert;
end;

procedure TGetJarsExpert.GetJarsExecute(Sender: TObject);
begin
   FGetJars.ShowModal;
end;

constructor TGetJarsExpert.Create;

var
   NTAServices : INTAServices;
   Bmp: TBitmap;
   ImageIndex: integer;
//   Intf2: TIDENotifier;

begin

  inherited Create;

  { Main menu item }
   if Supports(BorlandIDEServices, INTAServices, NTAServices)
   then
      begin

         FProjectMenu := FindMenuItem('Project;QA Audits...');

         Bmp := TBitmap.Create;

         FActionGetJars := TAction.Create(nil);
         FActionGetJars.Category := 'Project';
         FActionGetJars.Caption := 'Gradle';
         FActionGetJars.Hint := 'Gradle for Delphi';
         FActionGetJars.Name := 'GetJarsAction';
         FActionGetJars.Visible := True;
         FActionGetJars.OnExecute := GetJarsExecute;
         FActionGetJars.Enabled := True;

         FMenuGetJars := TMenuItem.Create(nil);
         FMenuGetJars.Name := 'GetJars';
         FMenuGetJars.Caption := 'Gradle for Delphi';
         FMenuGetJars.AutoHotkeys := maAutomatic;
         FMenuGetJars.Action := FActionGetJars;

         NTAServices.AddActionMenu(FProjectMenu.Name, FActionGetJars, FMenuGetJars, True);

         Bmp.LoadFromResourceName(HInstance, 'AndroidBmp');
         ImageIndex := NTAServices.AddMasked(Bmp, clNone,
                                  'Android icon');

         FActionGetJars.ImageIndex := ImageIndex;
         FMenuGetJars.ImageIndex := ImageIndex;

         Bmp.DisposeOf;

         FGetJars := TFGetJars.Create(nil);
         FManifest := TFManifest.Create(nil);
         FRepositories := TFRepositories.Create(nil);
         FAddRep := TFAddRep.Create(nil);
         FHistory := TFHistory.Create(nil);

         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFGetJars, FGetJars);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFManifest, FManifest);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFRepositories, FRepositories);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFAddRep, FAddRep);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFHistory, FHistory);

         with TRegIniFile.Create(REG_KEY) do
         try
            if ReadString(REG_BUILD_OPTIONS, 'Repositories', '') = ''
            then
               WriteString(REG_BUILD_OPTIONS, 'Repositories', 'mavenCentral()¤google()¤jcenter()');
         finally
            Free;
         end;

//         Intf2 := TIDENotifier.Create;
//         IDENot := (BorlandIDEServices as IOTAServices).AddNotifier(Intf2);

      end;

end;

procedure TGetJarsExpert.RemoveActionFromToolbar(AAction: TAction);
var
  Services : INTAServices;
begin
  Services := (BorlandIDEServices as INTAServices);

  RemoveAction(AAction, Services.ToolBar[sCustomToolBar]);
  RemoveAction(AAction, Services.ToolBar[sDesktopToolBar]);
  RemoveAction(AAction, Services.ToolBar[sStandardToolBar]);
  RemoveAction(AAction, Services.ToolBar[sDebugToolBar]);
  RemoveAction(AAction, Services.ToolBar[sViewToolBar]);
//  RemoveAction(AAction, Services.ToolBar['InternetToolBar']);
end;

procedure TGetJarsExpert.RemoveAction(AAction: TAction; AToolbar: TToolbar);
var
  iCounter: Integer;
  btnTool : TToolButton;
begin
  for iCounter := AToolbar.ButtonCount - 1 downto 0 do
  begin
    btnTool := AToolbar.Buttons[iCounter];
    if btnTool.Action = AAction then
    begin
      AToolbar.Perform(CM_CONTROLCHANGE, WParam(btnTool), 0);
      btnTool.Free;
    end;
  end;
end;

function TGetJarsExpert.AddAction(ACaption, AHint, AName: String;
  AExecuteEvent, AUpdateEvent: TNotifyEvent): TAction;
var
  Service : INTAServices;
begin
  Service := (BorlandIDEServices as INTAServices);

  Result := TAction.Create(Service.ActionList);
  with Result do
  begin
    ActionList := Service.ActionList;
    Category := 'Build';
    Caption := ACaption;
    Hint := AHint;
    Name := AName;
    Visible := True;
    OnExecute := AExecuteEvent;
    OnUpdate := AUpdateEvent;
  end;
end;

destructor TGetJarsExpert.Destroy;
begin

//  (BorlandIDEServices as IOTACompileServices).RemoveNotifier(IDENot);

//   FGetJars.FDCJobs.Connected := False;
//
   FMenuGetJars.Free;
   FActionGetJars.Free;
   FManifest.Free;
   FRepositories.Free;
   FAddRep.Free;
   FHistory.Free;
   FGetJars.Free;

   inherited Destroy;

end;

class procedure TBADIToolsAPIFunctions.RegisterFormClassForTheming(
  const AFormClass: TCustomFormClass; const Component: TComponent);
begin

   {$IFDEF Ver320}
   Var
     ITS : IOTAIDEThemingServices250;
   {$ENDIF Ver320}
   {$IFDEF Ver330}
   Var
     ITS : IOTAIDEThemingServices250;
   {$ENDIF Ver330}
   {$IFDEF Ver340}
   Var
     ITS : IOTAIDEThemingServices;
  {$ENDIF Ver340}
   {$IFDEF Ver350}
   Var
     ITS : IOTAIDEThemingServices;
  {$ENDIF Ver350}

   Begin

     {$IFDEF Ver350}
     If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
       If ITS.IDEThemingEnabled Then
         Begin
           ITS.RegisterFormClass(AFormClass);
           If Assigned(Component) Then
             ITS.ApplyTheme(Component);
         End;
     {$ENDIF Ver350}

     {$IFDEF Ver340}
     If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
       If ITS.IDEThemingEnabled Then
         Begin
           ITS.RegisterFormClass(AFormClass);
           If Assigned(Component) Then
             ITS.ApplyTheme(Component);
         End;
     {$ENDIF Ver340}

     {$IFDEF Ver330}
     If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
       If ITS.IDEThemingEnabled Then
         Begin
           ITS.RegisterFormClass(AFormClass);
           If Assigned(Component) Then
             ITS.ApplyTheme(Component);
         End;
     {$ENDIF Ver330}
     {$IFDEF Ver320}
     If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
       If ITS.IDEThemingEnabled Then
         Begin
           ITS.RegisterFormClass(AFormClass);
           If Assigned(Component) Then
             ITS.ApplyTheme(Component);
         End;
     {$ENDIF Ver320}
   End;

end;

{ TIDENotifier }

//procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
//begin
//
//end;
//
//procedure TIDENotifier.AfterSave;
//begin
//
//end;
//
//procedure TIDENotifier.BeforeCompile(const Project: IOTAProject;
//  var Cancel: Boolean);
//begin
//
//end;
//
//procedure TIDENotifier.BeforeSave;
//begin
//
//end;
//
//procedure TIDENotifier.Destroyed;
//begin
//
//end;
//
//procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
//  const FileName: string; var Cancel: Boolean);
//begin
//
////   if NotifyCode = ofnActiveProjectChanged
////   then
////      FGetJars.FDCJobs.Connected := False;
//
//end;
//
//procedure TIDENotifier.Modified;
//begin
//
//end;

initialization
  FGetJarsExpert := TGetJarsExpert.Instance;
finalization
  FreeAndNil(FGetJarsExpert);
end.

