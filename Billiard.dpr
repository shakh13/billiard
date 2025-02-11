program Billiard;

uses
  Vcl.Forms,
  mainUnit in 'mainUnit.pas' {mainForm},
  loginUnit in 'loginUnit.pas' {loginForm},
  Vcl.Themes,
  Vcl.Styles,
  machinesUnit in 'machinesUnit.pas' {machinesForm},
  cashUnit in 'cashUnit.pas' {cashForm},
  usersUnit in 'usersUnit.pas' {usersForm},
  productsUnit in 'productsUnit.pas' {productsForm},
  shoppingUnit in 'shoppingUnit.pas' {shoppingForm},
  printerUnit in 'printerUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TmainForm, mainForm);
  Application.CreateForm(TloginForm, loginForm);
  Application.CreateForm(TmachinesForm, machinesForm);
  Application.CreateForm(TcashForm, cashForm);
  Application.CreateForm(TusersForm, usersForm);
  Application.CreateForm(TproductsForm, productsForm);
  Application.CreateForm(TshoppingForm, shoppingForm);
  LoginForm.Show;

  repeat
    Application.ProcessMessages;
  until loginForm.loggedIn;

  if loginForm.canTerminate then
    application.Terminate;

  loginForm.Close;

  Application.Run;
end.
