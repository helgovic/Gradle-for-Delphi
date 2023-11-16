object FHistory: TFHistory
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Job History'
  ClientHeight = 395
  ClientWidth = 358
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 15
  object LBHistory: TListBox
    Left = 0
    Top = 0
    Width = 358
    Height = 319
    Align = alTop
    ItemHeight = 15
    TabOrder = 0
    OnClick = LBHistoryClick
  end
  object BRevert: TButton
    Left = 77
    Top = 343
    Width = 117
    Height = 49
    Caption = 'Revert'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = BRevertClick
  end
  object BClose: TButton
    Left = 200
    Top = 343
    Width = 117
    Height = 49
    Caption = 'Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = BCloseClick
  end
end
