unit printerUnit;

interface

uses
  Printers, System.Classes, Winapi.Windows, Vcl.Graphics, Vcl.ExtCtrls,
  System.SysUtils, Jpeg, PNGImage;

type
  TPrint = class

  constructor Create;


  private

  public
    function loadImage(filename: String): TBitmap;
    procedure printCheck(sum, time: real; startTime, endTime: String; items: TStringList);
  end;

implementation

uses mainUnit;

constructor TPrint.Create;
begin
  inherited;
end;

function TPrint.loadImage(filename: String): TBitmap;
var
  Info      : PBitmapInfo;
  InfoSize  : DWORD;
  Image     : TImage;
  ImageSize : DWORD;
  Bits      : HBITMAP;
begin
  image := TImage.Create(mainForm);
  image.Picture.LoadFromFile(ExtractFilePath(paramStr(0)) + '/images/' + filename);
     Bits := result.Handle;  // bmp is passed as a parameter
     GetDIBSizes(Bits, InfoSize, ImageSize);
     Info := AllocMem(InfoSize);
     try
       Image := AllocMem(ImageSize);
       try
         GetDIB(Bits, 0, Info^, Image);

         StretchDIBits(Printer.Canvas.Handle,
             5, 30, result.Width, result.Height,
             0,  0, result.Width, result.Height,
             Image, Info^, DIB_RGB_COLORS, SRCCOPY);

       finally
        image.Destroy
       end;
     finally
       FreeMem(Info, InfoSize);
     end;
end;

procedure TPrint.printCheck(sum, time: real; startTime, endTime: String; items: TStringList);
var
  logo: TBitmap;
  Conv : TBitmap;
  y: integer;
  I: Integer;
begin
  //logo := self.loadImage('header_logo.jpg');
  conv := TBitmap.Create;
  Conv.LoadFromFile(ExtractFilePath(paramstr(0)) + '/images/header_logo.bmp');
  logo := tbitmap.Create;
  logo.SetSize(250, 250);
  logo.Canvas.StretchDraw(Rect(0, 0, 250, 250), conv);
  Printer.BeginDoc;

//  Printer.Canvas.Font.Size := 24;
//  Printer.Canvas.Font.Style := [fsBold];
//
//  Printer.Canvas.TextOut(20, 15, 'Billiard');

  Printer.Canvas.Draw(round(Printer.PageWidth / 2 - 125), 0, logo);

  Printer.Canvas.Font.Size := 10;
  Printer.Canvas.Font.Style := [fsBold];

  Printer.Canvas.TextOut(0, 250, '--------------------------------------------------------------------------------');



  Printer.Canvas.TextOut(0, 330, 'Начало: ' + startTime);
  Printer.Canvas.TextOut(0, 410, 'Время: ' + endTime);
  Printer.Canvas.TextOut(0, 490, 'Цена: ' + floattostr(time));


  y := 550;
  if items.Count > 0 then
    begin

      Printer.Canvas.TextOut(0, y, '--------------------------------------------------------------------------------');
      Printer.Canvas.Font.Size := 10;
      Printer.Canvas.Font.Style := [];
      for I := 0 to items.Count - 1 do
        begin
          y := y + 70;
          Printer.Canvas.TextOut(0, y, items[i]);
        end;
      y := y + 70;
    end;


  Printer.Canvas.Font.Style := [fsBold];
  Printer.Canvas.TextOut(0, y, '--------------------------------------------------------------------------------');

  y := y + 50;

  Printer.Canvas.TextOut(0, y, 'Итого: ' + floattostr(sum));

  Printer.Canvas.TextOut(0, y+100, '--------------------------------------------------------------------------------');

  Printer.EndDoc;
end;

end.
