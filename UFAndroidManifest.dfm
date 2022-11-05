object FManifest: TFManifest
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'AndroidManifest'
  ClientHeight = 298
  ClientWidth = 532
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poDesigned
  OnShow = FormShow
  TextHeight = 13
  object Label3: TLabel
    Left = 15
    Top = 27
    Width = 241
    Height = 13
    Caption = 'The following Android Manifest entries were found'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object MAndrMan: TMemo
    Left = 15
    Top = 52
    Width = 500
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    WordWrap = False
  end
  object BDissMiss: TButton
    Left = 85
    Top = 234
    Width = 117
    Height = 49
    Caption = 'Dismiss'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 1
    OnClick = BDissMissClick
  end
  object BSaveToClipb: TButton
    Left = 206
    Top = 234
    Width = 117
    Height = 49
    Caption = 'Save To Clipboard'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 8
    ParentFont = False
    TabOrder = 2
    OnClick = BSaveToClipbClick
  end
  object BAddManifest: TButton
    Left = 327
    Top = 234
    Width = 117
    Height = 49
    Caption = 'Insert into Android manifest template'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 3
    WordWrap = True
  end
end
