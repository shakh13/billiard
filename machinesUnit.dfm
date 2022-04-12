object machinesForm: TmachinesForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu]
  Caption = #1057#1090#1086#1083#1099
  ClientHeight = 311
  ClientWidth = 365
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Padding.Left = 10
  Padding.Top = 10
  Padding.Right = 10
  Padding.Bottom = 10
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 13
    Width = 48
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077
  end
  object Label2: TLabel
    Left = 35
    Top = 37
    Width = 25
    Height = 13
    Caption = #1055#1086#1088#1090
  end
  object Label3: TLabel
    Left = 227
    Top = 37
    Width = 26
    Height = 13
    Caption = #1062#1077#1085#1072
  end
  object SpeedButton1: TSpeedButton
    Left = 144
    Top = 176
    Width = 23
    Height = 22
  end
  object DBGrid1: TDBGrid
    Left = 10
    Top = 92
    Width = 345
    Height = 209
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'caption'
        ImeName = 'Russian'
        Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'port'
        Title.Caption = #1055#1086#1088#1090
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'price'
        Title.Caption = #1062#1077#1085#1072
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'status'
        Title.Caption = #1057#1090#1072#1090#1091#1089
        Width = 55
        Visible = True
      end>
  end
  object DBEdit1: TDBEdit
    Left = 66
    Top = 10
    Width = 121
    Height = 21
    DataField = 'caption'
    DataSource = DataSource1
    TabOrder = 1
  end
  object DBEdit2: TDBEdit
    Left = 66
    Top = 34
    Width = 121
    Height = 21
    DataField = 'port'
    DataSource = DataSource1
    TabOrder = 2
  end
  object DBCheckBox1: TDBCheckBox
    Left = 218
    Top = 10
    Width = 97
    Height = 17
    Caption = #1057#1090#1072#1090#1091#1089
    DataField = 'status'
    DataSource = DataSource1
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object DBNavigator1: TDBNavigator
    Left = 10
    Top = 61
    Width = 340
    Height = 25
    DataSource = DataSource1
    TabOrder = 4
  end
  object DBEdit3: TDBEdit
    Left = 259
    Top = 34
    Width = 96
    Height = 21
    DataField = 'price'
    DataSource = DataSource1
    TabOrder = 5
  end
  object FDTable1: TFDTable
    Active = True
    IndexFieldNames = 'caption;port;price;status'
    DetailFields = 'caption;port;price;status'
    Connection = mainForm.connection
    UpdateOptions.UpdateTableName = 'machines'
    Exclusive = True
    TableName = 'machines'
    Left = 120
    Top = 152
  end
  object DataSource1: TDataSource
    DataSet = FDTable1
    Left = 208
    Top = 168
  end
end
