object cashForm: TcashForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu]
  Caption = #1050#1072#1089#1089#1072
  ClientHeight = 109
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Padding.Left = 15
  Padding.Top = 15
  Padding.Right = 15
  Padding.Bottom = 15
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cashLabel: TLabel
    Left = 15
    Top = 15
    Width = 286
    Height = 23
    Align = alTop
    Alignment = taCenter
    Caption = #1053#1072' '#1082#1072#1089#1089#1077': 0 '#1089#1091#1084
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 135
  end
  object Label2: TLabel
    Left = 18
    Top = 52
    Width = 31
    Height = 13
    Caption = #1057#1091#1084#1084#1072
  end
  object Button1: TButton
    Left = 145
    Top = 69
    Width = 75
    Height = 25
    Caption = #1042#1079#1103#1090#1100
    TabOrder = 1
    OnClick = Button1Click
  end
  object cashEdit: TSpinEdit
    Left = 15
    Top = 71
    Width = 121
    Height = 22
    MaxValue = 5000000
    MinValue = 1
    TabOrder = 0
    Value = 1
  end
  object Button2: TButton
    Left = 226
    Top = 69
    Width = 75
    Height = 25
    Caption = #1042#1079#1103#1090#1100' '#1074#1089#1077
    TabOrder = 2
    OnClick = Button2Click
  end
end
