object fmClicker: TfmClicker
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Demo-clicker'
  ClientHeight = 297
  ClientWidth = 502
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cbPortList: TComboBox
    Left = 8
    Top = 11
    Width = 156
    Height = 21
    Hint = 'COM-port'
    Style = csDropDownList
    TabOrder = 0
  end
  object btnRefresh: TButton
    Left = 181
    Top = 9
    Width = 75
    Height = 25
    Hint = 'Refresh COM-port list'
    Caption = 'Refresh'
    TabOrder = 1
    OnClick = btnRefreshClick
  end
  object btnOpenClose: TButton
    Left = 181
    Top = 36
    Width = 75
    Height = 25
    Hint = 'Open/close COM-port'
    Caption = 'Open'
    TabOrder = 2
    OnClick = btnOpenCloseClick
  end
  object cbBaudRateList: TComboBox
    Left = 8
    Top = 38
    Width = 156
    Height = 21
    Hint = 'Baudrate'
    Style = csDropDownList
    TabOrder = 3
  end
  object gbMouse: TGroupBox
    Left = 8
    Top = 67
    Width = 237
    Height = 78
    Caption = 'Mouse'
    TabOrder = 4
    object edtX: TEdit
      Left = 11
      Top = 48
      Width = 62
      Height = 21
      Hint = 'Delta X'
      MaxLength = 4
      TabOrder = 0
      Text = '300'
    end
    object edtY: TEdit
      Left = 79
      Top = 48
      Width = 62
      Height = 21
      Hint = 'Delta Y'
      MaxLength = 4
      TabOrder = 1
      Text = '-500'
    end
    object cbLeftMouse: TCheckBox
      Left = 159
      Top = 50
      Width = 29
      Height = 17
      Hint = 'Hold left button'
      Caption = 'L'
      TabOrder = 2
    end
    object cbRightMouse: TCheckBox
      Left = 194
      Top = 50
      Width = 29
      Height = 17
      Hint = 'Hold right button'
      Caption = 'R'
      TabOrder = 3
    end
    object btnMouse: TButton
      Left = 159
      Top = 19
      Width = 75
      Height = 25
      Hint = 'Move mouse'
      Caption = 'Move'
      Enabled = False
      TabOrder = 4
      OnClick = btnMouseClick
    end
    object tbMSpeed: TTrackBar
      Left = 3
      Top = 17
      Width = 150
      Height = 24
      Hint = 'Moving speed'
      Min = 3
      Position = 5
      ShowSelRange = False
      TabOrder = 5
    end
  end
  object gbKeyboard: TGroupBox
    Left = 255
    Top = 67
    Width = 237
    Height = 78
    Caption = 'Keyboard'
    TabOrder = 5
    object tbKSpeed: TTrackBar
      Left = 3
      Top = 17
      Width = 150
      Height = 25
      Hint = 'Typing speed'
      Min = 2
      Position = 5
      ShowSelRange = False
      TabOrder = 0
    end
    object btnKeyboard: TButton
      Left = 156
      Top = 17
      Width = 75
      Height = 25
      Hint = 'Type text'
      Caption = 'Type'
      Enabled = False
      TabOrder = 1
      OnClick = btnKeyboardClick
    end
    object edtText: TEdit
      Left = 8
      Top = 48
      Width = 222
      Height = 21
      Hint = 'Typing text'
      TabOrder = 2
      Text = #1057#1098#1077#1096#1100' '#1077#1097#1105' '#1101#1090#1080#1093' '#1084#1103#1075#1082#1080#1093' '#1092#1088#1072#1085#1094#1091#1079#1089#1082#1080#1093' '#1073#1091#1083#1086#1082'_ '#1076#1072' '#1074#1099#1087#1077#1081' '#1078#1077' '#1095#1072#1102'!'
    end
  end
  object mmLog: TMemo
    Left = 8
    Top = 151
    Width = 484
    Height = 138
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object cbTest: TCheckBox
    Left = 424
    Top = 56
    Width = 97
    Height = 17
    Caption = 'cbTest'
    TabOrder = 7
    Visible = False
    OnClick = cbTestClick
  end
  object ComPort: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnAfterOpen = ComPortChangeState
    OnAfterClose = ComPortChangeState
    OnRxChar = ComPortRxChar
    Left = 264
    Top = 8
  end
  object tmrMouse: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrMouseTimer
    Left = 304
    Top = 8
  end
  object tmrKeyBoard: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrKeyBoardTimer
    Left = 344
    Top = 8
  end
  object tmrTest: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = tmrTestTimer
    Left = 424
    Top = 8
  end
end
