unit Graficas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, ExtCtrls, Matrices, Estadisticas;

procedure LimpiarGrafica(const PaintBox: TPaintBox; const Mensaje: string);
procedure MostrarGraficaClases(const PaintBox: TPaintBox;
  const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer);
procedure MostrarGraficaDispersion(const PaintBox: TPaintBox;
  const MatrizDatosOriginales: TMatrizString;
  const NombresColumnas: TNombresColumnas;
  const TotalFilasDatos, IndiceColumnaClase, ColX, ColY: Integer;
  out MensajeError: string);
procedure MostrarGraficaBoxPlot(const PaintBox: TPaintBox;
  const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase, Columna: Integer;
  out MensajeError: string);
procedure MostrarGraficaProbabilidades(const PaintBox: TPaintBox;
  const Clases: TStringList; const Probabilidades: TArregloDouble);
procedure MostrarGraficaClusters(const PaintBox: TPaintBox;
  const ValoresX, ValoresY: TArregloDouble;
  const MinX, MaxX, MinY, MaxY: Double;
  const LabelX, LabelY: string;
  const ClusterPorRegistro: array of Integer);

implementation

//Contamos ocurrencias por clase para la grafica.
procedure ContarClases(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer;
  out Etiquetas: TStringList; out Conteos: TArregloEntero);
forward;
//Preparamos etiquetas, conteos y maximo para la grafica de clases.
procedure PrepararGraficaClases(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer;
  var EtiquetasClases: TStringList; out ConteosClases: TArregloEntero;
  out MaxConteoClases: Integer);
forward;

procedure LimpiarGrafica(const PaintBox: TPaintBox; const Mensaje: string);
begin
  PaintBox.Canvas.Brush.Color := clWhite;
  PaintBox.Canvas.FillRect(PaintBox.ClientRect);

  if Mensaje <> '' then
  begin
    PaintBox.Canvas.Font.Color := clGray;
    PaintBox.Canvas.TextOut(10, 10, Mensaje);
  end;
end;

procedure ContarClases(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer;
  out Etiquetas: TStringList; out Conteos: TArregloEntero);
var
  fila: Integer;
  etiqueta: string;
  indiceEtiqueta: Integer;
begin
  Etiquetas := TStringList.Create;
  SetLength(Conteos, 0);

  if (TotalFilasDatos <= 0) or (IndiceColumnaClase < 0) then
    Exit;

  for fila := 0 to TotalFilasDatos - 1 do
  begin
    etiqueta := Trim(MatrizDatosOriginales[fila][IndiceColumnaClase]);
    if etiqueta = '' then
      etiqueta := 'SinClase';

    indiceEtiqueta := Etiquetas.IndexOf(etiqueta);
    if indiceEtiqueta < 0 then
    begin
      Etiquetas.Add(etiqueta);
      SetLength(Conteos, Length(Conteos) + 1);
      Conteos[High(Conteos)] := 1;
    end
    else
      Inc(Conteos[indiceEtiqueta]);
  end;
end;

procedure PrepararGraficaClases(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer;
  var EtiquetasClases: TStringList; out ConteosClases: TArregloEntero;
  out MaxConteoClases: Integer);
var
  i: Integer;
begin
  if Assigned(EtiquetasClases) then
  begin
    EtiquetasClases.Free;
    EtiquetasClases := nil;
  end;

  ContarClases(MatrizDatosOriginales, TotalFilasDatos, IndiceColumnaClase,
    EtiquetasClases, ConteosClases);

  MaxConteoClases := 0;
  for i := 0 to High(ConteosClases) do
    if ConteosClases[i] > MaxConteoClases then
      MaxConteoClases := ConteosClases[i];
end;

function EtiquetaAjustada(const Canvas: TCanvas; const Texto: string;
  const AnchoMax: Integer): string;
var
  Temp: string;
begin
  Temp := Texto;
  while (Length(Temp) > 0) and (Canvas.TextWidth(Temp) > AnchoMax) do
    Delete(Temp, Length(Temp), 1);
  if (Temp <> Texto) and (Length(Temp) > 0) then
    Temp := Copy(Temp, 1, Length(Temp) - 1) + '.';
  Result := Temp;
end;

//Dibujamos una grafica de barras con ejes y valores.
procedure DibujarGraficaBarras(const PaintBox: TPaintBox;
  const Etiquetas: TStringList; const Valores: TArregloDouble;
  const Titulo: string; MostrarPorcentaje: Boolean);
var
  i: Integer;
  n: Integer;
  MargenIzq: Integer;
  MargenDer: Integer;
  MargenSup: Integer;
  MargenInf: Integer;
  AnchoGraf: Integer;
  AltoGraf: Integer;
  Espacio: Integer;
  AnchoBarra: Integer;
  AltoBarra: Integer;
  X: Integer;
  Y: Integer;
  BaseY: Integer;
  Etiqueta: string;
  NumTicks: Integer;
  Tick: Integer;
  YTick: Integer;
  ValorTick: Double;
  TextoTick: string;
  TitleX: Integer;
  ValueText: string;
  LabelX: Integer;
  MaxValor: Double;
  ValorActual: Double;
begin
  if PaintBox = nil then
    Exit;

  LimpiarGrafica(PaintBox, '');

  if (not Assigned(Etiquetas)) or (Length(Valores) = 0) then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  n := Etiquetas.Count;
  if (n = 0) or (Length(Valores) < n) then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  MaxValor := Valores[0];
  for i := 1 to n - 1 do
    if Valores[i] > MaxValor then
      MaxValor := Valores[i];

  if MaxValor <= 0 then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  MargenIzq := 70;
  MargenDer := 20;
  MargenSup := 30;
  MargenInf := 60;
  AnchoGraf := PaintBox.Width - MargenIzq - MargenDer;
  AltoGraf := PaintBox.Height - MargenSup - MargenInf;
  if (AnchoGraf <= 0) or (AltoGraf <= 0) then
    Exit;

  PaintBox.Canvas.Font.Style := [fsBold];
  PaintBox.Canvas.Font.Color := clBlack;
  TitleX := MargenIzq + (AnchoGraf - PaintBox.Canvas.TextWidth(Titulo)) div 2;
  PaintBox.Canvas.TextOut(TitleX, 4, Titulo);
  PaintBox.Canvas.Font.Style := [];

  Espacio := 6;
  if n > 1 then
    AnchoBarra := (AnchoGraf - (n - 1) * Espacio) div n
  else
    AnchoBarra := AnchoGraf;

  if AnchoBarra < 1 then
  begin
    Espacio := 2;
    if n > 1 then
      AnchoBarra := (AnchoGraf - (n - 1) * Espacio) div n
    else
      AnchoBarra := AnchoGraf;
  end;

  if AnchoBarra < 1 then
    AnchoBarra := 1;

  BaseY := MargenSup + AltoGraf;

  NumTicks := 5;
  if AltoGraf > 320 then
    NumTicks := 6
  else if AltoGraf < 180 then
    NumTicks := 4;

  PaintBox.Canvas.Pen.Width := 1;
  PaintBox.Canvas.Pen.Color := clSilver;
  for Tick := 0 to NumTicks do
  begin
    YTick := BaseY - Round((Tick / NumTicks) * AltoGraf);
    PaintBox.Canvas.MoveTo(MargenIzq, YTick);
    PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, YTick);

    ValorTick := (MaxValor * Tick) / NumTicks;
    if MostrarPorcentaje then
      TextoTick := FormatFloat('0.00%', ValorTick)
    else
      TextoTick := FormatFloat('0', ValorTick);
    PaintBox.Canvas.Font.Color := clBlack;
    PaintBox.Canvas.TextOut(
      MargenIzq - PaintBox.Canvas.TextWidth(TextoTick) - 6,
      YTick - (PaintBox.Canvas.TextHeight(TextoTick) div 2),
      TextoTick
    );
  end;

  PaintBox.Canvas.Pen.Color := clBlack;
  PaintBox.Canvas.Pen.Width := 2;
  PaintBox.Canvas.MoveTo(MargenIzq, MargenSup);
  PaintBox.Canvas.LineTo(MargenIzq, BaseY);
  PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, BaseY);

  PaintBox.Canvas.Pen.Width := 1;
  PaintBox.Canvas.Brush.Color := clSkyBlue;

  for i := 0 to n - 1 do
  begin
    ValorActual := Valores[i];
    if ValorActual < 0 then
      ValorActual := 0;

    AltoBarra := Round((ValorActual / MaxValor) * AltoGraf);
    X := MargenIzq + i * (AnchoBarra + Espacio);
    Y := BaseY - AltoBarra;

    PaintBox.Canvas.Rectangle(X, Y, X + AnchoBarra, BaseY);

    Etiqueta := EtiquetaAjustada(PaintBox.Canvas, Etiquetas[i], AnchoBarra);
    LabelX := X + (AnchoBarra div 2) - (PaintBox.Canvas.TextWidth(Etiqueta) div 2);
    PaintBox.Canvas.TextOut(LabelX, BaseY + 6, Etiqueta);

    if MostrarPorcentaje then
      ValueText := FormatFloat('0.00%', ValorActual)
    else
      ValueText := IntToStr(Round(ValorActual));

    PaintBox.Canvas.TextOut(
      X + (AnchoBarra div 2) - (PaintBox.Canvas.TextWidth(ValueText) div 2),
      Y - PaintBox.Canvas.TextHeight(ValueText) - 2,
      ValueText
    );
  end;
end;

procedure DibujarGraficaClases(const PaintBox: TPaintBox;
  const Etiquetas: TStringList; const Conteos: TArregloEntero;
  const MaxConteo: Integer);
var
  Valores: TArregloDouble;
  i: Integer;
begin
  if (not Assigned(Etiquetas)) or (Length(Conteos) = 0) then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  SetLength(Valores, Length(Conteos));
  for i := 0 to High(Conteos) do
    Valores[i] := Conteos[i];

  if MaxConteo <= 0 then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  DibujarGraficaBarras(PaintBox, Etiquetas, Valores, 'Distribucion de clases', False);
end;

procedure DibujarGraficaProbabilidades(const PaintBox: TPaintBox;
  const Clases: TStringList; const Probabilidades: TArregloDouble);
begin
  DibujarGraficaBarras(PaintBox, Clases, Probabilidades,
    'Probabilidades por Clase', True);
end;

//Dibujamos una dispersion escalando al area visible.
procedure DibujarGraficaDispersion(const PaintBox: TPaintBox;
  const ValoresX, ValoresY: TArregloDouble;
  const MinX, MaxX, MinY, MaxY: Double;
  const LabelX, LabelY: string);
var
  i: Integer;
  MargenIzq: Integer;
  MargenDer: Integer;
  MargenSup: Integer;
  MargenInf: Integer;
  AnchoGraf: Integer;
  AltoGraf: Integer;
  BaseY: Integer;
  X: Integer;
  Y: Integer;
  XTick: Integer;
  YTick: Integer;
  EscalaX: Double;
  EscalaY: Double;
  RangoX: Double;
  RangoY: Double;
  NumTicks: Integer;
  Tick: Integer;
  ValorTick: Double;
  TextoTick: string;
  Title: string;
  TitleX: Integer;
  AxisX: string;
  AxisY: string;
begin
  LimpiarGrafica(PaintBox, '');

  if Length(ValoresX) = 0 then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  MargenIzq := 70;
  MargenDer := 20;
  MargenSup := 30;
  MargenInf := 60;
  AnchoGraf := PaintBox.Width - MargenIzq - MargenDer;
  AltoGraf := PaintBox.Height - MargenSup - MargenInf;
  if (AnchoGraf <= 0) or (AltoGraf <= 0) then
    Exit;

  Title := 'Grafica de dispersion';
  PaintBox.Canvas.Font.Style := [fsBold];
  PaintBox.Canvas.Font.Color := clBlack;
  TitleX := MargenIzq + (AnchoGraf - PaintBox.Canvas.TextWidth(Title)) div 2;
  PaintBox.Canvas.TextOut(TitleX, 4, Title);
  PaintBox.Canvas.Font.Style := [];

  BaseY := MargenSup + AltoGraf;
  RangoX := MaxX - MinX;
  RangoY := MaxY - MinY;
  if RangoX = 0 then
    RangoX := 1;
  if RangoY = 0 then
    RangoY := 1;

  EscalaX := AnchoGraf / RangoX;
  EscalaY := AltoGraf / RangoY;

  NumTicks := 5;
  if AltoGraf > 320 then
    NumTicks := 6
  else if AltoGraf < 180 then
    NumTicks := 4;

  PaintBox.Canvas.Pen.Width := 1;
  PaintBox.Canvas.Pen.Color := clSilver;
  for Tick := 0 to NumTicks do
  begin
    YTick := BaseY - Round((Tick / NumTicks) * AltoGraf);
    PaintBox.Canvas.MoveTo(MargenIzq, YTick);
    PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, YTick);

    ValorTick := MinY + (Tick / NumTicks) * RangoY;
    TextoTick := FormatFloat('0.##', ValorTick);
    PaintBox.Canvas.Font.Color := clBlack;
    PaintBox.Canvas.TextOut(
      MargenIzq - PaintBox.Canvas.TextWidth(TextoTick) - 6,
      YTick - (PaintBox.Canvas.TextHeight(TextoTick) div 2),
      TextoTick
    );
  end;

  PaintBox.Canvas.Pen.Color := clBlack;
  PaintBox.Canvas.Pen.Width := 2;
  PaintBox.Canvas.MoveTo(MargenIzq, MargenSup);
  PaintBox.Canvas.LineTo(MargenIzq, BaseY);
  PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, BaseY);

  PaintBox.Canvas.Pen.Width := 1;
  for Tick := 0 to NumTicks do
  begin
    XTick := MargenIzq + Round((Tick / NumTicks) * AnchoGraf);
    PaintBox.Canvas.MoveTo(XTick, BaseY);
    PaintBox.Canvas.LineTo(XTick, BaseY + 4);
    ValorTick := MinX + (Tick / NumTicks) * RangoX;
    TextoTick := FormatFloat('0.##', ValorTick);
    PaintBox.Canvas.TextOut(
      XTick - (PaintBox.Canvas.TextWidth(TextoTick) div 2),
      BaseY + 6,
      TextoTick
    );
  end;

  AxisX := 'X: ' + LabelX;
  AxisY := 'Y: ' + LabelY;
  PaintBox.Canvas.TextOut(
    MargenIzq + (AnchoGraf - PaintBox.Canvas.TextWidth(AxisX)) div 2,
    BaseY + 28,
    AxisX
  );
  PaintBox.Canvas.TextOut(6, MargenSup + 4, AxisY);

  PaintBox.Canvas.Brush.Color := clNavy;
  PaintBox.Canvas.Pen.Color := clNavy;
  for i := 0 to High(ValoresX) do
  begin
    X := MargenIzq + Round((ValoresX[i] - MinX) * EscalaX);
    Y := BaseY - Round((ValoresY[i] - MinY) * EscalaY);
    PaintBox.Canvas.Ellipse(X - 2, Y - 2, X + 2, Y + 2);
  end;
end;

//Dibujamos boxplots por clase usando percentiles.
procedure DibujarGraficaBoxPlot(const PaintBox: TPaintBox;
  const Labels: TStringList;
  const ValoresMin, ValoresQ1, ValoresMediana, ValoresQ3, ValoresMax: TArregloDouble);
var
  n: Integer;
  i: Integer;
  MargenIzq: Integer;
  MargenDer: Integer;
  MargenSup: Integer;
  MargenInf: Integer;
  AnchoGraf: Integer;
  AltoGraf: Integer;
  Espacio: Integer;
  AnchoCaja: Integer;
  XCentro: Integer;
  BaseY: Integer;
  MinGlobal: Double;
  MaxGlobal: Double;
  Rango: Double;
  NumTicks: Integer;
  Tick: Integer;
  YTick: Integer;
  ValorTick: Double;
  TextoTick: string;
  Title: string;
  TitleX: Integer;
  Etiqueta: string;
  LabelX: Integer;
  function EscalaY(const Valor: Double): Integer;
  begin
    if Rango = 0 then
      Result := BaseY
    else
      Result := BaseY - Round((Valor - MinGlobal) / Rango * AltoGraf);
  end;
begin
  LimpiarGrafica(PaintBox, '');

  if (not Assigned(Labels)) or (Labels.Count = 0) then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  n := Labels.Count;
  if (Length(ValoresMin) < n) or (Length(ValoresMax) < n) or (Length(ValoresQ1) < n) or
    (Length(ValoresMediana) < n) or (Length(ValoresQ3) < n) then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  MinGlobal := ValoresMin[0];
  MaxGlobal := ValoresMax[0];
  for i := 1 to n - 1 do
  begin
    if ValoresMin[i] < MinGlobal then
      MinGlobal := ValoresMin[i];
    if ValoresMax[i] > MaxGlobal then
      MaxGlobal := ValoresMax[i];
  end;

  MargenIzq := 70;
  MargenDer := 20;
  MargenSup := 30;
  MargenInf := 60;
  AnchoGraf := PaintBox.Width - MargenIzq - MargenDer;
  AltoGraf := PaintBox.Height - MargenSup - MargenInf;
  if (AnchoGraf <= 0) or (AltoGraf <= 0) then
    Exit;

  Title := 'BoxPlot de atributos';
  PaintBox.Canvas.Font.Style := [fsBold];
  PaintBox.Canvas.Font.Color := clBlack;
  TitleX := MargenIzq + (AnchoGraf - PaintBox.Canvas.TextWidth(Title)) div 2;
  PaintBox.Canvas.TextOut(TitleX, 4, Title);
  PaintBox.Canvas.Font.Style := [];

  BaseY := MargenSup + AltoGraf;
  Rango := MaxGlobal - MinGlobal;
  if Rango = 0 then
    Rango := 1;

  NumTicks := 5;
  if AltoGraf > 320 then
    NumTicks := 6
  else if AltoGraf < 180 then
    NumTicks := 4;

  PaintBox.Canvas.Pen.Width := 1;
  PaintBox.Canvas.Pen.Color := clSilver;
  for Tick := 0 to NumTicks do
  begin
    YTick := BaseY - Round((Tick / NumTicks) * AltoGraf);
    PaintBox.Canvas.MoveTo(MargenIzq, YTick);
    PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, YTick);

    ValorTick := MinGlobal + (Tick / NumTicks) * Rango;
    TextoTick := FormatFloat('0.##', ValorTick);
    PaintBox.Canvas.Font.Color := clBlack;
    PaintBox.Canvas.TextOut(
      MargenIzq - PaintBox.Canvas.TextWidth(TextoTick) - 6,
      YTick - (PaintBox.Canvas.TextHeight(TextoTick) div 2),
      TextoTick
    );
  end;

  PaintBox.Canvas.Pen.Color := clBlack;
  PaintBox.Canvas.Pen.Width := 2;
  PaintBox.Canvas.MoveTo(MargenIzq, MargenSup);
  PaintBox.Canvas.LineTo(MargenIzq, BaseY);
  PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, BaseY);

  Espacio := 10;
  if n > 1 then
    AnchoCaja := (AnchoGraf - (n - 1) * Espacio) div n
  else
    AnchoCaja := AnchoGraf;

  if AnchoCaja < 10 then
    AnchoCaja := 10;

  PaintBox.Canvas.Pen.Color := clGray;
  PaintBox.Canvas.Brush.Color := clMoneyGreen;

  for i := 0 to n - 1 do
  begin
    XCentro := MargenIzq + i * (AnchoCaja + Espacio) + (AnchoCaja div 2);

    PaintBox.Canvas.Pen.Width := 1;
    PaintBox.Canvas.MoveTo(XCentro, EscalaY(ValoresMin[i]));
    PaintBox.Canvas.LineTo(XCentro, EscalaY(ValoresMax[i]));
    PaintBox.Canvas.LineTo(XCentro - 6, EscalaY(ValoresMax[i]));
    PaintBox.Canvas.MoveTo(XCentro, EscalaY(ValoresMin[i]));
    PaintBox.Canvas.LineTo(XCentro + 6, EscalaY(ValoresMin[i]));

    PaintBox.Canvas.Rectangle(
      XCentro - (AnchoCaja div 2),
      EscalaY(ValoresQ3[i]),
      XCentro + (AnchoCaja div 2),
      EscalaY(ValoresQ1[i])
    );
    PaintBox.Canvas.Pen.Width := 2;
    PaintBox.Canvas.MoveTo(XCentro - (AnchoCaja div 2), EscalaY(ValoresMediana[i]));
    PaintBox.Canvas.LineTo(XCentro + (AnchoCaja div 2), EscalaY(ValoresMediana[i]));

    Etiqueta := EtiquetaAjustada(PaintBox.Canvas, Labels[i], AnchoCaja + Espacio);
    LabelX := XCentro - (PaintBox.Canvas.TextWidth(Etiqueta) div 2);
    PaintBox.Canvas.TextOut(LabelX, BaseY + 6, Etiqueta);
  end;
end;

const
  COLORES_CLUSTER: array[0..14] of TColor = (
    clRed, clBlue, clGreen, clYellow, clNavy, clTeal,
    clOlive, clPurple, clLime, clMaroon, clMoneyGreen, clCream,
    clDkGray, clLtGray, clSilver
  );

function ObtenerColorCluster(NumeroClusters: Integer; ClusterActual: Integer): TColor;
begin
  Result := COLORES_CLUSTER[ClusterActual mod 15];
end;

//Dibujamos dispersion coloreada por cluster.
procedure DibujarGraficaDispersionClusters(const PaintBox: TPaintBox;
  const ValoresX, ValoresY: TArregloDouble;
  const MinX, MaxX, MinY, MaxY: Double;
  const LabelX, LabelY: string;
  const ClusterPorRegistro: array of Integer);
var
  i: Integer;
  MargenIzq: Integer;
  MargenDer: Integer;
  MargenSup: Integer;
  MargenInf: Integer;
  AnchoGraf: Integer;
  AltoGraf: Integer;
  BaseY: Integer;
  X: Integer;
  Y: Integer;
  XTick: Integer;
  YTick: Integer;
  EscalaX: Double;
  EscalaY: Double;
  RangoX: Double;
  RangoY: Double;
  NumTicks: Integer;
  Tick: Integer;
  ValorTick: Double;
  TextoTick: string;
  Title: string;
  TitleX: Integer;
  AxisX: string;
  AxisY: string;
  ColorActual: TColor;
begin
  LimpiarGrafica(PaintBox, '');

  if Length(ValoresX) = 0 then
  begin
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  MargenIzq := 70;
  MargenDer := 20;
  MargenSup := 30;
  MargenInf := 60;
  AnchoGraf := PaintBox.Width - MargenIzq - MargenDer;
  AltoGraf := PaintBox.Height - MargenSup - MargenInf;
  if (AnchoGraf <= 0) or (AltoGraf <= 0) then
    Exit;

  Title := 'Grafica de dispersión - Clusters';
  PaintBox.Canvas.Font.Style := [fsBold];
  PaintBox.Canvas.Font.Color := clBlack;
  TitleX := MargenIzq + (AnchoGraf - PaintBox.Canvas.TextWidth(Title)) div 2;
  PaintBox.Canvas.TextOut(TitleX, 4, Title);
  PaintBox.Canvas.Font.Style := [];

  BaseY := MargenSup + AltoGraf;
  RangoX := MaxX - MinX;
  RangoY := MaxY - MinY;
  if RangoX = 0 then
    RangoX := 1;
  if RangoY = 0 then
    RangoY := 1;

  EscalaX := AnchoGraf / RangoX;
  EscalaY := AltoGraf / RangoY;

  NumTicks := 5;
  if AltoGraf > 320 then
    NumTicks := 6
  else if AltoGraf < 180 then
    NumTicks := 4;

  PaintBox.Canvas.Pen.Width := 1;
  PaintBox.Canvas.Pen.Color := clSilver;
  for Tick := 0 to NumTicks do
  begin
    YTick := BaseY - Round((Tick / NumTicks) * AltoGraf);
    PaintBox.Canvas.MoveTo(MargenIzq, YTick);
    PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, YTick);

    ValorTick := MinY + (Tick / NumTicks) * RangoY;
    TextoTick := FormatFloat('0.##', ValorTick);
    PaintBox.Canvas.Font.Color := clBlack;
    PaintBox.Canvas.TextOut(
      MargenIzq - PaintBox.Canvas.TextWidth(TextoTick) - 6,
      YTick - (PaintBox.Canvas.TextHeight(TextoTick) div 2),
      TextoTick
    );
  end;

  PaintBox.Canvas.Pen.Color := clBlack;
  PaintBox.Canvas.Pen.Width := 2;
  PaintBox.Canvas.MoveTo(MargenIzq, MargenSup);
  PaintBox.Canvas.LineTo(MargenIzq, BaseY);
  PaintBox.Canvas.LineTo(MargenIzq + AnchoGraf, BaseY);

  PaintBox.Canvas.Pen.Width := 1;
  for Tick := 0 to NumTicks do
  begin
    XTick := MargenIzq + Round((Tick / NumTicks) * AnchoGraf);
    PaintBox.Canvas.MoveTo(XTick, BaseY);
    PaintBox.Canvas.LineTo(XTick, BaseY + 4);
    ValorTick := MinX + (Tick / NumTicks) * RangoX;
    TextoTick := FormatFloat('0.##', ValorTick);
    PaintBox.Canvas.TextOut(
      XTick - (PaintBox.Canvas.TextWidth(TextoTick) div 2),
      BaseY + 6,
      TextoTick
    );
  end;

  AxisX := 'X: ' + LabelX;
  AxisY := 'Y: ' + LabelY;
  PaintBox.Canvas.TextOut(
    MargenIzq + (AnchoGraf - PaintBox.Canvas.TextWidth(AxisX)) div 2,
    BaseY + 28,
    AxisX
  );
  PaintBox.Canvas.TextOut(6, MargenSup + 4, AxisY);

  PaintBox.Canvas.Pen.Width := 2;
  for i := 0 to High(ValoresX) do
  begin
    if (i >= 0) and (i <= High(ClusterPorRegistro)) then
      ColorActual := ObtenerColorCluster(15, ClusterPorRegistro[i])
    else
      ColorActual := clNavy;

    PaintBox.Canvas.Brush.Color := ColorActual;
    PaintBox.Canvas.Pen.Color := ColorActual;
    X := MargenIzq + Round((ValoresX[i] - MinX) * EscalaX);
    Y := BaseY - Round((ValoresY[i] - MinY) * EscalaY);
    PaintBox.Canvas.Ellipse(X - 3, Y - 3, X + 3, Y + 3);
  end;
end;

//Preparamos datos X/Y y rangos para la dispersion.
function PrepararDatosDispersion(const MatrizDatosOriginales: TMatrizString;
  const NombresColumnas: TNombresColumnas;
  const TotalFilasDatos, IndiceColumnaClase, ColX, ColY: Integer;
  out ValoresX, ValoresY: TArregloDouble;
  out MinX, MaxX, MinY, MaxY: Double;
  out LabelX, LabelY: string): Boolean;
var
  fila: Integer;
  valorX: Double;
  valorY: Double;
  formatos: TFormatSettings;
  puntos: Integer;
begin
  Result := False;
  SetLength(ValoresX, 0);
  SetLength(ValoresY, 0);
  LabelX := '';
  LabelY := '';

  if (ColX < 0) or (ColY < 0) or (ColX = ColY) then
    Exit;

  if (ColX >= IndiceColumnaClase) or (ColY >= IndiceColumnaClase) then
    Exit;

  if ColX < Length(NombresColumnas) then
    LabelX := NombresColumnas[ColX];
  if ColY < Length(NombresColumnas) then
    LabelY := NombresColumnas[ColY];

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';
  puntos := 0;

  for fila := 0 to TotalFilasDatos - 1 do
  begin
    if (fila >= Length(MatrizDatosOriginales)) or
      (ColX >= Length(MatrizDatosOriginales[fila])) or
      (ColY >= Length(MatrizDatosOriginales[fila])) then
      Continue;

    if not TryStrToFloat(Trim(MatrizDatosOriginales[fila][ColX]), valorX, formatos) then
      Continue;

    if not TryStrToFloat(Trim(MatrizDatosOriginales[fila][ColY]), valorY, formatos) then
      Continue;

    Inc(puntos);
    SetLength(ValoresX, puntos);
    SetLength(ValoresY, puntos);
    ValoresX[puntos - 1] := valorX;
    ValoresY[puntos - 1] := valorY;

    if puntos = 1 then
    begin
      MinX := valorX;
      MaxX := valorX;
      MinY := valorY;
      MaxY := valorY;
    end
    else
    begin
      if valorX < MinX then
        MinX := valorX;
      if valorX > MaxX then
        MaxX := valorX;
      if valorY < MinY then
        MinY := valorY;
      if valorY > MaxY then
        MaxY := valorY;
    end;
  end;

  Result := puntos > 0;
end;

//Calculamos percentil con interpolacion lineal.
function Percentil(const Datos: TArregloDouble; const P: Double): Double;
var
  idx: Double;
  i: Integer;
  frac: Double;
begin
  if Length(Datos) = 0 then
    Exit(0);
  if Length(Datos) = 1 then
    Exit(Datos[0]);

  idx := (Length(Datos) - 1) * P;
  i := Trunc(idx);
  frac := idx - i;
  if i >= Length(Datos) - 1 then
    Result := Datos[High(Datos)]
  else
    Result := Datos[i] + frac * (Datos[i + 1] - Datos[i]);
end;

//Agrupamos valores por clase y calculamos min, Q1, mediana, Q3 y max.
function PrepararDatosBoxPlot(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase, Columna: Integer;
  out Labels: TStringList;
  out ValoresMin, ValoresQ1, ValoresMediana, ValoresQ3, ValoresMax: TArregloDouble): Boolean;
var
  fila: Integer;
  numero: Double;
  clase: string;
  idxClase: Integer;
  i: Integer;
  valoresClase: array of TArregloDouble;
  valores: TArregloDouble;
  formatos: TFormatSettings;
begin
  Result := False;
  Labels := TStringList.Create;
  SetLength(ValoresMin, 0);
  SetLength(ValoresQ1, 0);
  SetLength(ValoresMediana, 0);
  SetLength(ValoresQ3, 0);
  SetLength(ValoresMax, 0);

  if (Columna < 0) or (Columna >= IndiceColumnaClase) then
    Exit;

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';
  SetLength(valoresClase, 0);

  for fila := 0 to TotalFilasDatos - 1 do
  begin
    if (fila >= Length(MatrizDatosOriginales)) or
      (Columna >= Length(MatrizDatosOriginales[fila])) or
      (IndiceColumnaClase >= Length(MatrizDatosOriginales[fila])) then
      Continue;

    if not TryStrToFloat(Trim(MatrizDatosOriginales[fila][Columna]), numero, formatos) then
      Continue;

    clase := Trim(MatrizDatosOriginales[fila][IndiceColumnaClase]);
    if clase = '' then
      clase := 'SinClase';

    idxClase := Labels.IndexOf(clase);
    if idxClase < 0 then
    begin
      idxClase := Labels.Add(clase);
      SetLength(valoresClase, Labels.Count);
      SetLength(valoresClase[idxClase], 0);
    end;

    SetLength(valoresClase[idxClase], Length(valoresClase[idxClase]) + 1);
    valoresClase[idxClase][High(valoresClase[idxClase])] := numero;
  end;

  for i := 0 to Labels.Count - 1 do
  begin
    valores := valoresClase[i];
    if Length(valores) = 0 then
      Continue;

    Estadisticas.OrdenarValores(valores);

    SetLength(ValoresMin, Length(ValoresMin) + 1);
    SetLength(ValoresQ1, Length(ValoresQ1) + 1);
    SetLength(ValoresMediana, Length(ValoresMediana) + 1);
    SetLength(ValoresQ3, Length(ValoresQ3) + 1);
    SetLength(ValoresMax, Length(ValoresMax) + 1);

    ValoresMin[High(ValoresMin)] := valores[0];
    ValoresMax[High(ValoresMax)] := valores[High(valores)];
    ValoresQ1[High(ValoresQ1)] := Percentil(valores, 0.25);
    ValoresMediana[High(ValoresMediana)] := Percentil(valores, 0.50);
    ValoresQ3[High(ValoresQ3)] := Percentil(valores, 0.75);
  end;

  Result := Labels.Count > 0;
end;

procedure MostrarGraficaClases(const PaintBox: TPaintBox;
  const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer);
var
  etiquetas: TStringList;
  conteos: TArregloEntero;
  maxConteo: Integer;
begin
  etiquetas := nil;
  PrepararGraficaClases(MatrizDatosOriginales, TotalFilasDatos,
    IndiceColumnaClase, etiquetas, conteos, maxConteo);
  try
    DibujarGraficaClases(PaintBox, etiquetas, conteos, maxConteo);
  finally
    if Assigned(etiquetas) then
      etiquetas.Free;
  end;
end;

procedure MostrarGraficaDispersion(const PaintBox: TPaintBox;
  const MatrizDatosOriginales: TMatrizString;
  const NombresColumnas: TNombresColumnas;
  const TotalFilasDatos, IndiceColumnaClase, ColX, ColY: Integer;
  out MensajeError: string);
var
  valoresX: TArregloDouble;
  valoresY: TArregloDouble;
  minX: Double;
  maxX: Double;
  minY: Double;
  maxY: Double;
  labelX: string;
  labelY: string;
begin
  MensajeError := '';
  if not PrepararDatosDispersion(MatrizDatosOriginales, NombresColumnas,
    TotalFilasDatos, IndiceColumnaClase, ColX, ColY, valoresX, valoresY,
    minX, maxX, minY, maxY, labelX, labelY) then
  begin
    MensajeError := 'No hay datos numericos para dispersion.';
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    Exit;
  end;

  DibujarGraficaDispersion(PaintBox, valoresX, valoresY, minX, maxX, minY,
    maxY, labelX, labelY);
end;

procedure MostrarGraficaBoxPlot(const PaintBox: TPaintBox;
  const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase, Columna: Integer;
  out MensajeError: string);
var
  labels: TStringList;
  valoresMin: TArregloDouble;
  valoresQ1: TArregloDouble;
  valoresMediana: TArregloDouble;
  valoresQ3: TArregloDouble;
  valoresMax: TArregloDouble;
begin
  MensajeError := '';
  labels := nil;
  if not PrepararDatosBoxPlot(MatrizDatosOriginales, TotalFilasDatos,
    IndiceColumnaClase, Columna, labels, valoresMin, valoresQ1,
    valoresMediana, valoresQ3, valoresMax) then
  begin
    MensajeError := 'No hay datos numericos para boxplot.';
    LimpiarGrafica(PaintBox, 'No hay datos para graficar');
    if Assigned(labels) then
      labels.Free;
    Exit;
  end;

  try
    DibujarGraficaBoxPlot(PaintBox, labels, valoresMin, valoresQ1,
      valoresMediana, valoresQ3, valoresMax);
  finally
    labels.Free;
  end;
end;

procedure MostrarGraficaProbabilidades(const PaintBox: TPaintBox;
  const Clases: TStringList; const Probabilidades: TArregloDouble);
begin
  DibujarGraficaProbabilidades(PaintBox, Clases, Probabilidades);
end;

procedure MostrarGraficaClusters(const PaintBox: TPaintBox;
  const ValoresX, ValoresY: TArregloDouble;
  const MinX, MaxX, MinY, MaxY: Double;
  const LabelX, LabelY: string;
  const ClusterPorRegistro: array of Integer);
begin
  DibujarGraficaDispersionClusters(PaintBox, ValoresX, ValoresY, MinX, MaxX,
    MinY, MaxY, LabelX, LabelY, ClusterPorRegistro);
end;

end.

