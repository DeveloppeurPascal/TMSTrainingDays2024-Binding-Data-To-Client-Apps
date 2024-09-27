object frmVCLClientMain: TfrmVCLClientMain
  Left = 0
  Top = 0
  Caption = 'WebSocket VCL Client Sample'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 79
    Width = 618
    Height = 359
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    TabOrder = 0
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 624
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 1
    object btnStart: TButton
      AlignWithMargins = True
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Start'
      TabOrder = 0
      OnClick = btnStartClick
    end
    object btnStop: TButton
      AlignWithMargins = True
      Left = 75
      Top = 0
      Width = 75
      Height = 22
      Caption = 'Stop'
      TabOrder = 1
      OnClick = btnStopClick
    end
  end
  object TMSFNCWebsocketClient1: TTMSFNCWebsocketClient
    Left = 304
    Top = 224
    Width = 26
    Height = 26
    Visible = True
    OnConnect = TMSFNCWebsocketClient1Connect
    OnDisconnect = TMSFNCWebsocketClient1Disconnect
    OnMessageReceived = TMSFNCWebsocketClient1MessageReceived
  end
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 32
    Width = 618
    Height = 41
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 3
    object Edit1: TEdit
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 121
      Height = 31
      Align = alLeft
      NumbersOnly = True
      TabOrder = 0
      Text = 'Edit1'
      ExplicitHeight = 23
    end
    object btnSub: TButton
      AlignWithMargins = True
      Left = 340
      Top = 5
      Width = 75
      Height = 31
      Align = alLeft
      Caption = 'Sub'
      TabOrder = 3
      OnClick = btnSubClick
    end
    object btnAdd: TButton
      AlignWithMargins = True
      Left = 259
      Top = 5
      Width = 75
      Height = 31
      Align = alLeft
      Caption = 'Add'
      TabOrder = 2
      OnClick = btnAddClick
    end
    object Edit2: TEdit
      AlignWithMargins = True
      Left = 132
      Top = 5
      Width = 121
      Height = 31
      Align = alLeft
      NumbersOnly = True
      TabOrder = 1
      Text = 'Edit2'
      ExplicitHeight = 23
    end
  end
  object TMSFNCWaitingIndicator1: TTMSFNCWaitingIndicator
    Left = 0
    Top = 76
    Width = 624
    Height = 365
    Align = alClient
    ParentDoubleBuffered = False
    DoubleBuffered = True
    TabOrder = 4
    Active = False
    Appearance.Indicators = 5
    Appearance.IndicatorShape = wisCircle
    Appearance.MoveShape = wmsCircle
    AnimationSpeed = 4.000000000000000000
  end
end
