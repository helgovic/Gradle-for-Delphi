object FRepositories: TFRepositories
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Repositories'
  ClientHeight = 269
  ClientWidth = 626
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 11
    Width = 345
    Height = 13
    Caption = 
      'Enter Repositories (ivy or maven). See syntax in Gradle document' +
      'ation.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object MRepositeries: TMemo
    Left = 24
    Top = 28
    Width = 591
    Height = 180
    TabOrder = 0
    WordWrap = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 202
    Width = 626
    Height = 67
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 190
    ExplicitWidth = 618
    object BCancel: TButton
      Left = 198
      Top = 9
      Width = 117
      Height = 49
      Caption = 'Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 0
      OnClick = BCancelClick
    end
    object BOK: TButton
      Left = 319
      Top = 9
      Width = 117
      Height = 49
      Caption = 'OK'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 1
      OnClick = BOKClick
    end
  end
end
