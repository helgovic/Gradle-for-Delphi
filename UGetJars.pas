unit UGetJars;

interface

uses
  Windows, SysUtils, Classes, vcl.Menus, vcl.ActnList, ToolsAPI, vcl.ComCtrls, vcl.ExtCtrls, vcl.Graphics, vcl.Controls,
  System.IOUtils, vcl.Dialogs, Threading, System.Win.Registry, Vcl.Forms, vcl.VirtualImageList, Vcl.ImageCollection;

type

  TGraphicHack = class(TGraphic);

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
   JclStrings, UFGetJars, UFAndroidManifest, UFRepositories, UFHistory, UFSettings, UFBackUp, UFRestore;

var
   FGetJarsExpert: TGetJarsExpert;
//   IDENot: Integer;

{$IFDEF VER360}
{$ELSEIF VER350}
{$ELSE}
function AddIconToImageList(AIcon: TIcon; ImageList: TCustomImageList;
  Stretch: Boolean): Integer;
const
  MaskColor = clBtnFace;
var
  SrcBmp, DstBmp: TBitmap;
  PSrc1, PSrc2, PDst: PRGBArray;
  X, Y: Integer;
begin
  Assert(Assigned(AIcon));
  Assert(Assigned(ImageList));

{$IFDEF DEBUG}
  if not AIcon.Empty then
    CnDebugger.LogFmt('AddIcon %dx%d To ImageList %dx%d', [AIcon.Width, AIcon.Height,
      ImageList.Width, ImageList.Height]);
{$ENDIF}

  if (ImageList.Width = 16) and (ImageList.Height = 16) and not AIcon.Empty and
    (AIcon.Width = 32) and (AIcon.Height = 32) then
  begin
    if Stretch then // ImageList 尺寸比图标大，指定拉伸的情况下，使用平滑处理
    begin
      SrcBmp := nil;
      DstBmp := nil;
      try
        SrcBmp := CreateEmptyBmp24(32, 32, MaskColor);
        DstBmp := CreateEmptyBmp24(16, 16, MaskColor);
        SrcBmp.Canvas.Draw(0, 0, AIcon);
        for Y := 0 to DstBmp.Height - 1 do
        begin
          PSrc1 := SrcBmp.ScanLine[Y * 2];
          PSrc2 := SrcBmp.ScanLine[Y * 2 + 1];
          PDst := DstBmp.ScanLine[Y];
          for X := 0 to DstBmp.Width - 1 do
          begin
            PDst^[X].b := (PSrc1^[X * 2].b + PSrc1^[X * 2 + 1].b + PSrc2^[X * 2].b
              + PSrc2^[X * 2 + 1].b) shr 2;
            PDst^[X].g := (PSrc1^[X * 2].g + PSrc1^[X * 2 + 1].g + PSrc2^[X * 2].g
              + PSrc2^[X * 2 + 1].g) shr 2;
            PDst^[X].r := (PSrc1^[X * 2].r + PSrc1^[X * 2 + 1].r + PSrc2^[X * 2].r
              + PSrc2^[X * 2 + 1].r) shr 2;
          end;
        end;
        Result := ImageList.AddMasked(DstBmp, MaskColor);
      finally
        if Assigned(SrcBmp) then FreeAndNil(SrcBmp);
        if Assigned(DstBmp) then FreeAndNil(DstBmp);
      end;
    end
    else
    begin
      // 指定不拉伸的情况下，把 32*32 图标的左上角 16*16 部分绘制来加入
      DstBmp := nil;
      try
        DstBmp := CreateEmptyBmp24(16, 16, MaskColor);
        DstBmp.Canvas.Draw(0, 0, AIcon);
        Result := ImageList.AddMasked(DstBmp, MaskColor);
      finally
        DstBmp.Free;
      end;
    end;
  end
  else if not AIcon.Empty then
    Result := ImageList.AddIcon(AIcon)
  else
    Result := -1;
end;

{$ENDIF}

function AddGraphicToVirtualImageList(Graphic: TGraphic; DstVirtual: TVirtualImageList;
  const ANamePrefix: string; Disabled: Boolean): Integer;
var
  C: Integer;
  R: TRect;
  Bmp: TBitmap;
  Mem: TMemoryStream;
  Collection: TImageCollection;
begin
  Result := -1;
  if (Graphic = nil) or (DstVirtual = nil) then
    Exit;

  if DstVirtual.ImageCollection is TImageCollection then
    Collection := DstVirtual.ImageCollection as TImageCollection
  else
    Exit;

  C := Collection.Count;
  Mem := TMemoryStream.Create;
  try
    if Graphic is TIcon then // 是 Icon 则直接存避免丢失透明度
    begin
      Mem.Clear;
      (Graphic as TIcon).SaveToStream(Mem);
    end
    else if Graphic is TBitmap then
    begin
      Mem.Clear;
      (Graphic as TBitmap).SaveToStream(Mem);
    end
    else
    begin
      Bmp := TBitmap.Create;
      try
        Bmp.PixelFormat := pf32bit;
        Bmp.AlphaFormat := afIgnored;
        Bmp.Width := Graphic.Width;
        Bmp.Height := Graphic.Height;
        R := Rect(0, 0, Bmp.Width, Bmp.Height);
        TGraphicHack(Graphic).Draw(Bmp.Canvas, R);

        Mem.Clear;
        Bmp.SaveToStream(Mem);
      finally
        Bmp.Free;
      end;
    end;
    Collection.Add(ANamePrefix + IntToStr(C), Mem);
  finally
    Mem.Free;
  end;

  DstVirtual.Add('', C, C, Disabled);
  Result := DstVirtual.Count - 1;
end;

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
                     Captions.Free;
                     Exit;
                  end;

            end;

         Result := MenuItems;
         Captions.Free;

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

         FProjectMenu := FindMenuItem('Project');

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

         NTAServices.AddActionMenu(FProjectMenu.Name, FActionGetJars, FMenuGetJars, False, True);

         Bmp.LoadFromResourceName(HInstance, 'AndroidBmp');

         {$IFDEF VER360}
             ImageIndex := AddGraphicToVirtualImageList(bmp, NTAServices.ImageList as TVirtualImageList, '', False);
         {$ELSEIF VER350}
             ImageIndex := AddGraphicToVirtualImageList(bmp, NTAServices.ImageList as TVirtualImageList, '', False);
         {$ELSE}
             ImageIndex := AddIconToImageList(AWizAction.FIcon, Svcs40.ImageList, False);
         {$ENDIF}

         FActionGetJars.ImageIndex := ImageIndex;
         FMenuGetJars.ImageIndex := ImageIndex;

         Bmp.Free;

         FGetJars := TFGetJars.Create(nil);
         FManifest := TFManifest.Create(nil);
         FRepositories := TFRepositories.Create(nil);
         FHistory := TFHistory.Create(nil);
         FSettings := TFSettings.Create(nil);
         FBackUp := TFBackUp.Create(nil);
         FRestore := TFRestore.Create(nil);

         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFGetJars, FGetJars);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFManifest, FManifest);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFRepositories, FRepositories);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFHistory, FHistory);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFSettings, FSettings);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFBackUp, FBackUp);
         TBADIToolsAPIFunctions.RegisterFormClassForTheming(TFRestore, FRestore);

         with TRegIniFile.Create(REG_KEY) do
         try
            if ReadString(REG_BUILD_OPTIONS, 'Repositories', '') = ''
            then
               WriteString(REG_BUILD_OPTIONS, 'Repositories', 'mavenCentral()oogle()center()');
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

   FGetJars.FDCJobs.Connected := False;
//
   FMenuGetJars.Free;
   FActionGetJars.Free;
   FManifest.Free;
   FRepositories.Free;
   FHistory.Free;
   FGetJars.Free;
   FSettings.Free;

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

   {$IFDEF Ver360}
   Var
     ITS : IOTAIDEThemingServices;
  {$ENDIF Ver360}

   Begin

     {$IFDEF Ver360}
     If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
       If ITS.IDEThemingEnabled Then
         Begin
           ITS.RegisterFormClass(AFormClass);
           If Assigned(Component) Then
             ITS.ApplyTheme(Component);
         End;
     {$ENDIF Ver360}

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

