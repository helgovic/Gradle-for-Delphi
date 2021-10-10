object FGetJars: TFGetJars
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Gradle for Delphi'
  ClientHeight = 808
  ClientWidth = 1043
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 15
    Top = 30
    Width = 67
    Height = 13
    Caption = 'Dependencies'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 530
    Top = 30
    Width = 152
    Height = 13
    Caption = 'Additional (Local) Dependencies'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 530
    Top = 221
    Width = 257
    Height = 13
    Caption = 'Exlude from final jar (test/compile time dependencies)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 15
    Top = 221
    Width = 161
    Height = 13
    Caption = 'Exclude when building JNI pas file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 358
    Top = 638
    Width = 59
    Height = 13
    Caption = 'Project Jobs'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 15
    Top = 410
    Width = 34
    Height = 13
    Caption = 'Output'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object MExclFinal: TMemo
    Left = 530
    Top = 240
    Width = 500
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    WordWrap = False
  end
  object MJars: TMemo
    Left = 15
    Top = 54
    Width = 500
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    WordWrap = False
  end
  object MAddJars: TMemo
    Left = 530
    Top = 54
    Width = 500
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    WordWrap = False
  end
  object LEJobName: TLabeledEdit
    Left = 15
    Top = 654
    Width = 328
    Height = 21
    Color = 3288877
    EditLabel.Width = 47
    EditLabel.Height = 13
    EditLabel.Caption = 'Job Name'
    EditLabel.Color = 10930928
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWhite
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentColor = False
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object LEJ2OLoc: TLabeledEdit
    Left = 701
    Top = 654
    Width = 328
    Height = 21
    Color = 3288877
    EditLabel.Width = 86
    EditLabel.Height = 13
    EditLabel.Caption = 'Java2OP Location'
    EditLabel.Color = 10930928
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWhite
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentColor = False
    EditLabel.ParentFont = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
  end
  object MExclJars: TMemo
    Left = 15
    Top = 240
    Width = 500
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 10
    WordWrap = False
  end
  object CBProjJobs: TComboBox
    Left = 358
    Top = 654
    Width = 328
    Height = 21
    AutoComplete = False
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = 3288877
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 11
    OnSelect = CBProjJobsSelect
  end
  object ASPB: TProgressBar
    Left = 15
    Top = 608
    Width = 1015
    Height = 19
    BorderWidth = 1
    ParentShowHint = False
    Smooth = True
    BarColor = clBlue
    BackgroundColor = clBlack
    ShowHint = False
    TabOrder = 12
    TabStop = True
  end
  object TSKeepLibs: TToggleSwitch
    Left = 15
    Top = 685
    Width = 157
    Height = 20
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    FrameColor = clWhite
    ParentFont = False
    StateCaptions.CaptionOn = 'Keep GradLibs Dir'
    StateCaptions.CaptionOff = 'Don'#39't keep GradLibs Dir'
    SwitchWidth = 40
    TabOrder = 13
    ThumbColor = clGreen
  end
  object BGo: TButton
    Left = 221
    Top = 730
    Width = 117
    Height = 49
    Caption = 'Create JNI pas file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = BGoClick
  end
  object BAddRep: TButton
    Left = 342
    Top = 730
    Width = 117
    Height = 49
    Caption = 'Repositories'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = BAddRepClick
  end
  object BClose: TButton
    Left = 100
    Top = 730
    Width = 117
    Height = 49
    Caption = 'Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 8
    ParentFont = False
    TabOrder = 4
  end
  object BNewJob: TButton
    Left = 584
    Top = 730
    Width = 117
    Height = 49
    Caption = 'New Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnClick = BNewJobClick
  end
  object BSave: TButton
    Left = 463
    Top = 730
    Width = 117
    Height = 49
    Caption = 'Save Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    OnClick = BSaveClick
  end
  object BDelete: TButton
    Left = 705
    Top = 730
    Width = 117
    Height = 49
    Caption = 'Delete Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 14
    OnClick = BDeleteClick
  end
  object MStatus: TMemo
    Left = 16
    Top = 429
    Width = 1014
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 15
  end
  object BCompileAll: TButton
    Left = 826
    Top = 730
    Width = 117
    Height = 49
    Caption = 'Compile project jar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 16
    OnClick = BCompileAllClick
  end
end
