unit Graficas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, ExtCtrls, Matrices;

procedure LimpiarGrafica(const PaintBox: TPaintBox; const Mensaje: string);
procedure ContarClases(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer;
  out Etiquetas: TStringList; out Conteos: TArregloEntero);
procedure PrepararGraficaClases(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, IndiceColumnaClase: Integer;
  var EtiquetasClases: TStringList; out ConteosClases: TArregloEntero;
  out MaxConteoClases: Integer);

procedure DibujarGraficaBarras(const PaintBox: TPaintBox;
  const Etiquetas: TStringList; const Valores: TArregloDouble;
  const Titulo: string; MostrarPorcentaje: Boolean);

procedure DibujarGraficaClases(const PaintBox: TPaintBox;
  const Etiquetas: TStringList; const Conteos: TArregloEntero;
  const MaxConteo: Integer);

procedure DibujarGraficaProbabilidades(const PaintBox: TPaintBox;
  const Clases: TStringList; const Probabilidades: TArregloDouble);

procedure DibujarGraficaDispersion(const PaintBox: TPaintBox;
  const ValoresX, ValoresY: TArregloDouble;
  const MinX, MaxX, MinY, MaxY: Double;
  const LabelX, LabelY: string);

procedure DibujarGraficaDispersionClusters(const PaintBox: TPaintBox;
  const ValoresX, ValoresY: TArregloDouble;
  const MinX, MaxX, MinY, MaxY: Double;
  const LabelX, LabelY: string;
  const ClusterPorRegistro: array of Integer);

procedure DibujarGraficaBoxPlot(const PaintBox: TPaintBox;
  const Labels: TStringList;
  const ValoresMin, ValoresQ1, ValoresMediana, ValoresQ3, ValoresMax: TArregloDouble);

implementation

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

end.

