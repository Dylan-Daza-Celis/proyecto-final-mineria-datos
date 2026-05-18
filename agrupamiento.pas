unit Agrupamiento;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids;

type
  TMatrizReal = array of array of Double;
  TArregloInteger = array of Integer;

  TCluster = record
    Elementos: TArregloInteger;
  end;

  TArregloClusters = array of TCluster;

  TResultadoAGNES = record
    ClusterPorRegistro: TArregloInteger;
    FilasOriginales: TArregloInteger;
    ColumnasNumericas: TArregloInteger;
    NumClusters: Integer;
    MensajeError: string;
  end;

procedure ExtraerDatosNumericosLimpios(
  Grid: TStringGrid;
  out DatosLimpios: TMatrizReal;
  out FilasOriginales: TArregloInteger;
  out ColumnasNumericas: TArregloInteger
);

function EjecutarAGNES(Grid: TStringGrid; K: Integer): TResultadoAGNES;

implementation

function EsNumero(const Texto: string; out Valor: Double): Boolean;
var
  formatos: TFormatSettings;
begin
  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';
  Result := TryStrToFloat(Trim(Texto), Valor, formatos);
end;

function EsFilaIgnorable(const Grid: TStringGrid; Fila: Integer): Boolean;
var
  primerValor: string;
begin
  primerValor := LowerCase(Trim(Grid.Cells[0, Fila]));
  Result := (primerValor = '') or (primerValor = 'media') or
    (primerValor = 'desvstd');
end;

procedure ExtraerDatosNumericosLimpios(
  Grid: TStringGrid;
  out DatosLimpios: TMatrizReal;
  out FilasOriginales: TArregloInteger;
  out ColumnasNumericas: TArregloInteger
);
var
  filasValidas: TArregloInteger;
  columnasValidas: array of Boolean;
  totalFilasValidas: Integer;
  totalColumnasNumericas: Integer;
  ultimaColumnaDatos: Integer;
  fila: Integer;
  col: Integer;
  i: Integer;
  j: Integer;
  conteoNumericos: Integer;
  valor: Double;
begin
  DatosLimpios := nil;
  FilasOriginales := nil;
  ColumnasNumericas := nil;

  if (Grid = nil) or (Grid.RowCount <= 1) or (Grid.ColCount <= 1) then
    Exit;

  totalFilasValidas := 0;
  SetLength(filasValidas, 0);

  for fila := 1 to Grid.RowCount - 1 do
  begin
    if EsFilaIgnorable(Grid, fila) then
      Continue;

    SetLength(filasValidas, totalFilasValidas + 1);
    filasValidas[totalFilasValidas] := fila;
    Inc(totalFilasValidas);
  end;

  if totalFilasValidas = 0 then
    Exit;

  ultimaColumnaDatos := Grid.ColCount - 2;
  if ultimaColumnaDatos < 0 then
    Exit;

  SetLength(columnasValidas, Grid.ColCount);
  totalColumnasNumericas := 0;

  for col := 0 to ultimaColumnaDatos do
  begin
    conteoNumericos := 0;

    for i := 0 to totalFilasValidas - 1 do
    begin
      fila := filasValidas[i];
      if EsNumero(Grid.Cells[col, fila], valor) then
        Inc(conteoNumericos);
    end;

    columnasValidas[col] := (conteoNumericos / totalFilasValidas) >= 0.8;
    if columnasValidas[col] then
      Inc(totalColumnasNumericas);
  end;

  if totalColumnasNumericas = 0 then
    Exit;

  SetLength(ColumnasNumericas, totalColumnasNumericas);
  j := 0;
  for col := 0 to ultimaColumnaDatos do
  begin
    if columnasValidas[col] then
    begin
      ColumnasNumericas[j] := col;
      Inc(j);
    end;
  end;

  SetLength(DatosLimpios, totalFilasValidas);
  SetLength(FilasOriginales, totalFilasValidas);

  for i := 0 to totalFilasValidas - 1 do
  begin
    fila := filasValidas[i];
    FilasOriginales[i] := fila;
    SetLength(DatosLimpios[i], totalColumnasNumericas);

    for j := 0 to totalColumnasNumericas - 1 do
    begin
      col := ColumnasNumericas[j];
      if EsNumero(Grid.Cells[col, fila], valor) then
        DatosLimpios[i][j] := valor
      else
        DatosLimpios[i][j] := 0;
    end;
  end;
end;

function DistanciaEuclidiana(const Datos: TMatrizReal;
  Fila1, Fila2: Integer): Double;
var
  i: Integer;
  diferencia: Double;
begin
  Result := 0;

  if (Fila1 < 0) or (Fila2 < 0) or
    (Fila1 >= Length(Datos)) or (Fila2 >= Length(Datos)) then
    Exit;

  for i := 0 to High(Datos[Fila1]) do
  begin
    if i > High(Datos[Fila2]) then
      Break;

    diferencia := Datos[Fila1][i] - Datos[Fila2][i];
    Result := Result + diferencia * diferencia;
  end;

  Result := Sqrt(Result);
end;

function DistanciaClustersSingleLinkage(const Datos: TMatrizReal;
  const Cluster1, Cluster2: TCluster): Double;
var
  i: Integer;
  j: Integer;
  distancia: Double;
begin
  Result := 1e308;

  for i := 0 to High(Cluster1.Elementos) do
  begin
    for j := 0 to High(Cluster2.Elementos) do
    begin
      distancia := DistanciaEuclidiana(Datos, Cluster1.Elementos[i],
        Cluster2.Elementos[j]);
      if distancia < Result then
        Result := distancia;
    end;
  end;
end;

function EjecutarAGNESLimpio(const Datos: TMatrizReal; K: Integer): TArregloInteger;
var
  clusters: TArregloClusters;
  cantidadClusters: Integer;
  i: Integer;
  j: Integer;
  kElemento: Integer;
  cluster1Idx: Integer;
  cluster2Idx: Integer;
  minDistancia: Double;
  distancia: Double;
  inicioFusion: Integer;
begin
  Result := nil;

  SetLength(clusters, Length(Datos));
  cantidadClusters := Length(Datos);

  for i := 0 to High(Datos) do
  begin
    SetLength(clusters[i].Elementos, 1);
    clusters[i].Elementos[0] := i;
  end;

  while cantidadClusters > K do
  begin
    cluster1Idx := 0;
    cluster2Idx := 1;
    minDistancia := 1e308;

    for i := 0 to cantidadClusters - 2 do
    begin
      for j := i + 1 to cantidadClusters - 1 do
      begin
        distancia := DistanciaClustersSingleLinkage(Datos, clusters[i], clusters[j]);
        if distancia < minDistancia then
        begin
          minDistancia := distancia;
          cluster1Idx := i;
          cluster2Idx := j;
        end;
      end;
    end;

    inicioFusion := Length(clusters[cluster1Idx].Elementos);
    SetLength(clusters[cluster1Idx].Elementos,
      inicioFusion + Length(clusters[cluster2Idx].Elementos));

    for i := 0 to High(clusters[cluster2Idx].Elementos) do
      clusters[cluster1Idx].Elementos[inicioFusion + i] :=
        clusters[cluster2Idx].Elementos[i];

    for i := cluster2Idx to cantidadClusters - 2 do
      clusters[i] := clusters[i + 1];

    Dec(cantidadClusters);
  end;

  SetLength(Result, Length(Datos));
  for i := 0 to High(Result) do
    Result[i] := -1;

  for i := 0 to cantidadClusters - 1 do
  begin
    for j := 0 to High(clusters[i].Elementos) do
    begin
      kElemento := clusters[i].Elementos[j];
      if (kElemento >= 0) and (kElemento < Length(Result)) then
        Result[kElemento] := i;
    end;
  end;
end;

function EjecutarAGNES(Grid: TStringGrid; K: Integer): TResultadoAGNES;
var
  datosLimpios: TMatrizReal;
begin
  Result := Default(TResultadoAGNES);

  ExtraerDatosNumericosLimpios(Grid, datosLimpios, Result.FilasOriginales,
    Result.ColumnasNumericas);

  if Length(Result.ColumnasNumericas) < 2 then
  begin
    Result.MensajeError :=
      'El dataset no contiene suficientes atributos numéricos válidos para AGNES.';
    Exit;
  end;

  if Length(datosLimpios) < 2 then
  begin
    Result.MensajeError :=
      'El dataset no contiene suficientes filas válidas para AGNES.';
    Exit;
  end;

  if (K < 1) or (K > Length(datosLimpios)) then
  begin
    Result.MensajeError :=
      'El número de clusters debe estar entre 1 y ' +
      IntToStr(Length(datosLimpios)) + '.';
    Exit;
  end;

  Result.ClusterPorRegistro := EjecutarAGNESLimpio(datosLimpios, K);
  Result.NumClusters := K;
end;

end.
