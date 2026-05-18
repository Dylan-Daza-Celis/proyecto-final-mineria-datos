unit Agnes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, ExtCtrls, StdCtrls, Dialogs, Matrices, Graficas,
  Agrupamiento;

//Validamos entradas, ejecutamos AGNES y preparamos la dispersion coloreada.
procedure EjecutarAGNESConGrafica(
  const Grid: TStringGrid;
  const NombresColumnas: TNombresColumnas;
  const TotalFilasDatos: Integer;
  const ColX, ColY, NumClusters: Integer;
  const PaintBox: TPaintBox;
  const Memo: TMemo;
  out Resultado: Agrupamiento.TResultadoAGNES
);

implementation

procedure EjecutarAGNESConGrafica(
  const Grid: TStringGrid;
  const NombresColumnas: TNombresColumnas;
  const TotalFilasDatos: Integer;
  const ColX, ColY, NumClusters: Integer;
  const PaintBox: TPaintBox;
  const Memo: TMemo;
  out Resultado: Agrupamiento.TResultadoAGNES
);
var
  conteoClusters: array of Integer;
  clustersDispersion: TArregloEntero;
  dispersionX: TArregloDouble;
  dispersionY: TArregloDouble;
  dispersionMinX: Double;
  dispersionMaxX: Double;
  dispersionMinY: Double;
  dispersionMaxY: Double;
  dispersionLabelX: string;
  dispersionLabelY: string;
  formatos: TFormatSettings;
  valorX: Double;
  valorY: Double;
  puntos: Integer;
  fila: Integer;
  filaGrid: Integer;
  i: Integer;
begin
  Resultado := Default(Agrupamiento.TResultadoAGNES);

  if TotalFilasDatos <= 0 then
  begin
    ShowMessage('No hay datos cargados. Cargue un conjunto de datos primero.');
    Exit;
  end;

  if NumClusters < 1 then
  begin
    ShowMessage('El numero de clusters debe ser mayor o igual a 1.');
    Exit;
  end;

  if (ColX < 0) or (ColY < 0) then
  begin
    ShowMessage('Seleccione ambas columnas para visualizar los clusters.');
    Exit;
  end;

  if ColX = ColY then
  begin
    ShowMessage('Seleccione columnas diferentes.');
    Exit;
  end;

  if (Grid = nil) or (ColX >= Grid.ColCount - 1) or (ColY >= Grid.ColCount - 1) then
  begin
    ShowMessage('Las columnas seleccionadas no son validas.');
    Exit;
  end;

  Resultado := Agrupamiento.EjecutarAGNES(Grid, NumClusters);

  if Resultado.NumClusters = 0 then
  begin
    if Resultado.MensajeError <> '' then
      ShowMessage(Resultado.MensajeError)
    else
      ShowMessage('Error ejecutando AGNES.');
    Exit;
  end;

  SetLength(conteoClusters, Resultado.NumClusters);
  for i := 0 to Resultado.NumClusters - 1 do
    conteoClusters[i] := 0;

  for i := 0 to High(Resultado.ClusterPorRegistro) do
  begin
    if (Resultado.ClusterPorRegistro[i] >= 0) and
       (Resultado.ClusterPorRegistro[i] < Resultado.NumClusters) then
      Inc(conteoClusters[Resultado.ClusterPorRegistro[i]]);
  end;

  SetLength(dispersionX, 0);
  SetLength(dispersionY, 0);
  SetLength(clustersDispersion, 0);

  if ColX < Length(NombresColumnas) then
    dispersionLabelX := NombresColumnas[ColX]
  else
    dispersionLabelX := 'Columna ' + IntToStr(ColX + 1);

  if ColY < Length(NombresColumnas) then
    dispersionLabelY := NombresColumnas[ColY]
  else
    dispersionLabelY := 'Columna ' + IntToStr(ColY + 1);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  puntos := 0;

  for fila := 0 to High(Resultado.FilasOriginales) do
  begin
    filaGrid := Resultado.FilasOriginales[fila];

    if (filaGrid < 0) or (filaGrid >= Grid.RowCount) then
      Continue;

    if not TryStrToFloat(Trim(Grid.Cells[ColX, filaGrid]), valorX, formatos) then
      Continue;

    if not TryStrToFloat(Trim(Grid.Cells[ColY, filaGrid]), valorY, formatos) then
      Continue;

    Inc(puntos);
    SetLength(dispersionX, puntos);
    SetLength(dispersionY, puntos);
    SetLength(clustersDispersion, puntos);

    dispersionX[puntos - 1] := valorX;
    dispersionY[puntos - 1] := valorY;
    clustersDispersion[puntos - 1] := Resultado.ClusterPorRegistro[fila];

    if puntos = 1 then
    begin
      dispersionMinX := valorX;
      dispersionMaxX := valorX;
      dispersionMinY := valorY;
      dispersionMaxY := valorY;
    end
    else
    begin
      if valorX < dispersionMinX then
        dispersionMinX := valorX;
      if valorX > dispersionMaxX then
        dispersionMaxX := valorX;
      if valorY < dispersionMinY then
        dispersionMinY := valorY;
      if valorY > dispersionMaxY then
        dispersionMaxY := valorY;
    end;
  end;

  if puntos = 0 then
  begin
    ShowMessage('No hay datos numericos validos para visualizar.');
    Exit;
  end;

  Graficas.MostrarGraficaClusters(PaintBox, dispersionX, dispersionY,
    dispersionMinX, dispersionMaxX, dispersionMinY, dispersionMaxY,
    dispersionLabelX, dispersionLabelY, clustersDispersion);

  if Memo <> nil then
  begin
    Memo.Lines.Clear;
    Memo.Lines.Add('========== AGNES - AGGLOMERATIVE HIERARCHICAL CLUSTERING ==========');
    Memo.Lines.Add('');
    Memo.Lines.Add('Configuracion:');
    Memo.Lines.Add('  Numero de clusters solicitados: ' + IntToStr(NumClusters));
    Memo.Lines.Add('  Numero de clusters generados: ' + IntToStr(Resultado.NumClusters));
    Memo.Lines.Add('  Total registros limpios: ' + IntToStr(Length(Resultado.FilasOriginales)));
    Memo.Lines.Add('  Atributos numericos usados: ' + IntToStr(Length(Resultado.ColumnasNumericas)));
    Memo.Lines.Add('  Metodo: Single Linkage');
    Memo.Lines.Add('');
    Memo.Lines.Add('Distribucion de clusters:');

    for i := 0 to Resultado.NumClusters - 1 do
    begin
      Memo.Lines.Add('  Cluster ' + IntToStr(i) + ' -> ' +
        IntToStr(conteoClusters[i]) + ' elementos');
    end;

    Memo.Lines.Add('');
    Memo.Lines.Add('Visualizacion: scatter plot coloreado por cluster');
  end;

  SetLength(conteoClusters, 0);
  SetLength(clustersDispersion, 0);
end;

end.

