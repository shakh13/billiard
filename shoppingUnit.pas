unit shoppingUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.DBCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Samples.Spin, System.DateUtils;

type
  TshoppingForm = class(TForm)
    sg: TStringGrid;
    shoppingPanel: TPanel;
    FDTable1: TFDTable;
    DataSource1: TDataSource;
    DBLookupListBox1: TDBLookupListBox;
    quantityEdit: TSpinEdit;
    Label1: TLabel;
    DBText1: TDBText;
    Label2: TLabel;
    Label3: TLabel;
    DBText2: TDBText;
    buyButton: TButton;
    DBText3: TDBText;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DBLookupListBox1Click(Sender: TObject);
    procedure buyButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    is_shopping: boolean; // true - show current timer shopping history and shop
                          // false - show all shopping history of this machine
    machine_caption: string;
    timer_id: string;     // required if is_shopping=true
    machine_id: string;
  end;

var
  shoppingForm: TshoppingForm;

implementation

{$R *.dfm}

uses mainUnit;

procedure TshoppingForm.buyButtonClick(Sender: TObject);
begin
  if (quantityEdit.Value > 0) and (quantityEdit.Value <= dataSource1.DataSet.FieldByName('quantity').AsInteger) then
    begin
      FDTable1.CachedUpdates := true;
      mainForm.query.Close;
      mainForm.query.ExecSQL('insert into shop (timer_id, user_id, product_id, quantity, created_at) values ('+timer_id+', '+mainForm.userId+', '+dataSource1.DataSet.FieldByName('id').AsString+', '+quantityEdit.Value.ToString+', '+DateTimeToUnix(now).ToString+')');
      mainForm.query.Close;
      mainForm.query.ExecSQL('update products set quantity='+inttostr(dataSource1.DataSet.FieldByName('quantity').AsInteger - quantityEdit.Value)+' where id=' + dataSource1.DataSet.FieldByName('id').AsString);
      FDTable1.CommitUpdates;

      shoppingForm.OnShow(Sender);
    end;
end;

procedure TshoppingForm.DBLookupListBox1Click(Sender: TObject);
begin
  quantityEdit.MaxValue := DataSource1.DataSet.FieldByName('quantity').AsInteger;
  if DataSource1.DataSet.FieldByName('quantity').AsInteger > 0 then
    begin
      quantityEdit.Value := 1;
      buyButton.Enabled := true;
    end
  else
    begin
      quantityEdit.Value := 0;
      buyButton.Enabled := false;
    end;
end;

procedure TshoppingForm.FormCreate(Sender: TObject);
begin
  sg.ColWidths[0] := 70;
  sg.ColWidths[1] := 130;
  sg.ColWidths[2] := 80;
  sg.ColWidths[3] := 50;
  sg.ColWidths[4] := 70;
  sg.ColWidths[5] := 110;

  sg.Cells[0, 0] := 'ID';
  sg.Cells[1, 0] := 'Нахвание';
  sg.Cells[2, 0] := 'Пользователь';
  sg.Cells[3, 0] := 'Количество';
  sg.Cells[4, 0] := 'Цена';
  sg.Cells[5, 0] := 'Добавлено';
end;

procedure TshoppingForm.FormShow(Sender: TObject);
var
  I: Integer;
begin
  caption := machine_caption + ' - Магазин';
  mainForm.query.Close;

  shoppingPanel.Visible := is_shopping;

  FDTable1.Active := false;
  FDTable1.Active := true;

  quantityEdit.MaxValue := dataSource1.DataSet.FieldByName('quantity').AsInteger;
  quantityEdit.Value := 1;

  if is_shopping then
    begin
      mainForm.query.Open('select shop.id id, products.caption caption, users.username username, shop.quantity quantity, products.price price, shop.created_at created_at from shop inner join products, users on shop.user_id=users.id and shop.product_id=products.id and shop.timer_id=' + timer_id + ' order by shop.id');

      Width := 790;
    end
  else
    begin
      mainForm.query.SQL.Clear;
      mainForm.query.SQL.Add('select shop.id id, products.caption caption, users.username username, shop.quantity quantity, products.price price, shop.created_at created_at from shop');
      mainForm.query.SQL.Add(' inner join products, timer, users on shop.user_id=users.id and shop.timer_id=timer.id and shop.product_id=products.id and timer.machine_id='+machine_id);
      mainForm.query.SQL.Add(' order by shop.id desc');
      mainForm.query.Open;

      Width := 580;
    end;

  sg.RowCount := mainForm.query.RecordCount + 1;
  if sg.RowCount > 1 then
    sg.FixedRows := 1;
  for I := 1 to mainForm.query.RecordCount do
    begin
      sg.Cells[0, i] := mainForm.query.FieldByName('id').AsString;
      sg.Cells[1, i] := mainForm.query.FieldByName('caption').AsString;
      sg.Cells[2, i] := mainForm.query.FieldByName('username').AsString;
      sg.Cells[3, i] := mainForm.query.FieldByName('quantity').AsString;
      sg.Cells[4, i] := inttostr(mainForm.query.FieldByName('price').AsInteger * mainForm.query.FieldByName('quantity').AsInteger);
      sg.Cells[5, i] := DateTimeToStr(UnixToDateTime(mainForm.query.FieldByName('created_at').AsInteger));

      mainForm.query.Next;
    end;

end;

end.
