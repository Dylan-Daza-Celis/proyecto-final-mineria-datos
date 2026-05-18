unit datosSinteticos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, ExtCtrls;

type
  TPuntoSintetico = record
    X: Double;
    Y: Double;
    Clase: Integer;
  end;

  TArregloPuntosSinteticos = array of TPuntoSintetico;

function ObtenerColorClase(const Clase: Integer): TColor;
//Convertimos coordenadas de pantalla a cartesianas invirtiendo el eje Y.
procedure ConvertirCoordenadasPantallaACartesianas(const Image: TImage;
  const XPantalla, YPantalla: Integer; out XCartesiano, YCartesiano: Double);
function ConvertirXPantalla(const Image: TImage; const XCartesiano: Double): Integer;
function ConvertirYPantalla(const Image: TImage; const YCartesiano: Double): Integer;
procedure DibujarEjes(Image: TImage);
procedure InicializarCanvas(Image: TImage);
procedure AgregarPuntoSintetico(const X, Y: Double; const Clase: Integer);
procedure DibujarPunto(Image: TImage; const X, Y: Double; const Clase: Integer);
procedure RedibujarPuntos(Image: TImage);
procedure LimpiarDatosSinteticos(Image: TImage);
function CantidadPuntosSinteticos: Integer;
function ObtenerCantidadPuntos: Integer;
procedure ExportarDatosSinteticosCSV(const NombreArchivo: string;
  const Delimitador: Char = ',');

implementation

const
  RADIO_PUNTO = 3;
  INTERVALO_MARCAS = 50;
  TICKS_POR_DEFECTO = 5;

var
  puntosSinteticos: TArregloPuntosSinteticos;

function ObtenerColorClase(const Clase: Integer): TColor;
const
  COLORES_CLASE: array[0..6] of TColor = (
    clRed, clBlue, clGreen, clPurple, clOlive, clFuchsia, clTeal
  );
begin
  Result := COLORES_CLASE[Clase mod Length(COLORES_CLASE)];
end;

function ObtenerOrigenXPantalla(const Image: TImage): Integer;
begin
  if (Image = nil) or (Image.Width <= 0) then
    Exit(0);
  Result := 0;
end;

function ObtenerOrigenYPantalla(const Image: TImage): Integer;
begin
  if (Image = nil) or (Image.Height <= 0) then
    Exit(0);
  Result := Image.Height - 1;
end;

procedure ConvertirCoordenadasPantallaACartesianas(const Image: TImage;
  const XPantalla, YPantalla: Integer; out XCartesiano, YCartesiano: Double);
begin
  XCartesiano := XPantalla;
  if Image = nil then
    YCartesiano := YPantalla
  else
    YCartesiano := (Image.Height - 1) - YPantalla;
end;

function ConvertirXPantalla(const Image: TImage; const XCartesiano: Double): Integer;
begin
  if Image = nil then
    Exit(Round(XCartesiano));
  Result := Round(XCartesiano);
end;

function ConvertirYPantalla(const Image: TImage; const YCartesiano: Double): Integer;
begin
  if Image = nil then
    Exit(Round(YCartesiano));
  Result := (Image.Height - 1) - Round(YCartesiano);
end;

procedure LimpiarCanvasBlanco(Image: TImage);
begin
  if Image = nil then
    Exit;

  Image.Picture.Bitmap.SetSize(Image.Width, Image.Height);
  Image.Picture.Bitmap.Canvas.Brush.Color := clWhite;
  Image.Picture.Bitmap.Canvas.Pen.Color := clWhite;
  Image.Picture.Bitmap.Canvas.FillRect(0, 0, Image.Width, Image.Height);
end;

//Preparamos el canvas limpio con ejes cartesianos.
procedure PrepararCanvasCartesiano(Image: TImage);
begin
  LimpiarCanvasBlanco(Image);
  DibujarEjes(Image);
end;

//Dibujamos ejes y marcas de referencia en el plano.
procedure DibujarEjes(Image: TImage);
var
  Canvas: TCanvas;
  OrigenX, OrigenY: Integer;
  Posicion: Integer;
  Etiqueta: string;
begin
  if (Image = nil) or (Image.Picture.Bitmap = nil) then
    Exit;
  if (Image.Width <= 0) or (Image.Height <= 0) then
    Exit;

  Canvas := Image.Picture.Bitmap.Canvas;
  OrigenX := ObtenerOrigenXPantalla(Image);
  OrigenY := ObtenerOrigenYPantalla(Image);

  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 2;
  Canvas.Brush.Style := bsClear;

  Canvas.MoveTo(0, OrigenY);
  Canvas.LineTo(Image.Width - 1, OrigenY);
  Canvas.MoveTo(OrigenX, 0);
  Canvas.LineTo(OrigenX, Image.Height - 1);

  Canvas.Font.Color := clBlack;
  Canvas.Font.Size := 7;

  Posicion := 0;
  while Posicion <= Image.Width - 1 do
  begin
    Canvas.MoveTo(Posicion, OrigenY - TICKS_POR_DEFECTO);
    Canvas.LineTo(Posicion, OrigenY + TICKS_POR_DEFECTO);
    Etiqueta := IntToStr(Posicion);
    Canvas.TextOut(Posicion + 2,
      OrigenY - Canvas.TextHeight(Etiqueta) - 2, Etiqueta);
    Inc(Posicion, INTERVALO_MARCAS);
  end;

  Posicion := 0;
  while Posicion <= Image.Height - 1 do
  begin
    Canvas.MoveTo(OrigenX - TICKS_POR_DEFECTO, ConvertirYPantalla(Image, Posicion));
    Canvas.LineTo(OrigenX + TICKS_POR_DEFECTO, ConvertirYPantalla(Image, Posicion));
    Etiqueta := IntToStr(Posicion);
    Canvas.TextOut(OrigenX + 6, ConvertirYPantalla(Image, Posicion) - 4, Etiqueta);
    Inc(Posicion, INTERVALO_MARCAS);
  end;

  Canvas.TextOut(4,
    OrigenY - (Canvas.TextHeight('(0,0)') * 2) - 4, '(0,0)');
  Canvas.Brush.Style := bsSolid;
end;

//Inicializamos el canvas y reiniciamos los puntos sinteticos.
procedure InicializarCanvas(Image: TImage);
begin
  PrepararCanvasCartesiano(Image);
  SetLength(puntosSinteticos, 0);
  if Image <> nil then
    Image.Invalidate;
end;

//Agregamos un punto sintetico a la lista interna.
procedure AgregarPuntoSintetico(const X, Y: Double; const Clase: Integer);
var
  n: Integer;
begin
  n := Length(puntosSinteticos);
  SetLength(puntosSinteticos, n + 1);
  puntosSinteticos[n].X := X;
  puntosSinteticos[n].Y := Y;
  puntosSinteticos[n].Clase := Clase;
end;

procedure DibujarPuntoEnBitmap(Bitmap: TBitmap; const X, Y: Double;
  const Clase: Integer);
var
  cx, cy: Integer;
begin
  if Bitmap = nil then
    Exit;

  cx := Round(X);
  cy := Round(Y);
  Bitmap.Canvas.Brush.Color := ObtenerColorClase(Clase);
  Bitmap.Canvas.Pen.Color := clBlack;
  Bitmap.Canvas.Pen.Width := 1;
  Bitmap.Canvas.Ellipse(cx - RADIO_PUNTO, cy - RADIO_PUNTO,
    cx + RADIO_PUNTO, cy + RADIO_PUNTO);
end;

procedure DibujarPunto(Image: TImage; const X, Y: Double; const Clase: Integer);
var
  XPantalla, YPantalla: Integer;
begin
  if (Image = nil) or (Image.Picture.Bitmap = nil) then
    Exit;

  XPantalla := ConvertirXPantalla(Image, X);
  YPantalla := ConvertirYPantalla(Image, Y);
  DibujarPuntoEnBitmap(Image.Picture.Bitmap, XPantalla, YPantalla, Clase);
  Image.Invalidate;
end;

//Redibujamos todos los puntos despues de limpiar o redimensionar.
procedure RedibujarPuntos(Image: TImage);
var
  i: Integer;
begin
  if Image = nil then
    Exit;

  PrepararCanvasCartesiano(Image);
  for i := 0 to High(puntosSinteticos) do
    DibujarPuntoEnBitmap(Image.Picture.Bitmap,
      ConvertirXPantalla(Image, puntosSinteticos[i].X),
      ConvertirYPantalla(Image, puntosSinteticos[i].Y),
      puntosSinteticos[i].Clase);
  Image.Invalidate;
end;

procedure LimpiarDatosSinteticos(Image: TImage);
begin
  SetLength(puntosSinteticos, 0);
  PrepararCanvasCartesiano(Image);
  if Image <> nil then
    Image.Invalidate;
end;

function CantidadPuntosSinteticos: Integer;
begin
  Result := Length(puntosSinteticos);
end;

function ObtenerCantidadPuntos: Integer;
begin
  Result := Length(puntosSinteticos);
end;

function FloatToCSV(const Valor: Double; const FS: TFormatSettings): string;
begin
  Result := FloatToStrF(Valor, ffGeneral, 15, 6, FS);
end;

//Exportamos los puntos sinteticos en CSV con separador decimal consistente.
procedure ExportarDatosSinteticosCSV(const NombreArchivo: string;
  const Delimitador: Char = ',');
var
  archivo: TextFile;
  i: Integer;
  fs: TFormatSettings;
begin
  fs := DefaultFormatSettings;
  fs.DecimalSeparator := '.';

  AssignFile(archivo, NombreArchivo);
  Rewrite(archivo);
  try
    WriteLn(archivo, 'X' + Delimitador + 'Y' + Delimitador + 'Clase');
    for i := 0 to High(puntosSinteticos) do
      WriteLn(archivo,
        FloatToCSV(puntosSinteticos[i].X, fs) + Delimitador +
        FloatToCSV(puntosSinteticos[i].Y, fs) + Delimitador +
        IntToStr(puntosSinteticos[i].Clase));
  finally
    CloseFile(archivo);
  end;
end;

end.

