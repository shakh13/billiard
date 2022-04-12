object productsForm: TproductsForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu]
  Caption = #1055#1088#1086#1076#1091#1082#1090#1099
  ClientHeight = 322
  ClientWidth = 485
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
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 10
    Width = 100
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1088#1086#1076#1091#1082#1090#1072
  end
  object Label2: TLabel
    Left = 266
    Top = 10
    Width = 26
    Height = 13
    Caption = #1062#1077#1085#1072
  end
  object Label3: TLabel
    Left = 378
    Top = 10
    Width = 60
    Height = 13
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
  end
  object DBGrid1: TDBGrid
    Left = 10
    Top = 95
    Width = 465
    Height = 217
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
        Title.Alignment = taCenter
        Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1088#1086#1076#1091#1082#1090#1072
        Width = 200
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'price'
        Title.Alignment = taCenter
        Title.Caption = #1062#1077#1085#1072
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'quantity'
        Title.Alignment = taCenter
        Title.Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
        Visible = True
      end>
  end
  object DBNavigator1: TDBNavigator
    Left = 10
    Top = 64
    Width = 460
    Height = 25
    DataSource = DataSource1
    TabOrder = 1
  end
  object DBEdit1: TDBEdit
    Left = 10
    Top = 29
    Width = 241
    Height = 21
    DataField = 'caption'
    DataSource = DataSource1
    TabOrder = 2
  end
  object DBEdit2: TDBEdit
    Left = 266
    Top = 29
    Width = 98
    Height = 21
    DataField = 'price'
    DataSource = DataSource1
    TabOrder = 3
  end
  object DBEdit3: TDBEdit
    Left = 378
    Top = 29
    Width = 97
    Height = 21
    DataField = 'quantity'
    DataSource = DataSource1
    TabOrder = 4
  end
  object DataSource1: TDataSource
    DataSet = FDTable1
    Left = 384
    Top = 176
  end
  object FDTable1: TFDTable
    Active = True
    IndexFieldNames = 'id'
    Connection = mainForm.connection
    UpdateOptions.UpdateTableName = 'products'
    TableName = 'products'
    Left = 344
    Top = 192
  end
end
