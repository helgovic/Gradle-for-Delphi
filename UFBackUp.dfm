object FBackUp: TFBackUp
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Export/BackUp Settings'
  ClientHeight = 172
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  TextHeight = 15
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 95
    Height = 15
    Caption = 'Backup File Name'
  end
  object LStatus: TLabel
    Left = 4
    Top = 68
    Width = 3
    Height = 15
  end
  object BEBackUpFile: TButtonedEdit
    Left = 8
    Top = 32
    Width = 469
    Height = 23
    AutoSelect = False
    Images = ImageList1
    LeftButton.ImageIndex = 2
    RightButton.ImageIndex = 3
    RightButton.Visible = True
    TabOrder = 0
    OnRightButtonClick = BEBackUpFileRightButtonClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 97
    Width = 490
    Height = 75
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BOK: TButton
      Left = 126
      Top = 13
      Width = 117
      Height = 49
      Caption = 'OK'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = BOKClick
    end
    object Button1: TButton
      Left = 247
      Top = 13
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
      TabOrder = 1
    end
  end
  object ImageList1: TImageList
    ShareImages = True
    Left = 278
    Top = 75
    Bitmap = {
      494C010104000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F4F4F400ECEC
      EC00E9E9E900E0E0E000CDCDCD00BCBCBC00BDBDBD00C1C1C100CFCFCF00E2E2
      E200EAEAEA00F0F0F0000000000000000000000000FF000000FFE8DDD300D2BA
      A300D0B09300D2B09100D6B49400D7AE8700D0AB8300CD9F7900C69F7500C6A4
      7F00D0B69C00E8DED300000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001516A1002640E600243CE0001F36
      DD001327D7001223D3001020D0000D19C9000C16C5000810BF00080DBC00060B
      BA00090EB5000C0FB300090AB100050674000000000000000000434343004343
      4300434343004343430043434300434343004343430043434300434343004343
      430043434300434343000000000000000000E7DBD000C59F8000D0987800F5CF
      BE00FFEFE100FFEFE700FFF6E900FFE9D100FEE1BE00F6DEAA00EDC29400E1B5
      7E00D5A26C00C38A5300C5A28100E3D6C90000000000C8C8C800858585007373
      7300737373007373730073737300737373007373730073737300737373007373
      7300737373007C7C7C00ACACAC00000000002122A4000E2BE8000019DD000A25
      DA003B4AD1003B49D0003C48CE004D55D8004D54D6003F42BF003E41BB003D40
      B6001013A80000009F000203A30012137200000000000000000043434300CFCF
      CF00D3D3D300D3D3D300D3D3D300D3D3D300D3D3D300D3D3D300D3D3D300D3D3
      D300D1D1D100434343000000000000000000C7A58A00BF805B00E2B09A00F4D6
      C400FFF0E600FFF1E200FFF9F200FFF3DE00F6E9C900F0D6B100E7C29F00DCB1
      8800D5A47800D1996A00BB855200C8A88A00D4D4D400B5460000B5460000B546
      0000B5460000B5460000B5460000B5460000B5460000B5460000B5460000B546
      0000B5460000B546000055555500A6A6A6008E8ECE003049E9000013E3006071
      D400DFE0D600E6E6DF00EFEFE700A9A9A200A2A29B00F0F2E900E7E8E000E1E2
      DA007274BC000000A1000C0FB6007777A500000000000000000043434300C3C3
      C300BFBFBF00BCBCBC00BBBBBB00BABABA00B9B9B900BCBCBC00BDBDBD00C1C1
      C100CDCDCD00434343000000000000000000C7A58A00BF836000E3B7A400F4DE
      D400FAEFEE00F6EDDE00E9E0CF00D5CABD00DABDB300D3B9A500DEBA9D00D8B1
      9700D5AB8D00D29D7B00BB845800C8A88A00B5460000FF741200B5460000FFA8
      5E00FFA75D00FFA65B00FFA45800FFA25400FFA05000FF9D4B00FF9B4700FF9B
      4700E54D2300FF9B4700B546000076767600000000001E20AB003950EA000016
      E600F9F7E800EFEEF000F7F7F700CECECF00C9C9CA00F9F9F900F0F0F100FAF9
      EC000002AD001319C2000D0F860000000000000000000000000043434300C5C5
      C500C3C3C300C1C1C100C0C0C000BFBFBF00BFBFBF00C0C0C000C2C2C200C4C4
      C400D0D0D000434343000000000000000000C7A68A00BB7F5B00CC977700CFA6
      8400D7B09100DBA58800DFAD7B00DBA77000D4965B00C5965200C1874B00BB85
      4A00BC7E4D00C0815300B8805600C8A98D00B5460000FF7E2000B5460000FFB2
      7100FFB17000FFB16F00FFAF6B00FFAB6500FFA85F00FFA75C00FFA45700FFA2
      5300E5502800FFA25300B54600006E6E6E0000000000403EAF003945CC001834
      F000E2E5EC00FCFBF600FBFBFC00C3C3C300BABABA00FCFCFD00FCFCF800F0F2
      EF00040BBE001A20B0002C2C810000000000000000000000000043434300C8C8
      C800C7C7C700C6C6C600C5C5C500C5C5C500C5C5C500C6C6C600C7C7C700C9C9
      C900D3D3D300434343000000000000000000C3A28400B06C4000D59B7B00F5CC
      B600FFEBE200FFF5DF00FFF6E300FFE8D000FCDCBA00F7D2AE00F2CB9600E3B5
      8100D8A16B00C68A5200AD6C3900C5A48800B5460000FF883200B5460000FFBE
      8700FFBE8600FFBC8300FFBA7E00FFB77900FFB37200FFB06C00FFAD6700FFAA
      6200E5542F00FFA95F00B54600006E6E6E0000000000D6D6ED001C1DA8003D54
      E6007485EB00FFFFFA00FFFFFF007F7F7F006D6D6D00FFFFFF00FFFFFE008C94
      DD001B25C80012128600BFBFD80000000000000000000000000043434300CFCF
      CF00CDCDCD00CDCDCD00CDCDCD00CDCDCD00CDCDCD00CDCDCD00CECECE00CDCD
      CD00D8D8D800434343000000000000000000C6A48800BE7F5A00E0AE9600F4D4
      C700FFF4EB00FFF4EB00FFF8F600FEF2E500FCEDCD00F0D8BA00E5C2A500DEB5
      8C00D4A47B00D29A6F00BD845200C8A98B00B5460000FF954600B5460000FFC8
      9A00FFC89800FFC69600FFC49000FFC08B00FFBD8400FFB97D00FFB67600FFB2
      7100E5583600FFB06C00B54600006E6E6E000000000000000000000000001315
      A600AEADFF00BFBFFE00FFFFFF004E4E4E0034343400FFFFFF009999FF002826
      FF0010128500CBCBE1000000000000000000000000000000000043434300D4D4
      D400D5D5D500D5D5D500D5D5D500D4D4D400D4D4D400D3D3D300D3D3D300D2D2
      D200DBDBDB00434343000000000000000000C7A58A00BF836000E0B5A300F0D8
      CA00F9E4DF00E6D5C300E4CFB900D8B99F00D0B39300CFAD8D00D4AA8700D5A7
      8700D4A48500D5A27F00BC845900C9AA8F00B5460000FFA15B00B5460000FFD3
      AC00FFD3AD00FFD1A900FFCEA400FFCB9E00FFC79500FFC49000FFC08A00FFBD
      8400E55D3E00FFBA7E00B54600006F6F6F000000000000000000000000007D7D
      CB00AEB0FF00A6A5FF00EAEAFF003232320021212100E8E8FF005453FF004041
      FF006565AA00000000000000000000000000000000000000000043434300DBDB
      DB00DADADA00DCDCDC00DDDDDD00DCDCDC00DBDBDB00D9D9D900D8D8D800D6D6
      D600DEDEDE00434343000000000000000000C6A68C00B77A5400C68E6C00D2A4
      8100D9B49500E3B69100E7C19A00E7BC9400E3B58200D9AB7700CD9B6300C687
      5600BB7E4400BC7B4D00B47B5000C7A98D00B5460000FFAE7100B5460000FFDC
      BE00FFDCBE00FFDAB900FFD8B500FFD5AF00FFD1A900FFCEA200FFCA9A00FFC8
      9700E5624900FFC38E00B5460000828282000000000000000000000000000000
      00002226B600ABAEF900B7B6FF00ACACA800A5A59F007776FF006164FA001D1F
      A70000000000000000000000000000000000000000000000000043434300DEDE
      DE00E0E0E000E1E1E100E2E2E200E1E1E100DFDFDF00DCDCDC00DADADA00D8D8
      D800E1E1E100434343000000000000000000C4A28600B16C4100D7A08200F8D4
      C000FFF1EA00FFEEE200FFF2E100FDE4C600F6DBB600EED0A700E9C19600E0B8
      8300D9A87100CD905900AE6D3900C6A68800B5460000FFBB8800B5460000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00B5460000C7C7C7000000000000000000000000000000
      00003737B400656AD800C4C4FF00FAFAFF00FDFDFF007D7EFF004A4DD6002525
      980000000000000000000000000000000000000000000000000043434300E6E6
      E600E7E7E700E8E8E800E8E8E800E7E7E700E4E4E400CDCDCD00C2C2C200C0C0
      C000CFCFCF00434343000000000000000000C7A68A00BE7F5A00DEAC9700F2D6
      C700FFF8F200FFF8F500FFFBF200FEF1E200F6E3C900F4D3B600E7C5A300DEB5
      9500D7A57F00CE9C6D00BA835300C9AB8E00B5460000FFC99F00FFB27600B546
      0000B5460000B5460000B5460000B5460000B5460000B5460000B5460000B546
      0000B5460000B5460000BEBEBE00000000000000000000000000000000000000
      0000B4B4E200181BB200ADB1F700CECEF800C9C9F7008285F900191BA5009D9D
      D00000000000000000000000000000000000000000000000000043434300EAEA
      EA00ECECEC00EDEDED00EDEDED00EBEBEB00E7E7E70043434300575757006B6B
      6B0080808000808080000000000000000000C7A58900BE805E00DCB09A00E9CC
      BB00ECD6C600E3C9B200D9C3A800DCBB9D00D7B39300CDAC8600D0A88100CDA0
      7C00CD977500CE947500BB835A00C9A98D00B5460000FFD5B500FFD5B500FFD5
      B400FFD6B500FFD5B300FFD5B300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00B5460000BEBEBE0000000000000000000000000000000000000000000000
      000000000000000000001416AF00D5D5FF00C3C2FF001415A500C7C7E6000000
      000000000000000000000000000000000000000000000000000043434300EDED
      ED00EFEFEF00EFEFEF00EEEEEE00EBEBEB00E8E8E80057575700DCDCDC00DBDB
      DB0080808000000000000000000000000000C6A58A00B77E5700CFA48500DFB7
      9A00E8C0A700EDC9AE00F4D2B200F6D7B400F6DAB100F4DCAE00F0D7A300E9D1
      9700DCBE8200C49D6400B2774C00C6A68800B5460000FFE0C700FFE0C700FFE0
      C700FFE0C700FFE0C700FFFFFF00B5460000B5460000B5460000B5460000B546
      0000D4D4D4000000000000000000000000000000000000000000000000000000
      000000000000000000006B6BC800DDDFFF00D8D9FF005353B700000000000000
      000000000000000000000000000000000000000000000000000043434300EEEE
      EE00F0F0F000EFEFEF00EDEDED00EBEBEB00E7E7E7006B6B6B00E0E0E0008080
      800000000000000000000000000000000000C8AC9000D4AB8C00FFE5D600FFE4
      D300FFE2D100FFE2D000FFE4C900FFE5C500FFE8C100FFEABE00FFEFBC00FFF3
      BA00FFF7B900FFFDB800D2B57600C9AE8F00B5460000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00B5460000BCBCBC000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008B8FE700949BEA00DBDBF000000000000000
      000000000000000000000000000000000000000000000000000043434300F5F5
      F500F7F7F700F6F6F600F5F5F500F3F3F300F0F0F00080808000808080000000
      000000000000000000000000000000000000E7DCD100CEB29700ECC9AF00FEDE
      CC00FFE4D400FFE6D600FFE8D100FFEACB00FFEDC700FFEFC400FFF4C000FFF5
      BC00FEF0B000ECD99600CFB69100E4D8CB0000000000B5460000B5460000B546
      0000B5460000B5460000D4D4D400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000434343004343
      4300434343004343430043434300434343004343430080808000000000000000
      000000000000000000000000000000000000000000FF000000FFE8DED400D3BC
      A500D0B19600D3B29600D8B69600DABA9600DBBA9400D8BA9100D3B78C00D0B4
      8F00D3BDA300E8DDD300000000FF000000FF424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFC003C003FFFF0000C0030000
      80010000C003000000000000C003000000008001C003000000008001C0030000
      00008001C00300000000E003C00300000000E007C00300000000F00FC0030000
      0000F00FC00300000001F00FC00300000003FC1FC00700000007FC3FC00F0000
      00FFFE3FC01F000081FFFFFFC03FC00300000000000000000000000000000000
      000000000000}
  end
  object FileOpenDialog: TFileOpenDialog
    DefaultExtension = 'db'
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 75
    Top = 75
  end
  object FDSQLiteBackup: TFDSQLiteBackup
    DriverLink = FDPhysSQLiteDriverLink1
    Catalog = 'MAIN'
    DestCatalog = 'MAIN'
    Left = 188
    Top = 32
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 396
    Top = 66
  end
end
