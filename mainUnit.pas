﻿unit mainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleServer, Vcl.CmAdmCtl, Vcl.StdCtrls, registry, IdThreadComponent, IdBaseComponent, CPort,
  CPortCtl, Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, Vcl.Menus, shellapi, FireDAC.Comp.UI,
  Vcl.Imaging.pngimage, Vcl.ComCtrls, System.ImageList, Vcl.ImgList, Vcl.ToolWin,
  Vcl.Buttons, Vcl.WinXCtrls, Vcl.Grids, DateUtils, Math, Printers;

type
  TmainForm = class(TForm)
    keyThread: TIdThreadComponent;
    ComPort: TComPort;
    connection: TFDConnection;
    query: TFDQuery;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    settingsMainMenu: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    N9: TMenuItem;
    cashMainMenu: TMenuItem;
    N2: TMenuItem;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    PopupMenu: TPopupMenu;
    ToolBar1: TToolBar;
    comportStatusImage: TImage;
    stopButton: TSpeedButton;
    sg: TStringGrid;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    N6: TMenuItem;
    timerQuery: TFDQuery;
    historyList: TListBox;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    timer: TTimer;
    freeQuery: TFDQuery;
    ImageList1: TImageList;
    N10: TMenuItem;
    PrintDialog: TPrintDialog;
    cashOpenClose: TSpeedButton;
    procedure ComPortException(Sender: TObject; TComException: TComExceptions;
      ComportMessage: string; WinError: Int64; WinMessage: string);
    procedure keyThreadRun(Sender: TIdThreadComponent);
    procedure FormCreate(Sender: TObject);
    procedure ComPortAfterOpen(Sender: TObject);
    procedure ComPortAfterClose(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N5Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure sgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure sgDblClick(Sender: TObject);
    procedure stopButtonClick(Sender: TObject);
    procedure cashMainMenuClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure ComPortError(Sender: TObject; Errors: TComErrors);
    procedure timerTimer(Sender: TObject);
    procedure cashOpenCloseClick(Sender: TObject);
  private
    procedure turnLED(port: String; val: integer);
    procedure onPopupClick(Sender: TObject);
  public
    userId: String;
    username: String;
    role: String;
    machine_ids: TStringList;
    machine_ports: TStringList;
    machine_prices: TStringList;

    function getCashStatus: boolean;
    function isRunningMachine: boolean;


  end;

const
  led_on = 1;
  led_off = 0;
  tag_stop = 0;
  tag_vip = 1;
  tag_time = 2;
  tag_shop = 3;
  tag_move = 4;

var
  reg: TRegistry;
  deviceConnected: Boolean;
  mainForm: TmainForm;

implementation

{$R *.dfm}

uses loginUnit, machinesUnit, cashUnit, usersUnit, productsUnit,
  shoppingUnit, printerUnit;


procedure TmainForm.cashMainMenuClick(Sender: TObject);
begin
  if role = 'Админ' then
    cashForm.ShowModal;
end;

procedure TmainForm.cashOpenCloseClick(Sender: TObject);
var
  current_timestamp: integer;
begin
  if getCashStatus then
    begin
      // cash is open; close cash
      if isRunningMachine then
        begin
          showMessage('Сначало отключите все столы');
        end
      else
        begin
          current_timestamp := DateTimeToUnix(Now);
          freeQuery.Close;
          freeQuery.ExecSQL('update cash set end_time='+current_timestamp.ToString+' where end_time=0');
          sg.visible := false;
          cashOpenClose.Caption := 'Открыть кассу';
        end;
    end
  else
    begin
      // cash is closed; open cash
      current_timestamp := DateTimeToUnix(Now);
      freeQuery.Close;
      freeQuery.ExecSQL('insert into cash (user_id, start_time) values ('+userId+', '+current_timestamp.ToString+')');
      sg.visible := true;
      cashOpenClose.Caption := 'Закрыть кассу';
    end;
end;

procedure TmainForm.ComPortAfterClose(Sender: TObject);
begin
  comportStatusImage.Picture.LoadFromFile('images\disconnected.png');
end;

procedure TmainForm.ComPortAfterOpen(Sender: TObject);
begin
  comportStatusImage.Picture.LoadFromFile('images\connected.png');
end;

procedure TmainForm.ComPortError(Sender: TObject; Errors: TComErrors);
begin
  errors := [];
end;

procedure TmainForm.ComPortException(Sender: TObject;
  TComException: TComExceptions; ComportMessage: string; WinError: Int64;
  WinMessage: string);
begin
  //TComException := CEPortNotOpen;
  WinError := 0;
end;

procedure TmainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  keyThread.Free;
  timer.Free;

  timerQuery.Close;
  query.Close;
  freeQuery.Close;

  connection.Close;

  reg.Free;
  comport.Free;
  machine_ids.Free;
  machine_ports.Free;
  machine_prices.Free;
end;

procedure TmainForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  reg := TRegistry.Create;
  try
    connection.Params.Database := extractfilepath(paramstr(0)) + '\db.db';
    connection.Connected := true;
    connection.Open;
  except
    ShowMessage('Ошибка' + #13 + 'База данных не найдено');
    close();
  end;

  sg.Cells[0, 0] := 'Название';
  sg.Cells[1, 0] := 'Начало';
  sg.Cells[2, 0] := 'Время';
  sg.Cells[3, 0] := 'Осталось';
  sg.Cells[4, 0] := 'Цена';
  sg.Cells[5, 0] := 'Покупки';
  sg.Cells[6, 0] := 'Итого';

  query.Close;
  query.Open('select * from machines where status=1 order by caption');
  sg.RowCount := query.RecordCount + 1;
  machine_ids := TStringList.Create;
  machine_ports := TStringList.Create;
  machine_prices := TStringList.Create;
  if query.RecordCount > 0 then
    begin
      sg.FixedRows := 1;
      for I := 1 to query.RecordCount do
        begin
          sg.Cells[0, i] := query.FieldByName('caption').AsString;
          machine_ids.Add(query.FieldByName('id').AsString);
          machine_ports.Add(query.FieldByName('port').AsString);
          machine_prices.Add(query.FieldByName('price').AsString);
          query.Next;
        end;
    end;

  if getCashStatus then
    begin
      sg.visible := true;
      cashOpenClose.Caption := 'Закрыть кассу';
    end
  else
    begin
      sg.visible := false;
      cashOpenClose.Caption := 'Открыть кассу';
    end;

end;


procedure TmainForm.FormResize(Sender: TObject);
begin
  if width > 720 then
    begin
      sg.ColWidths[0] := round((sg.Width - 30) * 0.13);
      sg.ColWidths[1] := round((sg.Width - 30) * 0.20);
      sg.ColWidths[2] := round((sg.Width - 30) * 0.15);
      sg.ColWidths[3] := round((sg.Width - 30) * 0.15);
      sg.ColWidths[4] := round((sg.Width - 30) * 0.12);
      sg.ColWidths[5] := round((sg.Width - 30) * 0.12);
      sg.ColWidths[6] := round((sg.Width - 30) * 0.13);
    end;
end;

function TmainForm.getCashStatus: boolean;
begin
  freeQuery.Close;
  freeQuery.Open('select * from cash where end_time=0');
  result := freeQuery.RecordCount > 0;
end;

function TmainForm.isRunningMachine: boolean;
begin
  freeQuery.Close;
  freeQuery.Open('select * from timer where status=1');
  result := freeQuery.RecordCount > 0;
end;

procedure TmainForm.N2Click(Sender: TObject);
begin
  if role = 'Админ' then
    usersForm.ShowModal;
end;

procedure TmainForm.N3Click(Sender: TObject);
begin
  hide;
  ShellExecute(handle, 'open', pchar(paramstr(0)), '', '', sw_show);
  close;
end;

procedure TmainForm.N5Click(Sender: TObject);
begin
  close;
end;

procedure TmainForm.N6Click(Sender: TObject);
begin
  showMessage('Шахзод Саидмуродов' + #13 + 'Тел: +998 90 6006960' + #13 + 'Instagram: @shakh_developer');
end;

procedure TmainForm.N7Click(Sender: TObject);
begin
  if role = 'Админ' then
    machinesForm.ShowModal;
end;


procedure TmainForm.N9Click(Sender: TObject);
begin
  if role = 'Админ' then
    begin
      productsForm.ShowModal;
    end;
end;

procedure TmainForm.onPopupClick(Sender: TObject);
var
  item: TMenuItem;
  machine_id: string;
  machine_hour_price: integer;
  current_timestamp: integer;
  until_time: integer;
  row: integer;
  cap: String;
  I: Integer;
begin
  item := Sender as TMenuItem;

  machine_id := machine_ids[sg.Row - 1];
  machine_hour_price := machine_prices[sg.Row - 1].ToInteger;
  current_timestamp := DateTimeToUnix(Now);
  case item.Tag of
    tag_vip: begin
      Query.Close;
      Query.ExecSQL('insert into timer (machine_id, user_id, status, created_at) values ('+machine_id+','+userId+', ''1'', '+current_timestamp.ToString+')');
    end;
    tag_stop: begin
      Query.Close;
      Query.ExecSQL('update timer set until_time=' + current_timestamp.ToString + ' where machine_id=' + machine_id + ' and status=1');
    end;
    tag_time: begin
      until_time := current_timestamp + round(item.Caption.ToInteger * 3600 / machine_hour_price);
      Query.Close;
      Query.ExecSQL('insert into timer (machine_id, user_id, is_vip, until_time, status, created_at) values ('+machine_id+','+userId+', 0, '+until_time.ToString+', ''1'', '+current_timestamp.ToString+')');
    end;
    tag_move: begin
      // find machine_id by caption
      cap := item.Caption;
      row := 0;
      for I := 1 to sg.RowCount - 1 do
        if sg.Cells[0, i] = cap then
          row := i;

      if row > 0 then
        begin
          Query.Close;
          Query.ExecSQL('update timer set machine_id='+machine_ids[row - 1] + ' where machine_id='+machine_ids[sg.Row - 1] + ' and status=1');
        end;
    end;
    tag_shop: begin
      sg.OnDblClick(Sender);
    end;
  end;

  timer.Enabled := false;
  timer.Enabled := true;
end;

procedure TmainForm.sgContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  stopItem: TMenuItem;
  activateVipItem: TMenuItem;
  activateTimeItem: TMenuItem;
  shopItem: TMenuITem;
  timeItem: TMenuItem;
  moveMenuItem: TMenuItem;
  moveItem: TMenuItem;
  machine_id: string;
  I: Integer;
  isEmptyMachine: Boolean;
begin
  machine_id := machine_ids[sg.Row - 1];

  try
    PopupMenu.Items.Clear;
    query.Close;
    query.Open('select * from timer where status=1 and machine_id=' + machine_id);
    if query.RecordCount > 0 then
      begin
        stopItem := TMenuItem.Create(PopupMenu);
        stopItem.Caption := 'Стоп';
        stopItem.Tag := tag_stop;
        stopItem.OnClick := onPopupClick;
        PopupMenu.Items.Add(stopItem);

        moveMenuItem := TMenuItem.Create(popupMenu);
        moveMenuItem.Caption := 'Переместить на';

        isEmptyMachine := false;
        query.Close;
        query.Open('select * from machines where id <> ' + machine_id);
        for I := 1 to query.RecordCount do
          begin
            freeQuery.Close;
            freeQuery.Open('select * from timer where status=1 and machine_id=' + query.FieldByName('id').AsString);
            if freeQuery.RecordCount = 0 then
              begin
                isEmptyMachine := true;
                moveItem := TMenuItem.Create(popupMenu);
                moveItem.Caption := query.FieldByName('caption').AsWideString;
                moveItem.Tag := tag_move;
                moveItem.OnClick := onPopupClick;

                moveMenuItem.Add(moveItem);
              end;
            query.Next;
          end;

        if isEmptyMachine then
          popupMenu.Items.Add(moveMenuItem);

        shopItem := TMenuItem.Create(PopupMenu);
        shopItem.Caption := 'Магазин';
        shopItem.Tag := tag_shop;
        shopItem.OnClick := onPopupClick;
        PopupMenu.Items.Add(shopItem);
      end
    else
      begin
        activateVipItem := TMenuItem.Create(popupMenu);
        activateVipItem.Caption := 'VIP';
        activateVipItem.Tag := tag_vip;
        activateVipItem.OnClick := onPopupClick;
        PopupMenu.Items.Add(activateVipItem);

        query.Close;
        query.Open('select * from times order by value');
        if query.RecordCount > 0 then
          begin
            activateTimeItem := TMenuItem.Create(popupMenu);
            activateTimeItem.Caption := 'Активировать на';
            PopupMenu.Items.Add(activateTimeItem);

            for I := 1 to query.RecordCount do
              begin
                timeItem := TMenuItem.Create(popupMenu);
                timeItem.Caption := query.FieldByName('value').AsString;
                timeItem.Tag := tag_time;
                timeItem.OnClick := onPopupClick;

                activateTimeItem.Add(timeItem);

                query.Next;
              end;
          end;
      end;
  except

  end;

end;

procedure TmainForm.sgDblClick(Sender: TObject);
var
  machine_id: String;
begin
  // show all of machine -------------------------------------------------------
  // - shop
  // - history

  machine_id := machine_ids[sg.Row - 1];
  shoppingForm.machine_id := machine_id;
  shoppingForm.machine_caption := sg.Cells[0, sg.Row];

  query.Close;
  query.Open('select * from timer where status=1 and machine_id=' + machine_id);
  if query.RecordCount > 0 then
    begin
      // time is going
      // show current timer shoppings
      // shopping

      shoppingForm.is_shopping := true;
      shoppingForm.timer_id := query.FieldByName('id').AsString;
    end
  else
    begin
      // time is not going
      // show all shopping history for this machine

      shoppingForm.is_shopping := false;
    end;

  shoppingForm.ShowModal();
end;

procedure TmainForm.sgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  machine_id: string;
begin
  if Button = TMouseButton.mbRight then
    begin
      sg.Perform(WM_LBUTTONDOWN, 0, MakeLParam(Word(X), Word(Y)));
    end;

  if Button = TMouseButton.mbLeft then
    begin
      if sg.Row > 0 then
        begin
          machine_id := machine_ids[sg.Row - 1];

          freeQuery.Close;
          freeQuery.Open('select * from timer where status=1 and machine_id=' + machine_id);
          if freeQuery.RecordCount > 0 then
            begin
              stopButton.Enabled := true;
            end
          else
            begin
              stopButton.Enabled := false;
            end;
        end;
    end;
end;

procedure TmainForm.stopButtonClick(Sender: TObject);
var
  machine_id: string;
  timer_id: string;
begin
  stopButton.Enabled := false;
  if sg.Row > 0 then
    begin
      machine_id := machine_ids[sg.Row - 1];
      freeQuery.Close;
      freeQuery.Open('select * from timer where status=1 and machine_id=' + machine_id);
      if freeQuery.RecordCount > 0 then
        begin
          timer_id := freeQuery.FieldByName('id').AsString;
          freeQuery.Close;
          freeQuery.ExecSQL('update timer set until_time=' + inttostr(DateTimeToUnix(now)) + ' where id=' + timer_id);
        end;
     end;
end;

procedure TmainForm.keyThreadRun(Sender: TIdThreadComponent);
var
  names: TStringList;
  i: integer;
  comportFound: Boolean;
  data: String;
begin
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
      if reg.OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM') then
      begin
        Names := TStringList.Create;
        try
          reg.GetValueNames(Names);

          if not comport.Connected then
            begin
              deviceConnected := false;
              for I := 0 to names.Count - 1 do
                begin
                  try
                    comport.Close;
                    comport.Port := reg.ReadString(names[i]);
                    comport.Open;

                    comport.WriteStr('whois,0'+#13#10);

                    application.ProcessMessages;
                    sleep(100);
                    application.ProcessMessages;

                    comport.ReadStr(data, comport.InputCount);
                    data := data.Remove(data.Length - 2, 2);
                    if data = 'controller' then
                      begin
                        deviceConnected := true;
                      end;
                  except

                  end;
                end;
            end
          else
            begin
              comportFound := false;

              for i := 0 to Names.Count - 1 do
                begin
                  if reg.ReadString(Names[i]) = comport.Port then
                    comportFound := true;
                end;

              if not comportFound then
                comport.Close;
            end;
        finally
          Names.Free;
        end
      end;
  finally

  end;

  sleep(500);
end;

procedure TmainForm.timerTimer(Sender: TObject);
var
  row: Integer;
  machine_caption: String;
  machine_id: String;
  machine_port: String;
  machine_hour_price: integer;
  current_timestamp: int64;
  timer_id: String;
  started, finished, sum: integer;
  msg: String;
  buttonCaptions: array [0..2] of String;
  itogo: real;
  print: TPrint;
  timePrice: real;
  items: TStringList;
  st, et: string;
  I: Integer;

begin
  for row := 1 to sg.RowCount - 1 do
    begin
      machine_caption := sg.Cells[0, row];
      machine_id := machine_ids[row - 1];
      machine_port := machine_ports[row - 1];
      machine_hour_price := machine_prices[row - 1].ToInteger;
      current_timestamp := DateTimeToUnix(now);
      st := sg.Cells[1, row];
      et := sg.Cells[2, row];
      // check is finished time
      timerQuery.Close;
      timerQuery.Open('select * from timer where machine_id=' + machine_id + ' and until_time<=' + IntToStr(current_timestamp) + ' and until_time > 0 and status=1');
      if timerQuery.RecordCount > 0 then
        begin
          timer_id := timerQuery.FieldByName('id').AsString;
          started := timerQuery.FieldByName('created_at').AsInteger;
          finished := timerQuery.FieldByName('until_time').AsInteger;
          sum := round(abs(finished - started) / 3600 * machine_hour_price);

          timePrice := sum;

          // turn LED OFF
          turnLED(machine_port, led_off);

          // delete timer
          timerQuery.Close;
          timerQuery.ExecSQL('update timer set status=0 where id=' + timer_id);
          // end delete

          msg := machine_caption  + #13#10 + 'Время: ' + inttostr(sum) + #13#10;

          items := TStringlist.Create;

          // add shopping list
          query.Close;
          query.SQL.Clear;
          query.SQL.Add('select products.caption, sum(shop.quantity) quantity, products.price, products.price*sum(shop.quantity) ap from shop inner join products on products.id=shop.product_id and shop.timer_id='+timer_id+' group by shop.product_id');
          query.Open;
          if query.RecordCount > 0 then
            begin
              for I := 1 to query.RecordCount do
                begin
                  items.Add(query.FieldByName('caption').AsString
                    + ': ' + query.FieldByName('quantity').AsString
                    + 'x' + query.FieldByName('price').AsString
                    + '     ' + query.FieldByName('ap').AsString);

                  msg := msg
                    + query.FieldByName('caption').AsString
                    + ': ' + query.FieldByName('quantity').AsString
                    + 'x' + query.FieldByName('price').AsString
                    + '          ' + query.FieldByName('ap').AsString + #13#10;
                  sum := sum + query.FieldByName('ap').AsInteger;
                  query.Next;
                end;
            end;

          historyList.Items.Insert(0, machine_caption + ': ' + sum.ToString + ' - ' + dateTimeToStr(UnixToDateTime(started)));


          buttonCaptions[0] := 'Печать';
          buttonCaptions[1] := 'Закрыть';

          case MessageDlg(
            msg + #13#10 + '-------------------' + #13#10 + 'Итого:     ' + IntToStr(sum) + ' СУМ',
            TMsgDlgType.mtConfirmation,
            [TMsgDlgBtn.mbAll, TMsgDlgBtn.mbClose],
            0,
            TMsgDlgBtn.mbClose,
            buttonCaptions
          ) of
            12: begin // Print
              try
                print := TPrint.Create;
                print.printCheck(sum, timePrice, st, et, items);
              except
                continue;
              end;
            end;
            8: begin  // Close

            end;
          end;

          items.Free;


          // Application.MessageBox(pchar(msg + #13#10 + '-------------------' + #13#10 + 'Èòîãî:     ' + IntToStr(sum) + ' ñóì'), 'Âðåìÿ', MB_OK);


        end;
      // end check
      current_timestamp := DateTimeToUnix(now);

      timerQuery.Close;
      timerQuery.Open('select * from timer where machine_id='+machine_id+' and status=1');

      if timerQuery.RecordCount > 0 then
        begin
          turnLED(machine_port, led_on);
          started := timerQuery.FieldByName('created_at').AsInteger;

          sum := round(abs(current_timestamp - started) / 3600 * machine_hour_price);

          sg.Cells[1, row] := DateTimeToStr(UnixToDateTime(started));
          sg.Cells[2, row] := FormatDateTime('hh:nn:ss', (current_timestamp - started) / 86400);
          sg.Cells[4, row] := sum.ToString;

          if timerQuery.FieldByName('is_vip').AsBoolean then
            begin
              sg.Cells[3, row] := 'VIP';
            end
          else
            begin
              sg.Cells[3, row] := FormatDateTime('hh:nn:ss', (timerQuery.FieldByName('until_time').AsInteger - current_timestamp) / 86400);
            end;

          try
            query.Close;
            query.SQL.Clear;
            query.SQL.Add('select sum(s.price) price from (select sum(shop.quantity) * products.price as price from shop inner join products on products.id=shop.product_id');
            query.SQL.Add(' where shop.timer_id='+timerQuery.FieldByName('id').AsString+' group by shop.product_id) s');
            query.Open;
            if query.RecordCount > 0 then
              begin
                if query.FieldByName('price').AsString <> '' then
                  begin
                    sg.Cells[5, row] := query.FieldByName('price').AsString;
                    sum := sum + query.FieldByName('price').AsInteger;
                  end
                else
                  sg.Cells[5, row] := '0';
              end
            else
              begin
                sg.Cells[5, row] := '0';
              end;

          except
            on e: Exception do
              StatusBar1.SimpleText := e.ToString;
          end;


          sg.Cells[6, row] := sum.ToString;
        end
      else
        begin
          turnLED(machine_port, led_off);
          sg.Cells[1, row] := '-';
          sg.Cells[2, row] := '-';
          sg.Cells[3, row] := '-';
          sg.Cells[4, row] := '-';
          sg.Cells[5, row] := '-';
          sg.Cells[6, row] := '-';
        end;
    end;
end;

procedure TmainForm.turnLED(port: String; val: integer);
begin
  try
    comport.WriteStr(port + ',' + val.ToString + #13#10);
  except

  end;
end;

end.
