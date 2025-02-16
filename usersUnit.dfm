object usersForm: TusersForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu]
  Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
  ClientHeight = 261
  ClientWidth = 303
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
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 15
    Top = 15
    Width = 30
    Height = 13
    Caption = #1051#1086#1075#1080#1085
  end
  object Label2: TLabel
    Left = 15
    Top = 63
    Width = 37
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100
  end
  object DBGrid1: TDBGrid
    Left = 15
    Top = 137
    Width = 273
    Height = 109
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
        FieldName = 'username'
        Title.Caption = #1051#1086#1075#1080#1085
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'password'
        Title.Caption = #1055#1072#1088#1086#1083#1100
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'role'
        PickList.Strings = (
          #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
          #1040#1076#1084#1080#1085)
        Title.Caption = #1040#1076#1084#1080#1085
        Visible = True
      end>
  end
  object DBEdit1: TDBEdit
    Left = 15
    Top = 31
    Width = 121
    Height = 21
    DataField = 'username'
    DataSource = DataSource1
    TabOrder = 1
  end
  object DBEdit2: TDBEdit
    Left = 15
    Top = 79
    Width = 121
    Height = 21
    DataField = 'password'
    DataSource = DataSource1
    TabOrder = 2
  end
  object DBCheckBox1: TDBCheckBox
    Left = 164
    Top = 81
    Width = 121
    Height = 17
    Caption = #1040#1076#1084#1080#1085#1080#1089#1090#1088#1072#1090#1086#1088
    DataField = 'role'
    DataSource = DataSource1
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object DBNavigator1: TDBNavigator
    Left = 15
    Top = 106
    Width = 270
    Height = 25
    DataSource = DataSource1
    TabOrder = 4
  end
  object DataSource1: TDataSource
    DataSet = FDTable1
    Left = 232
    Top = 176
  end
  object FDTable1: TFDTable
    IndexFieldNames = 'id'
    Connection = mainForm.connection
    UpdateOptions.UpdateTableName = 'users'
    TableName = 'users'
    Left = 176
    Top = 176
  end
end
