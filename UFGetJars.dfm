object FGetJars: TFGetJars
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Gradle for Delphi'
  ClientHeight = 791
  ClientWidth = 1055
  Color = 3288877
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 20
    Top = 2
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
    Top = 2
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
    Left = 363
    Top = 622
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
    Top = 382
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
    Top = 638
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
    Text = ''
  end
  object LEJ2OLoc: TLabeledEdit
    Left = 706
    Top = 638
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
    TabOrder = 8
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
    Left = 363
    Top = 638
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
    TabOrder = 7
    OnSelect = CBProjJobsSelect
  end
  object ASPB: TProgressBar
    Left = 20
    Top = 592
    Width = 1015
    Height = 19
    BorderWidth = 1
    ParentShowHint = False
    Smooth = True
    BarColor = clBlue
    BackgroundColor = clBlack
    ShowHint = False
    TabOrder = 5
    TabStop = True
  end
  object TSKeepLibs: TToggleSwitch
    Left = 20
    Top = 669
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
    TabOrder = 9
    ThumbColor = clGreen
  end
  object BGo: TButton
    Left = 166
    Top = 714
    Width = 117
    Height = 49
    Caption = 'Create JNI pas file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
    OnClick = BGoClick
  end
  object BAddRep: TButton
    Left = 287
    Top = 714
    Width = 117
    Height = 49
    Caption = 'Repositories'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 14
    OnClick = BAddRepClick
  end
  object BClose: TButton
    Left = 45
    Top = 714
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
    TabOrder = 12
  end
  object BNewJob: TButton
    Left = 529
    Top = 714
    Width = 117
    Height = 49
    Caption = 'New Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 16
    OnClick = BNewJobClick
  end
  object BSave: TButton
    Left = 408
    Top = 714
    Width = 117
    Height = 49
    Caption = 'Save Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 15
    OnClick = BSaveClick
  end
  object BDelete: TButton
    Left = 650
    Top = 714
    Width = 117
    Height = 49
    Caption = 'Delete Job'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 17
    OnClick = BDeleteClick
  end
  object MStatus: TMemo
    Left = 20
    Top = 411
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
    TabOrder = 4
  end
  object BCompileAll: TButton
    Left = 771
    Top = 714
    Width = 117
    Height = 49
    Caption = 'Compile project jar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 18
    OnClick = BCompileAllClick
  end
  object BHistory: TButton
    Left = 892
    Top = 714
    Width = 117
    Height = 49
    Caption = 'Show History'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 19
    OnClick = BHistoryClick
  end
  object TSResources: TToggleSwitch
    Left = 192
    Top = 669
    Width = 161
    Height = 20
    Color = 3288877
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    FrameColor = clWhite
    ParentFont = False
    State = tssOn
    StateCaptions.CaptionOn = 'Process resources'
    StateCaptions.CaptionOff = 'Don'#39't process resources'
    SwitchWidth = 40
    TabOrder = 10
    ThumbColor = clGreen
    OnClick = TSResourcesClick
  end
  object Button1: TButton
    Left = 702
    Top = 672
    Width = 57
    Height = 29
    Caption = 'Button1'
    TabOrder = 11
    Visible = False
    OnClick = Button1Click
  end
  object FDCJobs: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=D:\Deplhi\Explorer\ExplorerGJ.db')
    LoginPrompt = False
    Left = 75
    Top = 75
  end
  object QGetJobs: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'Select h.SaveDate,'
      '       h.Dependencies,'
      '       h.AddDependencies,'
      '       h.ExclJNI,'
      '       h.ExclFinal'
      '  from History h,'
      '       Jobs j'
      '  where h.JobID = j.ID and'
      '        j.JobName = :JobName'
      '  order by 1 desc')
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
      'BEGIN TRANSACTION;'
      ''
      '-- Table: History'
      
        'CREATE TABLE History (JobID INTEGER NOT NULL REFERENCES Jobs (ID' +
        ') ON DELETE CASCADE, SaveDate DATETIME NOT NULL, Dependencies ST' +
        'RING NOT NULL, AddDependencies STRING NOT NULL, ExclJNI STRING N' +
        'OT NULL, ExclFinal STRING NOT NULL);'
      ''
      '-- Table: Jobs'
      
        'CREATE TABLE Jobs (ID INTEGER PRIMARY KEY NOT NULL UNIQUE, JobNa' +
        'me STRING NOT NULL);'
      ''
      '-- Table: Parms'
      
        'CREATE TABLE Parms (Name STRING PRIMARY KEY NOT NULL, Value STRI' +
        'NG NOT NULL);'
      ''
      '-- Table: Reposittories'
      
        'CREATE TABLE Reposittories (Name STRING PRIMARY KEY NOT NULL UNI' +
        'QUE, Link STRING NOT NULL);'
      ''
      '-- Index: JobIdx'
      
        'CREATE UNIQUE INDEX JobIdx ON History (JobID DESC, SaveDate DESC' +
        ');'
      ''
      '-- Index: PrimaryIdx'
      'CREATE UNIQUE INDEX PrimaryIdx ON Parms (Name);'
      ''
      'COMMIT TRANSACTION;')
    Left = 481
    Top = 73
  end
  object QGetCurrJob: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'Select h.SaveDate,'
      '       h.Dependencies,'
      '       h.AddDependencies,'
      '       h.ExclJNI,'
      '       h.ExclFinal'
      '  from History h,'
      '       Jobs j'
      ' where j.JobName = :JobName'
      '   and h.JobID = j.ID'
      ' and h.SaveDate = (Select max(SaveDate)'
      '                   from History'
      '                  where JobID = j.ID)')
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
      '             ExclFinal)'
      '      values((select ID'
      '                from Jobs'
      '               where JobName = :JobName),'
      '               :SaveDate,'
      '               :Dependencies,'
      '               :AddDependencies,'
      '               :ExclJNI,'
      '               :ExclFinal)')
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
      '       h.ExclFinal'
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
    Left = 280
    Top = 193
  end
  object QDelRepositories: TFDQuery
    Connection = FDCJobs
    SQL.Strings = (
      'delete'
      'from'
      '  Reposittories')
    Left = 278
    Top = 75
  end
end
