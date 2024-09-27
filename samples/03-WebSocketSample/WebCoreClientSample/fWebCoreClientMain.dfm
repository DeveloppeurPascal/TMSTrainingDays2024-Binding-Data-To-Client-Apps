object frmWebCoreClientMain: TfrmWebCoreClientMain
  Width = 640
  Height = 480
  CSSLibrary = cssBootstrap
  ElementFont = efCSS
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  OnCreate = WebFormCreate
  object btnStart: TWebButton
    Left = 8
    Top = 8
    Width = 96
    Height = 25
    Caption = 'Start'
    ElementClassName = 'btn btn-light'
    ElementFont = efCSS
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnStartClick
  end
  object btnStop: TWebButton
    Left = 118
    Top = 8
    Width = 96
    Height = 25
    Caption = 'Stop'
    ChildOrder = 1
    ElementClassName = 'btn btn-light'
    ElementFont = efCSS
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnStopClick
  end
  object WebEdit1: TWebEdit
    Left = 8
    Top = 63
    Width = 121
    Height = 22
    ChildOrder = 2
    EditType = weNumeric
    ElementClassName = 'form-control'
    ElementFont = efCSS
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    Text = 'WebEdit1'
    WidthPercent = 100.000000000000000000
  end
  object WebEdit2: TWebEdit
    Left = 143
    Top = 63
    Width = 121
    Height = 22
    ChildOrder = 3
    EditType = weNumeric
    ElementClassName = 'form-control'
    ElementFont = efCSS
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    Text = 'WebEdit2'
    WidthPercent = 100.000000000000000000
  end
  object btnSub: TWebButton
    Left = 393
    Top = 64
    Width = 96
    Height = 25
    Caption = 'Sub'
    ChildOrder = 4
    ElementClassName = 'btn btn-light'
    ElementFont = efCSS
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnSubClick
  end
  object btnAdd: TWebButton
    Left = 280
    Top = 64
    Width = 96
    Height = 25
    Caption = 'Add'
    ChildOrder = 5
    ElementClassName = 'btn btn-light'
    ElementFont = efCSS
    HeightStyle = ssAuto
    HeightPercent = 100.000000000000000000
    WidthPercent = 100.000000000000000000
    OnClick = btnAddClick
  end
  object WebMemo1: TWebMemo
    Left = 8
    Top = 104
    Width = 481
    Height = 313
    ElementClassName = 'form-control'
    ElementFont = efCSS
    HeightPercent = 100.000000000000000000
    Lines.Strings = (
      'WebMemo1')
    ReadOnly = True
    SelLength = 0
    SelStart = 0
    WidthPercent = 100.000000000000000000
  end
  object WebSocketClient1: TWebSocketClient
    OnConnect = WebSocketClient1Connect
    OnDisconnect = WebSocketClient1Disconnect
    OnMessageReceived = WebSocketClient1MessageReceived
    Left = 304
    Top = 224
  end
end
