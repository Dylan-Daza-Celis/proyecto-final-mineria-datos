unit Agrupamiento;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Matrices, Grids;

type
  TCluster = record
    Elementos: array of Integer;
  end;

  TArregloClusters = array of TCluster;

  TMatrizReal = array of TArregloDouble;
  TArregloEntero = Matrices.TArregloEntero;

  TResultadoAGNES = record
    ClusterPorRegistro: TArregloEntero;
    NumClusters: Integer;
  end;

procedure ExtraerDatosNumericosLimpios(
  Grid: TStringGrid;
  IndiceColumnaClase: Integer;
  out DatosLimpios: TMatrizReal;
  out FilasOriginales: TArregloEntero;
  out ColumnasNumericas: TArregloEntero;
  out TotalNumericas: Integer
);

procedure DetectarColumnasNumericas(const Datos: TMatrizString;
  TotalColumnas: Integer; IndiceColumnaClase: Integer;
  out ColumnasNumericas: TArregloEntero; out TotalNumericas: Integer);

function DistanciaEuclidiana(const Datos: TMatrizReal;
  fila1, fila2: Integer;
  const ColumnasNumericas: array of Integer): Double;

function DistanciaClustersSingleLinkage(const Datos: TMatrizReal;
  const Cluster1, Cluster2: TCluster;
  const ColumnasNumericas: array of Integer): Double;

function EjecutarAGNES(const Datos: TMatrizReal; NumClusters: Integer;
  const ColumnasNumericas: array of Integer): TResultadoAGNES; overload;

function EjecutarAGNES(const Datos: TMatrizString; NumClusters: Integer;
  const ColumnasNumericas: array of Integer): TResultadoAGNES; overload;

implementation

function TryConvertirFloat(const Texto: string; out Valor: Double): Boolean;
var
  formatos: TFormatSettings;
begin
  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';
  Result := TryStrToFloat(Trim(Texto), Valor, formatos);
end;

procedure ExtraerDatosNumericosLimpios(
  Grid: TStringGrid;
  IndiceColumnaClase: Integer;
  out DatosLimpios: TMatrizReal;
  out FilasOriginales: TArregloEntero;
  out ColumnasNumericas: TArregloEntero;
  out TotalNumericas: Integer
);
var
  fila: Integer;
  col: Integer;
  primeracelda: string;
  esFilaEstadistica: Boolean;
  valor: Double;
  formatos: TFormatSettings;
  filasValidas: array of Integer;
  totalFilasValidas: Integer;
  columnasValidas: array of Boolean;
  columnasValidasCount: Integer;
  conteoNumericos: array of Integer;
  porcentajeNumerico: Double;
  i: Integer;
  j: Integer;
begin
  SetLength(DatosLimpios, 0);
  SetLength(FilasOriginales, 0);
  SetLength(ColumnasNumericas, 0);
  TotalNumericas := 0;

  if Grid = nil then
    Exit;

  if (Grid.RowCount <= 1) or (Grid.ColCount <= 1) then
    Exit;

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  // Paso 1: Identificar filas válidas (ignorar encabezados y estadísticas)
  SetLength(filasValidas, 0);
  totalFilasValidas := 0;

  for fila := 1 to Grid.RowCount - 1 do
  begin
    if Grid.RowCount <= fila then
      Break;

    primeracelda := LowerCase(Trim(Grid.Cells[0, fila]));

    esFilaEstadistica := False;

    if (primeracelda = 'media') or
       (primeracelda = 'desvstd') or
       (primeracelda = 'desv std') or
       (primeracelda = '') then
      esFilaEstadistica := True;

    if not esFilaEstadistica then
    begin
      SetLength(filasValidas, totalFilasValidas + 1);
      filasValidas[totalFilasValidas] := fila;
      Inc(totalFilasValidas);
    end;
  end;

  if totalFilasValidas < 2 then
    Exit;

  // Paso 2: Detectar columnas numéricas (>= 80% de valores numéricos)
  SetLength(columnasValidas, Grid.ColCount);
  SetLength(conteoNumericos, Grid.ColCount);

  for col := 0 to Grid.ColCount - 1 do
  begin
    columnasValidas[col] := False;
    conteoNumericos[col] := 0;
  end;

  for col := 0 to IndiceColumnaClase - 1 do
  begin
    conteoNumericos[col] := 0;

    for i := 0 to totalFilasValidas - 1 do
    begin
      fila := filasValidas[i];
      if TryStrToFloat(Trim(Grid.Cells[col, fila]), valor, formatos) then
        Inc(conteoNumericos[col]);
    end;

    porcentajeNumerico := conteoNumericos[col] / totalFilasValidas;

    if porcentajeNumerico >= 0.8 then
      columnasValidas[col] := True;
  end;

  // Contar columnas numéricas válidas
  columnasValidasCount := 0;
  for col := 0 to IndiceColumnaClase - 1 do
  begin
    if columnasValidas[col] then
      Inc(columnasValidasCount);
  end;

  if columnasValidasCount < 1 then
    Exit;

  // Paso 3: Construir arreglo de columnas numéricas
  SetLength(ColumnasNumericas, columnasValidasCount);
  TotalNumericas := 0;

  for col := 0 to IndiceColumnaClase - 1 do
  begin
    if columnasValidas[col] then
    begin
      ColumnasNumericas[TotalNumericas] := col;
      Inc(TotalNumericas);
    end;
  end;

  // Paso 4: Construir matriz limpia
  SetLength(DatosLimpios, totalFilasValidas);
  SetLength(FilasOriginales, totalFilasValidas);

  for i := 0 to totalFilasValidas - 1 do
  begin
    fila := filasValidas[i];
    SetLength(DatosLimpios[i], TotalNumericas);
    FilasOriginales[i] := i;

    for j := 0 to TotalNumericas - 1 do
    begin
      col := ColumnasNumericas[j];
      if TryStrToFloat(Trim(Grid.Cells[col, fila]), valor, formatos) then
        DatosLimpios[i][j] := valor
      else
        DatosLimpios[i][j] := 0;
    end;
  end;

  SetLength(filasValidas, 0);
  SetLength(columnasValidas, 0);
  SetLength(conteoNumericos, 0);
end;

procedure DetectarColumnasNumericas(const Datos: TMatrizString;
  TotalColumnas: Integer; IndiceColumnaClase: Integer;
  out ColumnasNumericas: TArregloEntero; out TotalNumericas: Integer);
var
  col: Integer;
  fila: Integer;
  columnasALeer: Integer;
  conteoNumericos: Integer;
  valor: Double;
begin
  SetLength(ColumnasNumericas, 0);
  TotalNumericas := 0;

  if (Length(Datos) = 0) or (TotalColumnas <= 0) then
    Exit;

  columnasALeer := IndiceColumnaClase;
  if (columnasALeer < 0) or (columnasALeer > TotalColumnas) then
    columnasALeer := TotalColumnas;

  for col := 0 to columnasALeer - 1 do
  begin
    conteoNumericos := 0;

    for fila := 0 to High(Datos) do
    begin
      if (col < Length(Datos[fila])) and TryConvertirFloat(Datos[fila][col], valor) then
        Inc(conteoNumericos);
    end;

    if (Length(Datos) > 0) and ((conteoNumericos / Length(Datos)) >= 0.8) then
    begin
      SetLength(ColumnasNumericas, TotalNumericas + 1);
      ColumnasNumericas[TotalNumericas] := col;
      Inc(TotalNumericas);
    end;
  end;
end;

function DistanciaEuclidiana(const Datos: TMatrizReal;
  fila1, fila2: Integer;
  const ColumnasNumericas: array of Integer): Double;
var
  i: Integer;
  valor1: Double;
  valor2: Double;
  sumaDistancias: Double;
begin
  Result := 0;
  sumaDistancias := 0;

  if (fila1 < 0) or (fila2 < 0) or (fila1 >= Length(Datos)) or (fila2 >= Length(Datos)) then
    Exit;

  if Length(ColumnasNumericas) = 0 then
    Exit;

  if (Length(Datos[fila1]) = 0) or (Length(Datos[fila2]) = 0) then
    Exit;

  for i := 0 to High(ColumnasNumericas) do
  begin
    if (ColumnasNumericas[i] >= 0) and (ColumnasNumericas[i] < Length(Datos[fila1])) and
       (ColumnasNumericas[i] < Length(Datos[fila2])) then
    begin
      valor1 := Datos[fila1][ColumnasNumericas[i]];
      valor2 := Datos[fila2][ColumnasNumericas[i]];
      sumaDistancias := sumaDistancias + (valor1 - valor2) * (valor1 - valor2);
    end;
  end;

  Result := Sqrt(sumaDistancias);
end;

function DistanciaClustersSingleLinkage(const Datos: TMatrizReal;
  const Cluster1, Cluster2: TCluster;
  const ColumnasNumericas: array of Integer): Double;
var
  i: Integer;
  j: Integer;
  distancia: Double;
  distanciaMinima: Double;
begin
  Result := 1e308;
  distanciaMinima := 1e308;

  if (Length(Cluster1.Elementos) = 0) or (Length(Cluster2.Elementos) = 0) then
    Exit;

  for i := 0 to High(Cluster1.Elementos) do
  begin
    for j := 0 to High(Cluster2.Elementos) do
    begin
      distancia := DistanciaEuclidiana(Datos, Cluster1.Elementos[i],
        Cluster2.Elementos[j], ColumnasNumericas);

      if distancia < distanciaMinima then
        distanciaMinima := distancia;
    end;
  end;

  Result := distanciaMinima;
end;

function EjecutarAGNES(const Datos: TMatrizReal; NumClusters: Integer;
  const ColumnasNumericas: array of Integer): TResultadoAGNES; overload;
var
  clusters: TArregloClusters;
  cantidadClusters: Integer;
  i: Integer;
  j: Integer;
  k: Integer;
  cluster1Idx: Integer;
  cluster2Idx: Integer;
  minDistancia: Double;
  distancia: Double;
  filaActual: Integer;
begin
  Result := Default(TResultadoAGNES);
  SetLength(clusters, 0);

  if (Length(Datos) <= 1) or (NumClusters < 1) then
    Exit;

  filaActual := Length(Datos);

  if NumClusters > filaActual then
    NumClusters := filaActual;

  if NumClusters < 1 then
    Exit;

  // Inicializar: cada fila es su propio cluster
  SetLength(clusters, filaActual);
  cantidadClusters := filaActual;

  for i := 0 to filaActual - 1 do
  begin
    SetLength(clusters[i].Elementos, 1);
    clusters[i].Elementos[0] := i;
  end;

  // Aglomeración jerárquica
  while cantidadClusters > NumClusters do
  begin
    cluster1Idx := 0;
    cluster2Idx := 1;
    minDistancia := 1e308;

    // Encontrar los dos clusters más cercanos
    for i := 0 to cantidadClusters - 2 do
    begin
      for j := i + 1 to cantidadClusters - 1 do
      begin
        distancia := DistanciaClustersSingleLinkage(Datos, clusters[i],
          clusters[j], ColumnasNumericas);

        if distancia < minDistancia then
        begin
          minDistancia := distancia;
          cluster1Idx := i;
          cluster2Idx := j;
        end;
      end;
    end;

    // Fusionar cluster2Idx en cluster1Idx
    SetLength(clusters[cluster1Idx].Elementos,
      Length(clusters[cluster1Idx].Elementos) + Length(clusters[cluster2Idx].Elementos));

    for i := 0 to High(clusters[cluster2Idx].Elementos) do
    begin
      clusters[cluster1Idx].Elementos[Length(clusters[cluster1Idx].Elementos) -
        Length(clusters[cluster2Idx].Elementos) + i] := clusters[cluster2Idx].Elementos[i];
    end;

    // Desplazar clusters para eliminar el fusionado
    for i := cluster2Idx to cantidadClusters - 2 do
      clusters[i] := clusters[i + 1];

    Dec(cantidadClusters);
  end;

  // Construir resultado: mapear cada fila al cluster al que pertenece
  SetLength(Result.ClusterPorRegistro, filaActual);

  for i := 0 to cantidadClusters - 1 do
  begin
    for j := 0 to High(clusters[i].Elementos) do
    begin
      k := clusters[i].Elementos[j];
      if (k >= 0) and (k < filaActual) then
        Result.ClusterPorRegistro[k] := i;
    end;
  end;

  Result.NumClusters := cantidadClusters;
  SetLength(clusters, 0);
end;

function EjecutarAGNES(const Datos: TMatrizString; NumClusters: Integer;
  const ColumnasNumericas: array of Integer): TResultadoAGNES; overload;
var
  datosReales: TMatrizReal;
  fila: Integer;
  col: Integer;
  valor: Double;
begin
  Result := Default(TResultadoAGNES);

  if Length(Datos) = 0 then
    Exit;

  SetLength(datosReales, Length(Datos));

  for fila := 0 to High(Datos) do
  begin
    SetLength(datosReales[fila], Length(Datos[fila]));

    for col := 0 to High(Datos[fila]) do
    begin
      if TryConvertirFloat(Datos[fila][col], valor) then
        datosReales[fila][col] := valor
      else
        datosReales[fila][col] := 0;
    end;
  end;

  Result := EjecutarAGNES(datosReales, NumClusters, ColumnasNumericas);
  SetLength(datosReales, 0);
end;

end.
