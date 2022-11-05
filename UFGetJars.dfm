object FGetJars: TFGetJars
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Gradle for Delphi'
  ClientHeight = 803
  ClientWidth = 1052
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MMFGetJars
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 20
    Top = 8
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
    Left = 535
    Top = 8
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
    Left = 535
    Top = 193
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
    Left = 20
    Top = 193
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
    Left = 537
    Top = 636
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
  object LStatus: TLabel
    Left = 20
    Top = 407
    Width = 1014
    Height = 20
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object MExclFinal: TMemo
    Left = 535
    Top = 212
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
  object MJars: TMemo
    Left = 20
    Top = 26
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
  object MAddJars: TMemo
    Left = 535
    Top = 28
    Width = 500
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    WordWrap = False
  end
  object LEJobName: TLabeledEdit
    Left = 20
    Top = 650
    Width = 497
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
    TabOrder = 7
    Text = ''
  end
  object MExclJars: TMemo
    Left = 20
    Top = 212
    Width = 500
    Height = 159
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    WordWrap = False
  end
  object CBProjJobs: TComboBox
    Left = 537
    Top = 650
    Width = 497
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
    TabOrder = 8
    OnSelect = CBProjJobsSelect
  end
  object ASPB: TProgressBar
    Left = 20
    Top = 604
    Width = 1015
    Height = 19
    BorderWidth = 1
    ParentShowHint = False
    Smooth = True
    BarColor = clBlue
    BackgroundColor = clBlack
    ShowHint = False
    TabOrder = 6
    TabStop = True
  end
  object TSKeepLibs: TToggleSwitch
    Left = 20
    Top = 681
    Width = 183
    Height = 20
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    FrameColor = clWhite
    ParentFont = False
    StateCaptions.CaptionOn = 'Keep temporary directories'
    StateCaptions.CaptionOff = 'Delete temporary directories'
    SwitchWidth = 40
    TabOrder = 9
    ThumbColor = clGreen
  end
  object BGo: TButton
    Left = 168
    Top = 735
    Width = 117
    Height = 49
    Caption = 'Create JNI pas file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 12
    OnClick = BGoClick
  end
  object BAddRep: TButton
    Left = 289
    Top = 735
    Width = 117
    Height = 49
    Caption = 'Repositories'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
    OnClick = BAddRepClick
  end
  object BClose: TButton
    Left = 47
    Top = 735
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
    TabOrder = 11
  end
  object BNewJob: TButton
    Left = 531
    Top = 735
    Width = 117
    Height = 49
    Caption = 'New Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 15
    OnClick = BNewJobClick
  end
  object BSave: TButton
    Left = 410
    Top = 735
    Width = 117
    Height = 49
    Caption = 'Save Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 14
    OnClick = BSaveClick
  end
  object BDelete: TButton
    Left = 652
    Top = 735
    Width = 117
    Height = 49
    Caption = 'Delete Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 16
    OnClick = BDeleteClick
  end
  object MStatus: TMemo
    Left = 20
    Top = 433
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
    TabOrder = 5
  end
  object BCompileAll: TButton
    Left = 773
    Top = 735
    Width = 117
    Height = 49
    Caption = 'Compile project jar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 17
    OnClick = BCompileAllClick
  end
  object BHistory: TButton
    Left = 894
    Top = 735
    Width = 117
    Height = 49
    Caption = 'Show History'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 18
    OnClick = BHistoryClick
  end
  object Button1: TButton
    Left = 702
    Top = 686
    Width = 57
    Height = 29
    Caption = 'Button1'
    TabOrder = 10
    Visible = False
    OnClick = Button1Click
  end
  object TSInclRes: TToggleSwitch
    Left = 20
    Top = 377
    Width = 162
    Height = 20
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    FrameColor = clWhite
    ParentFont = False
    StateCaptions.CaptionOn = 'Include Resources'
    StateCaptions.CaptionOff = 'Don'#39't Include Resources'
    SwitchWidth = 40
    TabOrder = 4
    ThumbColor = clGreen
  end
  object FDCJobs: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=D:\Downloads\XE11\GetJars\Gradle.db')
    LoginPrompt = False
    Left = 75
    Top = 75
  end
  object QGetJobs: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'Select'
      '  h.SaveDate,'
      '  h.Dependencies,'
      '  h.AddDependencies,'
      '  h.ExclJNI,'
      '  h.ExclFinal,'
      '  h.InclRes'
      'From'
      '  History h,'
      '  Jobs j'
      'Where'
      '  h.JobID = j.ID And'
      '  (j.JobName = :JobName)'
      'Order By'
      '  1 Desc')
    Left = 481
    Top = 133
    ParamData = <
      item
        Name = 'JOBNAME'
        ParamType = ptInput
      end>
  end
  object TJobs: TFDTable
    Connection = FDCJobs
    TableName = 'Jobs'
    Left = 75
    Top = 191
  end
  object THistory: TFDTable
    Connection = FDCJobs
    TableName = 'History'
    Left = 887
    Top = 133
  end
  object QDefDB: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'PRAGMA foreign_keys = off;'
      'BEGIN TRANSACTION;'
      ''
      '-- Table: History'
      
        'CREATE TABLE History (JobID INTEGER NOT NULL REFERENCES Jobs (ID' +
        ') ON DELETE CASCADE, SaveDate DATETIME NOT NULL, Dependencies ST' +
        'RING NOT NULL, AddDependrencies STRING NOT NULL, ExclJNI STRING ' +
        'NOT NULL, ExclFinal STRING NOT NULL, InclRes BOOLEAN NOT NULL DE' +
        'FAULT (False));'
      ''
      '-- Table: Jobs'
      
        'CREATE TABLE Jobs (ID INTEGER PRIMARY KEY NOT NULL UNIQUE, JobNa' +
        'me STRING NOT NULL);'
      ''
      '-- Table: Reposittories'
      
        'CREATE TABLE Reposittories (Name STRING PRIMARY KEY NOT NULL UNI' +
        'QUE, Link STRING NOT NULL);'
      ''
      '-- Index: JobIdx'
      
        'CREATE UNIQUE INDEX JobIdx ON History (JobID DESC, SaveDate DESC' +
        ');'
      ''
      'COMMIT TRANSACTION;'
      'PRAGMA foreign_keys = on;')
    Left = 278
    Top = 75
  end
  object QGetCurrJob: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'Select'
      '  h.SaveDate,'
      '  h.Dependencies,'
      '  h.AddDependencies,'
      '  h.ExclJNI,'
      '  h.ExclFinal,'
      '  h.InclRes'
      'From'
      '  History h,'
      '  Jobs j'
      'Where'
      '  h.JobID = j.ID And'
      '  (h.SaveDate = (Select'
      '    Max(History.SaveDate)'
      '  From'
      '    History'
      '  Where'
      '    History.JobID = j.ID) And'
      '  j.JobName = :JobName)')
    Left = 684
    Top = 75
    ParamData = <
      item
        Name = 'JOBNAME'
        ParamType = ptInput
      end>
  end
  object TRepositories: TFDTable
    Connection = FDCJobs
    TableName = 'Reposittories'
    Left = 481
    Top = 191
  end
  object QInsHist: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'insert into History'
      '            (JobID,'
      '             SaveDate,'
      '             Dependencies,'
      '             AddDependencies,'
      '             ExclJNI,'
      '             ExclFinal,'
      '             InclRes)'
      '      values((select ID'
      '                from Jobs'
      '               where JobName = :JobName),'
      '               :SaveDate,'
      '               :Dependencies,'
      '               :AddDependencies,'
      '               :ExclJNI,'
      '               :ExclFinal,'
      '               :InclRes)')
    Left = 684
    Top = 133
    ParamData = <
      item
        Name = 'JOBNAME'
        ParamType = ptInput
      end
      item
        Name = 'SAVEDATE'
        ParamType = ptInput
      end
      item
        Name = 'DEPENDENCIES'
        ParamType = ptInput
      end
      item
        Name = 'ADDDEPENDENCIES'
        ParamType = ptInput
      end
      item
        Name = 'EXCLJNI'
        ParamType = ptInput
      end
      item
        Name = 'EXCLFINAL'
        ParamType = ptInput
      end
      item
        Name = 'INCLRES'
        ParamType = ptInput
      end>
  end
  object QGetID: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'Select Max(ID) + 1 as NewID'
      'from Jobs')
    Left = 887
    Top = 75
  end
  object QGetJobByDate: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'Select h.Dependencies,'
      '       h.AddDependencies,'
      '       h.ExclJNI,'
      '       h.ExclFinal,'
      '       h.InclRes'
      '  from History h,'
      '       Jobs j'
      ' where j.JobName = :JobName'
      '   and h.JobID = j.ID'
      ' and h.SaveDate = :Date')
    Left = 75
    Top = 133
    ParamData = <
      item
        Name = 'JOBNAME'
        ParamType = ptInput
      end
      item
        Name = 'DATE'
        ParamType = ptInput
      end>
  end
  object QGetJobByName: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'Select ID'
      'from Jobs'
      'where JobName = :JobName')
    Left = 278
    Top = 133
    ParamData = <
      item
        Name = 'JOBNAME'
        ParamType = ptInput
      end>
  end
  object TParms: TFDTable
    Connection = FDCJobs
    TableName = 'Parms'
    Left = 278
    Top = 191
  end
  object QDelRepositories: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'delete'
      'from'
      '  Reposittories')
    Left = 481
    Top = 75
  end
  object MMFGetJars: TMainMenu
    Left = 684
    Top = 191
    object MISettings: TMenuItem
      Caption = 'Settings'
      OnClick = MISettingsClick
    end
  end
end
