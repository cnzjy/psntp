object PSNtpClientForm: TPSNtpClientForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'PlumeSoft '#32593#32476#23545#26102#23567#24037#20855
  ClientHeight = 290
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    378
    290)
  TextHeight = 15
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 362
    Height = 241
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = #23545#26102#35774#32622
    TabOrder = 0
    DesignSize = (
      362
      241)
    object lblLast: TLabel
      Left = 16
      Top = 148
      Width = 71
      Height = 15
      Caption = #26368#21518#23545#26102': '#26080
    end
    object lblSucc: TLabel
      Left = 16
      Top = 169
      Width = 71
      Height = 15
      Caption = #25104#21151#23545#26102': '#26080
    end
    object lbledtServer: TLabeledEdit
      Left = 16
      Top = 40
      Width = 332
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 68
      EditLabel.Height = 15
      EditLabel.Caption = #23545#26102#26381#21153#22120':'
      TabOrder = 0
      Text = 'time.pool.aliyun.com'
      OnChange = lbledtServerChange
      ExplicitWidth = 270
    end
    object chkAutoSync: TCheckBox
      Left = 16
      Top = 69
      Width = 332
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = #27599#22825#33258#21160#23545#26102#12290
      TabOrder = 1
      OnClick = chkAutoSyncClick
      ExplicitWidth = 270
    end
    object dtpTime: TDateTimePicker
      Left = 40
      Top = 92
      Width = 308
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      Date = 45119.000000000000000000
      Time = 0.333333333335758700
      Kind = dtkTime
      TabOrder = 2
      OnChange = dtpTimeChange
      ExplicitWidth = 246
    end
    object btnSync: TButton
      Left = 16
      Top = 190
      Width = 105
      Height = 25
      Caption = #31435#21363#23545#26102'(&S)'
      TabOrder = 4
      OnClick = btnSyncClick
    end
    object chkAutoRun: TCheckBox
      Left = 16
      Top = 125
      Width = 264
      Height = 17
      Caption = #24320#26426#33258#21160#21551#21160#12290
      TabOrder = 3
      OnClick = chkAutoRunClick
    end
  end
  object btnMin: TButton
    Left = 295
    Top = 255
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #26368#23567#21270'(&M)'
    TabOrder = 2
    OnClick = btnMinClick
  end
  object btnClose: TButton
    Left = 214
    Top = 255
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #36864#20986'(&X)'
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object idsntp: TIdSNTP
    Port = 123
    ReceiveTimeout = 2000
    Left = 152
  end
  object tmr1: TTimer
    OnTimer = tmr1Timer
    Left = 192
  end
  object idntfrz1: TIdAntiFreeze
    Left = 112
  end
  object pmTrayIcon: TPopupMenu
    Left = 232
    Top = 2
    object mniShow: TMenuItem
      Caption = #26174#31034#20027#30028#38754'(&S)'
      Default = True
      OnClick = mniShowClick
    end
    object mniX1: TMenuItem
      Caption = #36864#20986#31243#24207'(&X)'
      OnClick = btnCloseClick
    end
  end
end
