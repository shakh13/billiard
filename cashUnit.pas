﻿unit cashUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, System.DateUtils;

type
  TcashForm = class(TForm)
    cashListBox: TListBox;
    procedure FormShow(Sender: TObject);
    procedure cashListBoxDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  private

  public
    function productsPriceByTimerId(timerId: integer): integer;
  end;

var
  cashForm: TcashForm;

implementation

{$R *.dfm}

uses mainUnit;

procedure TcashForm.cashListBoxDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  lb: TListbox;
  s: string;
  hasLine: boolean;

begin
  lb := Control as TListbox;
  s := lb.Items[Index];
  hasLine := (s <> '') and (s[1] = '-');

  lb.ItemHeight := 24;

  lb.Canvas.Brush.Style := bsSolid;
  lb.Canvas.Font.Assign(lb.Font);
  lb.Canvas.Font.Size := 12;

  lb.Canvas.FillRect(ARect);

  if hasLine then
    begin
      Delete(s, 1, 1);
      lb.Canvas.Pen.Style := psSolid;
      lb.Canvas.Pen.Color := clWindowText;
      lb.Canvas.Font.Style := [fsBold];
      lb.Canvas.MoveTo(ARect.Left + lb.Canvas.TextWidth(s) + 10, ARect.Top + 12);
      lb.Canvas.LineTo(ARect.Right - 10, ARect.Top + 12);
      lb.Canvas.TextOut(ARect.Left + 5, (ARect.Top + ARect.Bottom - lb.Canvas.TextHeight('Tg')) div 2, s);
    end
  else
    begin
      lb.Canvas.Brush.Style := bsClear;
      lb.Canvas.Font.Style := [];
      lb.Canvas.Pen.Color := clWindowText;
      lb.Canvas.TextOut(ARect.Left + 15, (ARect.Top + ARect.Bottom - lb.Canvas.TextHeight('Tg')) div 2, s);
    end;
end;

procedure TcashForm.FormShow(Sender: TObject);
var
  productsPrice: integer;
  summa, timerPrice: integer;
  items: TStringList;
  startTime, endTime, username: String;
begin
  cashListBox.Clear;
  items := TStringList.Create;

  with mainForm do
    begin
      freeQuery.Close;
      freeQuery.Open('select cash.*, users.username from cash inner join users  on (cash.end_time>0 and users.id=cash.user_id) order by cash.start_time desc');
      if freeQuery.RecordCount > 0 then
        begin
          freeQuery.First;

          while not freeQuery.Eof do
            begin
              items.Clear;
              summa := 0;
              startTime := freeQuery.FieldByName('start_time').AsString;
              endTime := freeQuery.FieldByName('end_time').AsString;
              username := freeQuery.FieldByName('username').AsString;

              query.Close;
              query.Open('select timer.*, (ABS(timer.until_time - timer.created_at) * machines.price / 3600) as price, machines.caption from timer inner join machines on (machines.id=timer.machine_id and timer.created_at >= '+startTime+' and timer.created_at <= '+endTime+')');
              if query.RecordCount > 0 then
                begin
                  while not query.Eof do
                    begin
                      productsPrice := productsPriceByTimerId(query.FieldByName('id').AsInteger);
                      timerPrice := query.FieldByName('price').AsInteger;
                      summa := summa + timerPrice + productsPrice;

                      items.Add(
                        dateTimeToStr(UnixToDateTime(query.FieldByName('created_at').AsInteger))
                        + ': "'
                        + query.FieldByName('caption').AsString
                        + '" '
                        + timerPrice.ToString
                        + ' сум Продукты: '
                        + productsPrice.ToString
                        + ' сум Итого: '
                        + inttostr(productsPrice + timerPrice)
                        + ' сум'
                      );

                      query.Next;
                    end;
                end;

              cashListBox.Items.Add(
                '-'
                + dateTimeToStr(UnixToDateTime(startTime.ToInteger))
                + ' - '
                + dateTimeToStr(UnixToDateTime(endTime.ToInteger))
                + ': '
                + username
                + ' '
                + summa.ToString
                );
              cashListBox.Items.AddStrings(items);

              freeQuery.Next;
            end;

        end
      else
        begin
          cashListBox.Items.Add('-Пусто');
        end;
    end;
end;

function TcashForm.productsPriceByTimerId(timerId: integer): integer;
begin
  with mainForm do
    begin
      timerQuery.Close;
      timerQuery.Open('select SUM(price) as price from (select shop.timer_id, shop.quantity * products.price as price from shop inner join products on (shop.product_id = products.id)) s where s.timer_id=' + timerId.toString);
      if query.RecordCount > 0 then
        begin
          try
            result := timerQuery.FieldByName('price').AsInteger;
          except
            result := 0;
          end;
        end;
    end;
end;

end.
