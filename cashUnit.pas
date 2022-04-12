unit cashUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin;

type
  TcashForm = class(TForm)
    cashLabel: TLabel;
    Button1: TButton;
    cashEdit: TSpinEdit;
    Button2: TButton;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  cashForm: TcashForm;

implementation

{$R *.dfm}

uses mainUnit;

procedure TcashForm.Button1Click(Sender: TObject);
begin
  mainForm.query.Close;
  mainForm.query.ExecSQL('update settings set cash=' + inttostr(mainForm.cash - cashEdit.Value));

  cashForm.OnShow(Sender);
end;

procedure TcashForm.Button2Click(Sender: TObject);
begin
  mainForm.query.Close;
  mainForm.query.ExecSQL('update settings set cash=0');

  cashForm.OnShow(Sender);
end;

procedure TcashForm.FormShow(Sender: TObject);
begin
  mainForm.query.Close;
  mainForm.query.Open('select * from settings');
  if mainForm.query.RecordCount > 0 then
    begin
      mainForm.cash := mainForm.query.FieldByName('cash').AsInteger;
      cashLabel.Caption := 'На кассе: ' + mainForm.cash.ToString + ' сум';
      cashEdit.MaxValue := mainForm.cash;
      cashEdit.Value := mainForm.cash;
    end
  else
    begin
      showMessage('Ошибка при выполнение комманды.' + #13 + 'Пожалуйста, обращаете к администратору.');
      close();
    end;
end;

end.
