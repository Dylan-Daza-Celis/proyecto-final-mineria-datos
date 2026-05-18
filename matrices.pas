unit Matrices;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids;

type
  TTipoEstadistica = (teMedia, teMediana, teDesviacion);
  TTipoGrafica = (tgNinguna, tgBarras, tgDispersion, tgBoxPlot);
  TTipoNormalizacion = (tnMinMax, tnZScore, tnDecimalScaling);

  TMatrizString = array of array of string;
  TArregloDouble = array of Double;
  TArregloBool = array of Boolean;
  TArregloEntero = array of Integer;
  TArregloEntero2D = array of TArregloEntero;
  TArregloDoble2D = array of TArregloDouble;
  TArregloString = array of string;
  TNombresColumnas = array of string;

function DetectarDelimitador(const Linea: string): Char;
procedure CargarDatosDesdeCSV(const NombreArchivo: string;
  out Matriz: TMatrizString; out Nombres: TNombresColumnas;
  out TotalFilas, TotalColumnas, IndiceClase: Integer; out Delimitador: Char);
procedure ExportarMatrizCSV(const Matriz: TMatrizString;
  const Nombres: TNombresColumnas; const TotalFilas, TotalColumnas: Integer;
  const Delimitador: Char; const NombreArchivo: string);
procedure CargarGridDesdeMatriz(const Grid: TStringGrid; const Matriz: TMatrizString;
  const Nombres: TNombresColumnas; const TotalFilas, TotalColumnas: Integer);

implementation

function DetectarDelimitador(const Linea: string): Char;
var
  i: Integer;
  conteoComa: Integer;
  conteoPuntoComa: Integer;
begin
  conteoComa := 0;
  conteoPuntoComa := 0;
  for i := 1 to Length(Linea) do
  begin
    case Linea[i] of
      ',': Inc(conteoComa);
      ';': Inc(conteoPuntoComa);
    end;
  end;

  if conteoPuntoComa > conteoComa then
    Result := ';'
  else
    Result := ',';
end;

procedure CargarDatosDesdeCSV(const NombreArchivo: string;
  out Matriz: TMatrizString; out Nombres: TNombresColumnas;
  out TotalFilas, TotalColumnas, IndiceClase: Integer; out Delimitador: Char);
var
  lineasArchivo: TStringList;
  lineasDatos: TStringList;
  valoresFila: TStringList;
  nombresTemp: TStringList;
  textoLinea: string;
  i: Integer;
  j: Integer;
  filaDatos: Integer;
  maxColumnas: Integer;
  indice: Integer;
  tieneDatos: Boolean;
  nombreColumna: string;
begin
  Matriz := nil;
  Nombres := nil;
  TotalFilas := 0;
  TotalColumnas := 0;
  IndiceClase := -1;
  Delimitador := ',';

  lineasArchivo := TStringList.Create;
  lineasDatos := TStringList.Create;
  valoresFila := TStringList.Create;
  nombresTemp := TStringList.Create;
  try
    lineasArchivo.LoadFromFile(NombreArchivo);
    if lineasArchivo.Count = 0 then
      Exit;

    Delimitador := DetectarDelimitador(lineasArchivo[0]);
    valoresFila.StrictDelimiter := True;
    valoresFila.Delimiter := Delimitador;

    maxColumnas := 0;
    valoresFila.DelimitedText := lineasArchivo[0];
    if valoresFila.Count > maxColumnas then
      maxColumnas := valoresFila.Count;

    for i := 1 to lineasArchivo.Count - 1 do
    begin
      textoLinea := lineasArchivo[i];
      valoresFila.DelimitedText := textoLinea;

      tieneDatos := False;
      for indice := 0 to valoresFila.Count - 1 do
      begin
        if Trim(valoresFila[indice]) <> '' then
        begin
          tieneDatos := True;
          Break;
        end;
      end;

      if tieneDatos then
      begin
        lineasDatos.Add(textoLinea);
        if valoresFila.Count > maxColumnas then
          maxColumnas := valoresFila.Count;
      end;
    end;

    if maxColumnas = 0 then
      maxColumnas := 1;

    TotalColumnas := maxColumnas;
    TotalFilas := lineasDatos.Count;
    if TotalColumnas > 0 then
      IndiceClase := TotalColumnas - 1
    else
      IndiceClase := -1;

    SetLength(Matriz, TotalFilas);
    for filaDatos := 0 to TotalFilas - 1 do
      SetLength(Matriz[filaDatos], TotalColumnas);

    for i := 0 to lineasDatos.Count - 1 do
    begin
      filaDatos := i;
      valoresFila.DelimitedText := lineasDatos[i];

      for j := 0 to TotalColumnas - 1 do
      begin
        if (j < valoresFila.Count) and (valoresFila.Count > 0) then
          Matriz[filaDatos][j] := valoresFila[j]
        else
          Matriz[filaDatos][j] := '';
      end;
    end;

    nombresTemp.StrictDelimiter := True;
    nombresTemp.Delimiter := Delimitador;
    nombresTemp.DelimitedText := lineasArchivo[0];
    SetLength(Nombres, maxColumnas);
    for i := 0 to maxColumnas - 1 do
    begin
      if i < nombresTemp.Count then
        nombreColumna := Trim(nombresTemp[i])
      else
        nombreColumna := '';

      if nombreColumna = '' then
        nombreColumna := Format('Col%d', [i + 1]);

      Nombres[i] := nombreColumna;
    end;
  finally
    nombresTemp.Free;
    valoresFila.Free;
    lineasDatos.Free;
    lineasArchivo.Free;
  end;
end;

procedure ExportarMatrizCSV(const Matriz: TMatrizString;
  const Nombres: TNombresColumnas; const TotalFilas, TotalColumnas: Integer;
  const Delimitador: Char; const NombreArchivo: string);
var
  lineas: TStringList;
  fila: Integer;
  col: Integer;
  linea: string;
  filasExportar: Integer;
  delim: Char;
begin
  if (TotalFilas <= 0) or (TotalColumnas <= 0) or (Length(Matriz) = 0) then
    Exit;

  delim := Delimitador;
  if (delim <> ',') and (delim <> ';') then
    delim := ',';

  lineas := TStringList.Create;
  try
    linea := '';
    for col := 0 to TotalColumnas - 1 do
    begin
      if col > 0 then
        linea := linea + delim;
      if col < Length(Nombres) then
        linea := linea + Nombres[col]
      else
        linea := linea + 'Col' + IntToStr(col + 1);
    end;
    lineas.Add(linea);

    filasExportar := TotalFilas;
    if Length(Matriz) < filasExportar then
      filasExportar := Length(Matriz);

    for fila := 0 to filasExportar - 1 do
    begin
      linea := '';
      for col := 0 to TotalColumnas - 1 do
      begin
        if col > 0 then
          linea := linea + delim;
        if (fila < Length(Matriz)) and (col < Length(Matriz[fila])) then
          linea := linea + Matriz[fila][col];
      end;
      lineas.Add(linea);
    end;

    lineas.SaveToFile(NombreArchivo);
  finally
    lineas.Free;
  end;
end;

procedure CargarGridDesdeMatriz(const Grid: TStringGrid; const Matriz: TMatrizString;
  const Nombres: TNombresColumnas; const TotalFilas, TotalColumnas: Integer);
var
  filaDatos: Integer;
  filaGrid: Integer;
  col: Integer;
  filasMostrar: Integer;
begin
  if (Grid = nil) or (TotalColumnas <= 0) then
    Exit;

  filasMostrar := TotalFilas;
  if Length(Matriz) < filasMostrar then
    filasMostrar := Length(Matriz);

  Grid.BeginUpdate;
  try
    Grid.FixedCols := 0;
    Grid.FixedRows := 1;
    Grid.RowCount := filasMostrar + 1;
    Grid.ColCount := TotalColumnas;

    for col := 0 to TotalColumnas - 1 do
    begin
      if col < Length(Nombres) then
        Grid.Cells[col, 0] := Nombres[col]
      else
        Grid.Cells[col, 0] := 'Columna ' + IntToStr(col + 1);
    end;

    for filaDatos := 0 to filasMostrar - 1 do
    begin
      filaGrid := filaDatos + 1;
      for col := 0 to TotalColumnas - 1 do
      begin
        if (filaDatos < Length(Matriz)) and (col < Length(Matriz[filaDatos])) then
          Grid.Cells[col, filaGrid] := Matriz[filaDatos][col]
        else
          Grid.Cells[col, filaGrid] := '';
      end;
    end;
  finally
    Grid.EndUpdate;
  end;
end;

end.

