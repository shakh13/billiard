unit loginUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.DBCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ExtCtrls, System.DateUtils, Vcl.Mask;

type
  TloginForm = class(TForm)
    passwordEdit: TLabeledEdit;
    authButton: TButton;
    Label1: TLabel;
    usernameComboBox: TComboBox;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure authButtonClick(Sender: TObject);
    procedure passwordEditKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LinkLabel1Click(Sender: TObject);
    procedure Label2MouseEnter(Sender: TObject);
    procedure Label2MouseLeave(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { Private declarations }
  public
    loggedIn: Boolean;
    canTerminate: boolean;
  end;

var
  loginForm: TloginForm;

implementation

{$R *.dfm}

uses mainUnit, cashUnit;

procedure TloginForm.authButtonClick(Sender: TObject);
begin
  with mainForm do
    begin
      query.close;
      query.Open('select * from users where username='''+usernameComboBox.Items[usernameComboBox.ItemIndex]+''' and password='''+passwordEdit.Text+'''');
      if query.RecordCount > 0 then
        begin
          userId := query.FieldByName('id').AsString;
          username := query.FieldByName('username').AsString;
          if query.FieldByName('role').AsBoolean then
            begin
              cashMainMenu.Visible := true;
              settingsMainMenu.Visible := true;
              role := 'Админ';
            end
          else
            role := 'Пользователь';

          mainForm.Caption := 'Billiard (' + role + ': ' + username + ')';

          loggedIn := true;
          canTerminate := false;
          mainForm.keyThread.Start;
          mainForm.timer.Enabled := true;
        end
      else
        ShowMessage('Логин или пароль неправильно.');
    end;
end;

procedure TloginForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  loggedIn := true;
end;

procedure TloginForm.FormCreate(Sender: TObject);
var
  I: Integer;
  s, f, p: integer;
begin
  loggedIn := false;
  canTerminate := true;
  mainForm.query.Close;
  mainForm.query.Open('select * from users order by username desc');
  if mainForm.query.RecordCount > 0 then
    begin
      usernameComboBox.Clear;
      for I := 0 to mainForm.query.RecordCount - 1 do
        begin
          usernameComboBox.Items.Add(mainForm.query.FieldByName('username').AsString);
          mainForm.query.Next;
        end;
      usernameComboBox.ItemIndex := 0;
    end
  else
    begin
      showMessage('Обратите к создателю!' + #13 + 'Шахзод Саидмуродов.' + #13 + '+998 90 906006960');
      loggedIn := true;
      canTerminate := true;
    end;


  mainForm.historyList.Clear;
  mainForm.query.Close;
  mainForm.query.Open('select machines.caption caption, machines.price price, timer.created_at created_at, timer.until_time until_time, timer.id as timer_id  from timer inner join machines on machines.id=timer.machine_id and timer.status=0 and timer.until_time<=' + IntToStr(DateTimeToUnix(Now)) + ' and timer.until_time > 0 order by timer.id desc');
  if mainForm.query.RecordCount > 0 then
    begin
      for I := 1 to mainForm.query.RecordCount do
        begin
          s := mainForm.query.FieldByName('created_at').AsInteger;
          f := mainForm.query.FieldByName('until_time').AsInteger;
          p := mainForm.query.FieldByName('price').AsInteger;

          mainForm.historyList.Items.Add(mainForm.query.FieldByName('caption').AsString + ': '
            + inttostr(round(abs(f - s) / 3600 * p) + cashForm.productsPriceByTimerId(mainForm.query.FieldByName('timer_id').AsInteger)) + ' - '
            + DateTimeToStr(UnixToDateTime(s)));

          mainForm.query.Next;
        end;
    end;
end;

procedure TloginForm.Label2Click(Sender: TObject);
begin
  showMessage('Шахзод 906006960');
end;

procedure TloginForm.Label2MouseEnter(Sender: TObject);
begin
  label2.Font.Style := [fsUnderline];
end;

procedure TloginForm.Label2MouseLeave(Sender: TObject);
begin
  label2.Font.Style := [];
end;

procedure TloginForm.LinkLabel1Click(Sender: TObject);
begin
  showMessage('Шахзод 906006960');
end;

procedure TloginForm.passwordEditKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    authButton.Click;
end;

end.
