unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, Grids,
  Buttons, ExtCtrls, Spin, Math, Matrices, Estadisticas, Normalizacion,
  NaiveBayes, Graficas;

type

  { TForm1 }

  TTipoEstadistica = Matrices.TTipoEstadistica;
  TTipoGrafica = Matrices.TTipoGrafica;
  TTipoNormalizacion = Matrices.TTipoNormalizacion;
  TMatrizString = Matrices.TMatrizString;
  TArregloDouble = Matrices.TArregloDouble;
  TArregloBool = Matrices.TArregloBool;
  TArregloEntero = Matrices.TArregloEntero;
  TArregloEntero2D = Matrices.TArregloEntero2D;
  TArregloDoble2D = Matrices.TArregloDoble2D;
  TArregloString = Matrices.TArregloString;
  TNombresColumnas = Matrices.TNombresColumnas;

  TForm1 = class(TForm)
    btnCargarArchivos: TButton;
    btnOriginales: TButton;
    btnNormalizados: TButton;
    btnExportarNormalizados: TButton;
    btnMedia: TButton;
    btnMediana: TButton;
    btnDesviacion: TButton;
    btnGraficar: TButton;
    btnCargarPrueba: TButton;
    btnEvaluarPrueba: TButton;
    btnKFolds: TButton;
    cBoxColumnaA: TComboBox;
    cBoxColumnaB: TComboBox;
    cmbMetodoNormalizacion: TComboBox;
    dialogoAbrirArchivo: TOpenDialog;
    memoEvaluacion: TMemo;
    saveDialogExportar: TSaveDialog;
    cmbTipoGrafica: TComboBox;
    Edit1: TEdit;
    gridDatos: TStringGrid;
    gridResultados: TStringGrid;
    paintBoxClases: TPaintBox;
    ScrollBar1: TScrollBar;
    spinKFolds: TSpinEdit;
    gridKFolds: TStringGrid;
    procedure btnCargarArchivosClick(Sender: TObject);
    procedure btnCargarPruebaClick(Sender: TObject);
    procedure btnOriginalesClick(Sender: TObject);
    procedure btnNormalizadosClick(Sender: TObject);
    procedure btnExportarNormalizadosClick(Sender: TObject);
    procedure btnGraficarClick(Sender: TObject);
    procedure btnEvaluarPruebaClick(Sender: TObject);
    procedure btnKFoldsClick(Sender: TObject);
    procedure btnMediaClick(Sender: TObject);
    procedure btnMedianaClick(Sender: TObject);
    procedure btnDesviacionClick(Sender: TObject);
    procedure cBoxColumnaAChange(Sender: TObject);
    procedure cBoxColumnaBChange(Sender: TObject);
    procedure cmbTipoGraficaChange(Sender: TObject);
    procedure cmbMetodoNormalizacionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CargarGridDatos(const NombreArchivo: string);
    function DetectarDelimitador(const Linea: string): Char;
    procedure paintBoxClasesClick(Sender: TObject);
    procedure paintBoxClasesPaint(Sender: TObject);
    procedure CargarComboBoxColumnas;
    procedure ValidarColumnasSeleccionadas(Sender: TObject);
    procedure ActualizarControlesGrafica;
  private
    matrizDatosOriginales: TMatrizString;
    matrizDatosNormalizados: TMatrizString;
    matrizDatosPrueba: TMatrizString;
    matrizDatosPruebaNormalizados: TMatrizString;
    nombresColumnas: TNombresColumnas;
    nombresColumnasPrueba: TNombresColumnas;
    indiceColumnaClase: Integer;
    indiceColumnaClasePrueba: Integer;
    totalFilasDatos: Integer;
    totalColumnasDatos: Integer;
    totalFilasPrueba: Integer;
    totalColumnasPrueba: Integer;
    delimitadorArchivo: Char;
    delimitadorArchivoPrueba: Char;
    tipoGraficaActual: TTipoGrafica;
    etiquetasClases: TStringList;
    conteosClases: TArregloEntero;
    maxConteoClases: Integer;
    dispersionX: TArregloDouble;
    dispersionY: TArregloDouble;
    dispersionMinX: Double;
    dispersionMaxX: Double;
    dispersionMinY: Double;
    dispersionMaxY: Double;
    dispersionLabelX: string;
    dispersionLabelY: string;
    nbClases: TStringList;
    nbPriors: TArregloDouble;
    nbMedias: TArregloDoble2D;
    nbDesv: TArregloDoble2D;
    nbConteos: TArregloEntero;
    nbNumAtributos: Integer;
    nbEntrenado: Boolean;
    nbModelo: NaiveBayes.TNaiveBayesModel;
    minValoresNormalizacion: TArregloDouble;
    maxValoresNormalizacion: TArregloDouble;
    mediasNormalizacion: TArregloDouble;
    desviacionesNormalizacion: TArregloDouble;
    factoresDecimalScaling: TArregloEntero;
    tipoNormalizacionActual: TTipoNormalizacion;
    boxLabels: TStringList;
    boxMin: TArregloDouble;
    boxQ1: TArregloDouble;
    boxMed: TArregloDouble;
    boxQ3: TArregloDouble;
    boxMax: TArregloDouble;
    procedure CargarGridDesdeMatriz(const Matriz: TMatrizString);
    procedure CargarDatosDesdeCSV(const NombreArchivo: string;
      out Matriz: TMatrizString; out Nombres: TNombresColumnas;
      out TotalFilas, TotalColumnas, IndiceClase: Integer; out Delimitador: Char);
    procedure CargarDatosPrueba(const NombreArchivo: string);
    procedure ContarClases(out Etiquetas: TStringList; out Conteos: TArregloEntero);
    procedure ObtenerClasesUnicas(out Clases: TStringList; out Conteos: TArregloEntero);
    procedure PrepararGraficaClases;
    procedure PrepararGraficaDispersion;
    procedure PrepararGraficaBoxPlot;
    procedure DibujarGraficaClases;
    procedure DibujarGraficaDispersion;
    procedure DibujarGraficaBoxPlot;
    procedure LimpiarGrafica(const Mensaje: string);
    procedure AplicarNormalizacionActual;
    { Normalization moved to Normalizacion.pas - keep state only in this form }
    function NormalizadosDisponibles: Boolean;
    procedure ExportarMatrizCSV(const Matriz: TMatrizString);
    procedure LeerNombresColumnas(const LineaAtributos: string;
      const TotalColumnas: Integer; const Delimitador: Char);
    procedure OrdenarValores(var Valores: TArregloDouble);
    procedure CalcularMediaDesviacionMuestral(const Valores: TArregloDouble;
      out Media, Desviacion: Double);
    procedure CalcularMediaDesviacionPoblacional(const Valores: TArregloDouble;
      out Media, Desviacion: Double);
    procedure CalcularEstadisticasNumericas(out Medias, Medianas,
      Desviaciones: TArregloDouble; out ColumnasCalculadas: TArregloBool);
    procedure AgregarFilaEstadistica(const Valores: TArregloDouble;
      const ColumnasCalculadas: TArregloBool; const FilaDestino: Integer);
    procedure EjecutarEstadistica(const Tipo: TTipoEstadistica);
    procedure EntrenarNaiveBayes;
    function ProbabilidadGaussiana(const X, Media, Desv: Double): Double;
    procedure ObtenerProbabilidadesPorClase(const Registro: TArregloDouble;
      out Probabilidades: TArregloDouble);
    function ClasificarRegistro(const Registro: TArregloDouble;
      out Probabilidades: TArregloDouble): string;
    function ObtenerIndiceClase(const Clase: string;
      const Clases: TStringList): Integer;
    procedure ConstruirMatrizConfusion(const ClasesReales,
      ClasesPredichas: TArregloString; out ClasesUnicas: TStringList;
      out MatrizConfusion: TArregloEntero2D);
    procedure MostrarMatrizConfusion(const ClasesUnicas: TStringList;
      const MatrizConfusion: TArregloEntero2D);
    procedure EvaluarConjuntoPrueba;
    procedure InicializarGridResultados;


  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  totalFilasDatos := 0;
  totalColumnasDatos := 0;
  totalFilasPrueba := 0;
  totalColumnasPrueba := 0;
  indiceColumnaClase := -1;
  indiceColumnaClasePrueba := -1;
  SetLength(matrizDatosOriginales, 0);
  SetLength(matrizDatosNormalizados, 0);
  SetLength(matrizDatosPrueba, 0);
  SetLength(matrizDatosPruebaNormalizados, 0);
  SetLength(minValoresNormalizacion, 0);
  SetLength(maxValoresNormalizacion, 0);
  delimitadorArchivo := ',';
  delimitadorArchivoPrueba := ',';
  tipoGraficaActual := tgNinguna;
  etiquetasClases := nil;
  boxLabels := nil;
  dispersionLabelX := '';
  dispersionLabelY := '';
  nbClases := nil;
  nbNumAtributos := 0;
  nbEntrenado := False;
  NaiveBayes.InicializarModeloNaiveBayes(nbModelo);
  SetLength(nbPriors, 0);
  SetLength(nbMedias, 0);
  SetLength(nbDesv, 0);
  SetLength(nbConteos, 0);
  cmbTipoGrafica.Items.Clear;
  cmbTipoGrafica.Items.Add('Ninguna');
  cmbTipoGrafica.Items.Add('Barras');
  cmbTipoGrafica.Items.Add('Dispersion');
  cmbTipoGrafica.Items.Add('BoxPlot');
  cmbTipoGrafica.ItemIndex := 0;
  cmbMetodoNormalizacion.Items.Clear;
  cmbMetodoNormalizacion.Items.Add('Min-Max');
  cmbMetodoNormalizacion.Items.Add('Z-Score');
  cmbMetodoNormalizacion.Items.Add('Decimal Scaling');
  cmbMetodoNormalizacion.ItemIndex := 0;
  tipoNormalizacionActual := tnMinMax;
  cBoxColumnaA.Items.Clear;
  cBoxColumnaB.Items.Clear;
  cBoxColumnaA.Enabled := False;
  cBoxColumnaB.Enabled := False;
  cBoxColumnaA.Visible := False;
  cBoxColumnaB.Visible := False;
  InicializarGridResultados;
  ActualizarControlesGrafica;
end;

procedure TForm1.btnCargarPruebaClick(Sender: TObject);
begin
  dialogoAbrirArchivo.Title := 'Seleccionar conjunto de prueba';
  dialogoAbrirArchivo.Filter := 'CSV o TXT (*.csv;*.txt)|*.csv;*.txt|Todos los archivos|*.*';
  dialogoAbrirArchivo.Options := dialogoAbrirArchivo.Options + [ofFileMustExist, ofPathMustExist];
  if dialogoAbrirArchivo.Execute then
    CargarDatosPrueba(dialogoAbrirArchivo.FileName);
end;

procedure TForm1.btnEvaluarPruebaClick(Sender: TObject);
begin
  EvaluarConjuntoPrueba;
end;

procedure TForm1.btnKFoldsClick(Sender: TObject);
var
  numFolds: Integer;
  resultadoKFold: NaiveBayes.TResultadoKFold;
  mensajeValidacion: string;
  i, j: Integer;
  resumen: string;
begin
  if totalFilasDatos <= 0 then
  begin
    ShowMessage('No hay datos de entrenamiento cargados.');
    Exit;
  end;

  if not nbEntrenado then
    EntrenarNaiveBayes;

  numFolds := spinKFolds.Value;
  if numFolds < 2 then
  begin
    ShowMessage('El número de folds debe ser mayor o igual a 2.');
    Exit;
  end;

  if numFolds > totalFilasDatos then
  begin
    ShowMessage('El número de folds no puede ser mayor que el número total de registros.');
    Exit;
  end;

  { Validar que cada clase tenga suficientes registros }
  NaiveBayes.ValidarClasesParaKFold(matrizDatosOriginales, totalFilasDatos,
    indiceColumnaClase, numFolds, mensajeValidacion);

  if mensajeValidacion <> '' then
  begin
    ShowMessage('No se puede ejecutar K-Fold: ' + LineEnding + mensajeValidacion);
    Exit;
  end;

  { Ejecutar K-Fold Cross Validation }
  try
    NaiveBayes.EjecutarKFold(matrizDatosOriginales, totalFilasDatos, totalColumnasDatos,
      indiceColumnaClase, numFolds, resultadoKFold);
  except
    on E: Exception do
      Exit;
  end;

  if resultadoKFold.NumFolds = 0 then
  begin
    ShowMessage('Error al ejecutar K-Fold Cross Validation.');
    Exit;
  end;

  { Limpiar y configurar gridKFolds }
  if gridKFolds <> nil then
  begin
    gridKFolds.Clean;
    gridKFolds.FixedCols := 1;
    gridKFolds.FixedRows := 1;
    gridKFolds.ColCount := 5;
    gridKFolds.RowCount := numFolds + 2;  { +1 para fila de promedios }

    { Encabezados de gridKFolds }
    gridKFolds.Cells[0, 0] := 'Fold';
    gridKFolds.Cells[1, 0] := 'Accuracy %';
    gridKFolds.Cells[2, 0] := 'Error %';
    gridKFolds.Cells[3, 0] := 'Correctos';
    gridKFolds.Cells[4, 0] := 'Incorrectos';

    { Llenar resultados por fold }
    for i := 0 to numFolds - 1 do
    begin
      gridKFolds.Cells[0, i + 1] := 'Fold ' + IntToStr(i + 1);
      gridKFolds.Cells[1, i + 1] := FormatFloat('0.00', resultadoKFold.ResultadosPorFold[i].Accuracy) + '%';
      gridKFolds.Cells[2, i + 1] := FormatFloat('0.00', resultadoKFold.ResultadosPorFold[i].TasaError) + '%';
      gridKFolds.Cells[3, i + 1] := IntToStr(resultadoKFold.ResultadosPorFold[i].Correctos);
      gridKFolds.Cells[4, i + 1] := IntToStr(resultadoKFold.ResultadosPorFold[i].Incorrectos);
    end;

    { Fila de promedios }
    gridKFolds.Cells[0, numFolds + 1] := 'PROMEDIO';
    gridKFolds.Cells[1, numFolds + 1] := FormatFloat('0.00', resultadoKFold.AccuracyPromedio) + '%';
    gridKFolds.Cells[2, numFolds + 1] := FormatFloat('0.00', resultadoKFold.TasaErrorPromedio) + '%';
    gridKFolds.Cells[3, numFolds + 1] := IntToStr(resultadoKFold.TotalCorrectos);
    gridKFolds.Cells[4, numFolds + 1] := IntToStr(resultadoKFold.TotalIncorrectos);
  end;

  { Limpiar memo }
  if memoEvaluacion <> nil then
  begin
    memoEvaluacion.Lines.Clear;

    { Mostrar resumen en memo con formato mejorado }
    resumen := '========== K-FOLD CROSS VALIDATION ==========' + LineEnding + LineEnding +
      'Configuración:' + LineEnding +
      '  Número de folds: ' + IntToStr(resultadoKFold.NumFolds) + LineEnding +
      '  Total registros: ' + IntToStr(totalFilasDatos) + LineEnding + LineEnding +

      'Resultados Globales:' + LineEnding +
      '  Accuracy Promedio: ' + FormatFloat('0.00', resultadoKFold.AccuracyPromedio) + '%' + LineEnding +
      '  Desviación Estándar: ' + FormatFloat('0.0000', resultadoKFold.DesviacionEstandar) + LineEnding +
      '  Error Promedio: ' + FormatFloat('0.00', resultadoKFold.TasaErrorPromedio) + '%' + LineEnding +
      '  Total Correctos: ' + IntToStr(resultadoKFold.TotalCorrectos) + LineEnding +
      '  Total Incorrectos: ' + IntToStr(resultadoKFold.TotalIncorrectos) + LineEnding + LineEnding +

      '--- RESULTADOS POR FOLD ---' + LineEnding;

    { Detalles por fold }
    for i := 0 to numFolds - 1 do
    begin
      resumen := resumen + LineEnding +
        'Fold ' + IntToStr(i + 1) + ':' + LineEnding +
        '  Accuracy: ' + FormatFloat('0.00', resultadoKFold.ResultadosPorFold[i].Accuracy) + '%' + LineEnding +
        '  Error: ' + FormatFloat('0.00', resultadoKFold.ResultadosPorFold[i].TasaError) + '%' + LineEnding +
        '  Correctos: ' + IntToStr(resultadoKFold.ResultadosPorFold[i].Correctos) + '/' +
          IntToStr(resultadoKFold.ResultadosPorFold[i].TotalRegistros);
    end;

    memoEvaluacion.Lines.Text := resumen;
  end;

  { Mostrar matriz de confusión global }
  if Assigned(resultadoKFold.EtiquetasConfusionGlobal) and
     (resultadoKFold.EtiquetasConfusionGlobal.Count > 0) then
  begin
    MostrarMatrizConfusion(resultadoKFold.EtiquetasConfusionGlobal, resultadoKFold.MatrizConfusionGlobal);
    resultadoKFold.EtiquetasConfusionGlobal.Free;
  end;

  SetLength(resultadoKFold.ResultadosPorFold, 0);
  SetLength(resultadoKFold.MatrizConfusionGlobal, 0);
end;

procedure TForm1.CargarComboBoxColumnas;
var
  col: Integer;
  nombre: string;
begin
  cBoxColumnaA.Items.Clear;
  cBoxColumnaB.Items.Clear;

  if totalColumnasDatos <= 1 then
  begin
    cBoxColumnaA.Enabled := False;
    cBoxColumnaB.Enabled := False;
    cBoxColumnaA.Visible := False;
    cBoxColumnaB.Visible := False;
    Exit;
  end;

  // Se cargan todas las columnas excepto la ultima (clase)
  for col := 0 to indiceColumnaClase - 1 do
  begin
    if col < Length(nombresColumnas) then
      nombre := nombresColumnas[col]
    else
      nombre := 'Columna ' + IntToStr(col + 1);

    cBoxColumnaA.Items.Add(nombre);
    cBoxColumnaB.Items.Add(nombre);
  end;

  if cBoxColumnaA.Items.Count > 0 then
    cBoxColumnaA.ItemIndex := 0;

  if cBoxColumnaB.Items.Count > 1 then
    cBoxColumnaB.ItemIndex := 1
  else
    cBoxColumnaB.ItemIndex := -1;

  ActualizarControlesGrafica;
end;

procedure TForm1.ValidarColumnasSeleccionadas(Sender: TObject);
begin
  if cmbTipoGrafica.ItemIndex <> 2 then
    Exit;

  if (not cBoxColumnaA.Enabled) or (not cBoxColumnaB.Enabled) then
    Exit;

  if (cBoxColumnaA.ItemIndex >= 0) and
     (cBoxColumnaB.ItemIndex >= 0) and
     (cBoxColumnaA.ItemIndex = cBoxColumnaB.ItemIndex) then
  begin
    ShowMessage('No se puede seleccionar la misma columna en ambos ComboBox.');

    if Sender = cBoxColumnaA then
      cBoxColumnaA.ItemIndex := -1
    else if Sender = cBoxColumnaB then
      cBoxColumnaB.ItemIndex := -1;
  end;
end;

procedure TForm1.cBoxColumnaAChange(Sender: TObject);
begin
  ValidarColumnasSeleccionadas(Sender);
end;

procedure TForm1.cBoxColumnaBChange(Sender: TObject);
begin
  ValidarColumnasSeleccionadas(Sender);
end;

procedure TForm1.cmbTipoGraficaChange(Sender: TObject);
begin
  ActualizarControlesGrafica;
end;

procedure TForm1.AplicarNormalizacionActual;
var
  tipo: TTipoNormalizacion;
begin
  if cmbMetodoNormalizacion.ItemIndex < 0 then
    tipo := tnMinMax
  else
    case cmbMetodoNormalizacion.ItemIndex of
      0: tipo := tnMinMax;
      1: tipo := tnZScore;
      2: tipo := tnDecimalScaling;
    else
      tipo := tnMinMax;
    end;

  tipoNormalizacionActual := tipo;

  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
    Exit;

  Normalizacion.NormalizarDatos(tipo, matrizDatosOriginales, totalFilasDatos, totalColumnasDatos, indiceColumnaClase,
    minValoresNormalizacion, maxValoresNormalizacion, mediasNormalizacion, desviacionesNormalizacion,
    factoresDecimalScaling, matrizDatosPrueba, totalFilasPrueba, totalColumnasPrueba,
    matrizDatosNormalizados, matrizDatosPruebaNormalizados);

  CargarGridDesdeMatriz(matrizDatosNormalizados);
end;

procedure TForm1.cmbMetodoNormalizacionChange(Sender: TObject);
begin
  if cmbMetodoNormalizacion.ItemIndex < 0 then
    Exit;

  AplicarNormalizacionActual;
end;

procedure TForm1.ActualizarControlesGrafica;
begin
  cBoxColumnaA.Visible := False;
  cBoxColumnaB.Visible := False;
  cBoxColumnaA.Enabled := False;
  cBoxColumnaB.Enabled := False;

  case cmbTipoGrafica.ItemIndex of
    1:
      begin
        cBoxColumnaA.Visible := False;
        cBoxColumnaB.Visible := False;
        cBoxColumnaA.Enabled := False;
        cBoxColumnaB.Enabled := False;
      end;
    2:
      begin
        cBoxColumnaA.Visible := True;
        cBoxColumnaB.Visible := True;
        cBoxColumnaA.Enabled := True;
        cBoxColumnaB.Enabled := True;
        if (cBoxColumnaA.ItemIndex < 0) and (cBoxColumnaA.Items.Count > 0) then
          cBoxColumnaA.ItemIndex := 0;
        if (cBoxColumnaB.ItemIndex < 0) and (cBoxColumnaB.Items.Count > 1) then
          cBoxColumnaB.ItemIndex := 1
        else if (cBoxColumnaB.ItemIndex < 0) and (cBoxColumnaB.Items.Count = 1) then
          cBoxColumnaB.ItemIndex := 0;
      end;
    3:
      begin
        cBoxColumnaA.Visible := True;
        cBoxColumnaA.Enabled := True;
        if (cBoxColumnaA.ItemIndex < 0) and (cBoxColumnaA.Items.Count > 0) then
          cBoxColumnaA.ItemIndex := 0;
      end;
  end;
end;


function TForm1.NormalizadosDisponibles: Boolean;
begin
  Result := (totalFilasDatos > 0) and (totalColumnasDatos > 0) and
    (Length(matrizDatosNormalizados) = totalFilasDatos);

  if Result then
  begin
    if Length(matrizDatosNormalizados) = 0 then
      Result := False
    else if Length(matrizDatosNormalizados[0]) <> totalColumnasDatos then
      Result := False;
  end;
end;

procedure TForm1.LimpiarGrafica(const Mensaje: string);
begin
  Graficas.LimpiarGrafica(paintBoxClases, Mensaje);
end;

procedure TForm1.ContarClases(out Etiquetas: TStringList; out Conteos: TArregloEntero);
begin
  Graficas.ContarClases(matrizDatosOriginales, totalFilasDatos,
    indiceColumnaClase, Etiquetas, Conteos);
end;

procedure TForm1.ObtenerClasesUnicas(out Clases: TStringList;
  out Conteos: TArregloEntero);
begin
  ContarClases(Clases, Conteos);
end;

procedure TForm1.PrepararGraficaClases;
begin
  Graficas.PrepararGraficaClases(matrizDatosOriginales, totalFilasDatos,
    indiceColumnaClase, etiquetasClases, conteosClases, maxConteoClases);
end;

procedure TForm1.PrepararGraficaDispersion;
var
  colX: Integer;
  colY: Integer;
  fila: Integer;
  valorX: Double;
  valorY: Double;
  formatos: TFormatSettings;
  puntos: Integer;
begin
  colX := cBoxColumnaA.ItemIndex;
  colY := cBoxColumnaB.ItemIndex;

  if (colX < 0) or (colY < 0) then
  begin
    ShowMessage('Seleccione columnas validas.');
    Exit;
  end;

  if colX = colY then
  begin
    ShowMessage('Seleccione columnas diferentes para la dispersion.');
    Exit;
  end;

  if (colX >= indiceColumnaClase) or
     (colY >= indiceColumnaClase) then
  begin
    ShowMessage('Las columnas seleccionadas no son validas.');
    Exit;
  end;

  SetLength(dispersionX, 0);
  SetLength(dispersionY, 0);

  dispersionLabelX := nombresColumnas[colX];
  dispersionLabelY := nombresColumnas[colY];

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  puntos := 0;

  for fila := 0 to totalFilasDatos - 1 do
  begin
    if not TryStrToFloat(
      Trim(matrizDatosOriginales[fila][colX]),
      valorX,
      formatos
    ) then
      Continue;

    if not TryStrToFloat(
      Trim(matrizDatosOriginales[fila][colY]),
      valorY,
      formatos
    ) then
      Continue;

    Inc(puntos);

    SetLength(dispersionX, puntos);
    SetLength(dispersionY, puntos);

    dispersionX[puntos - 1] := valorX;
    dispersionY[puntos - 1] := valorY;

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
    ShowMessage('No hay datos numericos para dispersion.');
end;

procedure TForm1.PrepararGraficaBoxPlot;
var
  col: Integer;
  fila: Integer;
  numero: Double;
  clase: string;
  idxClase: Integer;
  i: Integer;
  valoresClase: array of TArregloDouble;
  valores: TArregloDouble;
  clasesTemp: TStringList;
  formatos: TFormatSettings;
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
begin
  if Assigned(boxLabels) then
  begin
    boxLabels.Free;
    boxLabels := nil;
  end;

  boxLabels := TStringList.Create;
  SetLength(boxMin, 0);
  SetLength(boxQ1, 0);
  SetLength(boxMed, 0);
  SetLength(boxQ3, 0);
  SetLength(boxMax, 0);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  col := cBoxColumnaA.ItemIndex;

  if (col < 0) or (col >= indiceColumnaClase) then
  begin
    ShowMessage('Seleccione una columna valida.');
    Exit;
  end;

  clasesTemp := TStringList.Create;
  try
    SetLength(valoresClase, 0);

    for fila := 0 to totalFilasDatos - 1 do
    begin
      if not TryStrToFloat(Trim(matrizDatosOriginales[fila][col]), numero, formatos) then
        Continue;

      clase := Trim(matrizDatosOriginales[fila][indiceColumnaClase]);
      if clase = '' then
        clase := 'SinClase';

      idxClase := clasesTemp.IndexOf(clase);
      if idxClase < 0 then
      begin
        idxClase := clasesTemp.Add(clase);
        SetLength(valoresClase, clasesTemp.Count);
        SetLength(valoresClase[idxClase], 0);
      end;

      SetLength(valoresClase[idxClase], Length(valoresClase[idxClase]) + 1);
      valoresClase[idxClase][High(valoresClase[idxClase])] := numero;
    end;

    for i := 0 to clasesTemp.Count - 1 do
    begin
      valores := valoresClase[i];
      if Length(valores) = 0 then
        Continue;

      OrdenarValores(valores);

      boxLabels.Add(clasesTemp[i]);
      SetLength(boxMin, Length(boxMin) + 1);
      SetLength(boxQ1, Length(boxQ1) + 1);
      SetLength(boxMed, Length(boxMed) + 1);
      SetLength(boxQ3, Length(boxQ3) + 1);
      SetLength(boxMax, Length(boxMax) + 1);

      boxMin[High(boxMin)] := valores[0];
      boxMax[High(boxMax)] := valores[High(valores)];
      boxQ1[High(boxQ1)] := Percentil(valores, 0.25);
      boxMed[High(boxMed)] := Percentil(valores, 0.50);
      boxQ3[High(boxQ3)] := Percentil(valores, 0.75);
    end;
  finally
    clasesTemp.Free;
  end;

  if boxLabels.Count = 0 then
    ShowMessage('No hay datos numericos para boxplot.');
end;

procedure TForm1.DibujarGraficaClases;
var
  i: Integer;
  n: Integer;
  margenIzq: Integer;
  margenDer: Integer;
  margenSup: Integer;
  margenInf: Integer;
  anchoGraf: Integer;
  altoGraf: Integer;
  espacio: Integer;
  anchoBarra: Integer;
  altoBarra: Integer;
  x: Integer;
  y: Integer;
  baseY: Integer;
  etiqueta: string;
  numTicks: Integer;
  tick: Integer;
  yTick: Integer;
  valorTick: Double;
  textoTick: string;
  title: string;
  titleX: Integer;
  valueText: string;
  labelX: Integer;
  function EtiquetaAjustada(const Texto: string; const AnchoMax: Integer): string;
  var
    temp: string;
  begin
    temp := Texto;
    while (Length(temp) > 0) and (paintBoxClases.Canvas.TextWidth(temp) > AnchoMax) do
      Delete(temp, Length(temp), 1);
    if (temp <> Texto) and (Length(temp) > 0) then
      temp := Copy(temp, 1, Length(temp) - 1) + '.';
    Result := temp;
  end;
begin
  LimpiarGrafica('');

  if (not Assigned(etiquetasClases)) or (Length(conteosClases) = 0) or
    (maxConteoClases <= 0) then
  begin
    LimpiarGrafica('No hay datos para graficar');
    Exit;
  end;

  n := etiquetasClases.Count;
  if n = 0 then
  begin
    LimpiarGrafica('No hay datos para graficar');
    Exit;
  end;

  if Length(conteosClases) < n then
  begin
    LimpiarGrafica('No hay datos para graficar');
    Exit;
  end;

  margenIzq := 70;
  margenDer := 20;
  margenSup := 30;
  margenInf := 60;
  anchoGraf := paintBoxClases.Width - margenIzq - margenDer;
  altoGraf := paintBoxClases.Height - margenSup - margenInf;
  if (anchoGraf <= 0) or (altoGraf <= 0) then
    Exit;

  title := 'Distribucion de clases';
  paintBoxClases.Canvas.Font.Style := [fsBold];
  paintBoxClases.Canvas.Font.Color := clBlack;
  titleX := margenIzq + (anchoGraf - paintBoxClases.Canvas.TextWidth(title)) div 2;
  paintBoxClases.Canvas.TextOut(titleX, 4, title);
  paintBoxClases.Canvas.Font.Style := [];

  espacio := 6;
  if n > 1 then
    anchoBarra := (anchoGraf - (n - 1) * espacio) div n
  else
    anchoBarra := anchoGraf;

  if anchoBarra < 1 then
  begin
    espacio := 2;
    if n > 1 then
      anchoBarra := (anchoGraf - (n - 1) * espacio) div n
    else
      anchoBarra := anchoGraf;
  end;

  if anchoBarra < 1 then
    anchoBarra := 1;

  baseY := margenSup + altoGraf;

  numTicks := 5;
  if altoGraf > 320 then
    numTicks := 6
  else if altoGraf < 180 then
    numTicks := 4;

  paintBoxClases.Canvas.Pen.Width := 1;
  paintBoxClases.Canvas.Pen.Color := clSilver;
  for tick := 0 to numTicks do
  begin
    yTick := baseY - Round((tick / numTicks) * altoGraf);
    paintBoxClases.Canvas.MoveTo(margenIzq, yTick);
    paintBoxClases.Canvas.LineTo(margenIzq + anchoGraf, yTick);

    valorTick := (maxConteoClases * tick) / numTicks;
    textoTick := FormatFloat('0', valorTick);
    paintBoxClases.Canvas.Font.Color := clBlack;
    paintBoxClases.Canvas.TextOut(
      margenIzq - paintBoxClases.Canvas.TextWidth(textoTick) - 6,
      yTick - (paintBoxClases.Canvas.TextHeight(textoTick) div 2),
      textoTick
    );
  end;

  paintBoxClases.Canvas.Pen.Color := clBlack;
  paintBoxClases.Canvas.Pen.Width := 2;
  paintBoxClases.Canvas.MoveTo(margenIzq, margenSup);
  paintBoxClases.Canvas.LineTo(margenIzq, baseY);
  paintBoxClases.Canvas.LineTo(margenIzq + anchoGraf, baseY);

  paintBoxClases.Canvas.Pen.Width := 1;
  paintBoxClases.Canvas.Brush.Color := clSkyBlue;

  for i := 0 to n - 1 do
  begin
    altoBarra := Round((conteosClases[i] / maxConteoClases) * altoGraf);
    x := margenIzq + i * (anchoBarra + espacio);
    y := baseY - altoBarra;

    paintBoxClases.Canvas.Rectangle(x, y, x + anchoBarra, baseY);

    etiqueta := EtiquetaAjustada(etiquetasClases[i], anchoBarra);
    labelX := x + (anchoBarra div 2) - (paintBoxClases.Canvas.TextWidth(etiqueta) div 2);
    paintBoxClases.Canvas.TextOut(labelX, baseY + 6, etiqueta);

    valueText := IntToStr(conteosClases[i]);
    paintBoxClases.Canvas.TextOut(
      x + (anchoBarra div 2) - (paintBoxClases.Canvas.TextWidth(valueText) div 2),
      y - paintBoxClases.Canvas.TextHeight(valueText) - 2,
      valueText
    );
  end;
end;

procedure TForm1.DibujarGraficaDispersion;
var
  i: Integer;
  margenIzq: Integer;
  margenDer: Integer;
  margenSup: Integer;
  margenInf: Integer;
  anchoGraf: Integer;
  altoGraf: Integer;
  baseY: Integer;
  x: Integer;
  y: Integer;
  xTick: Integer;
  yTick: Integer;
  escalaX: Double;
  escalaY: Double;
  rangoX: Double;
  rangoY: Double;
  numTicks: Integer;
  tick: Integer;
  valorTick: Double;
  textoTick: string;
  title: string;
  titleX: Integer;
  axisX: string;
  axisY: string;
begin
  LimpiarGrafica('');

  if Length(dispersionX) = 0 then
  begin
    LimpiarGrafica('No hay datos para graficar');
    Exit;
  end;

  margenIzq := 70;
  margenDer := 20;
  margenSup := 30;
  margenInf := 60;
  anchoGraf := paintBoxClases.Width - margenIzq - margenDer;
  altoGraf := paintBoxClases.Height - margenSup - margenInf;
  if (anchoGraf <= 0) or (altoGraf <= 0) then
    Exit;

  title := 'Grafica de dispersion';
  paintBoxClases.Canvas.Font.Style := [fsBold];
  paintBoxClases.Canvas.Font.Color := clBlack;
  titleX := margenIzq + (anchoGraf - paintBoxClases.Canvas.TextWidth(title)) div 2;
  paintBoxClases.Canvas.TextOut(titleX, 4, title);
  paintBoxClases.Canvas.Font.Style := [];

  baseY := margenSup + altoGraf;
  rangoX := dispersionMaxX - dispersionMinX;
  rangoY := dispersionMaxY - dispersionMinY;
  if rangoX = 0 then
    rangoX := 1;
  if rangoY = 0 then
    rangoY := 1;

  escalaX := anchoGraf / rangoX;
  escalaY := altoGraf / rangoY;

  numTicks := 5;
  if altoGraf > 320 then
    numTicks := 6
  else if altoGraf < 180 then
    numTicks := 4;

  paintBoxClases.Canvas.Pen.Width := 1;
  paintBoxClases.Canvas.Pen.Color := clSilver;
  for tick := 0 to numTicks do
  begin
    yTick := baseY - Round((tick / numTicks) * altoGraf);
    paintBoxClases.Canvas.MoveTo(margenIzq, yTick);
    paintBoxClases.Canvas.LineTo(margenIzq + anchoGraf, yTick);

    valorTick := dispersionMinY + (tick / numTicks) * rangoY;
    textoTick := FormatFloat('0.##', valorTick);
    paintBoxClases.Canvas.Font.Color := clBlack;
    paintBoxClases.Canvas.TextOut(
      margenIzq - paintBoxClases.Canvas.TextWidth(textoTick) - 6,
      yTick - (paintBoxClases.Canvas.TextHeight(textoTick) div 2),
      textoTick
    );
  end;

  paintBoxClases.Canvas.Pen.Color := clBlack;
  paintBoxClases.Canvas.Pen.Width := 2;
  paintBoxClases.Canvas.MoveTo(margenIzq, margenSup);
  paintBoxClases.Canvas.LineTo(margenIzq, baseY);
  paintBoxClases.Canvas.LineTo(margenIzq + anchoGraf, baseY);

  paintBoxClases.Canvas.Pen.Width := 1;
  for tick := 0 to numTicks do
  begin
    xTick := margenIzq + Round((tick / numTicks) * anchoGraf);
    paintBoxClases.Canvas.MoveTo(xTick, baseY);
    paintBoxClases.Canvas.LineTo(xTick, baseY + 4);
    valorTick := dispersionMinX + (tick / numTicks) * rangoX;
    textoTick := FormatFloat('0.##', valorTick);
    paintBoxClases.Canvas.TextOut(
      xTick - (paintBoxClases.Canvas.TextWidth(textoTick) div 2),
      baseY + 6,
      textoTick
    );
  end;

  axisX := 'X: ' + dispersionLabelX;
  axisY := 'Y: ' + dispersionLabelY;
  paintBoxClases.Canvas.TextOut(
    margenIzq + (anchoGraf - paintBoxClases.Canvas.TextWidth(axisX)) div 2,
    baseY + 28,
    axisX
  );
  paintBoxClases.Canvas.TextOut(6, margenSup + 4, axisY);

  paintBoxClases.Canvas.Brush.Color := clNavy;
  paintBoxClases.Canvas.Pen.Color := clNavy;
  for i := 0 to High(dispersionX) do
  begin
    x := margenIzq + Round((dispersionX[i] - dispersionMinX) * escalaX);
    y := baseY - Round((dispersionY[i] - dispersionMinY) * escalaY);
    paintBoxClases.Canvas.Ellipse(x - 2, y - 2, x + 2, y + 2);
  end;
end;

procedure TForm1.DibujarGraficaBoxPlot;
var
  n: Integer;
  i: Integer;
  margenIzq: Integer;
  margenDer: Integer;
  margenSup: Integer;
  margenInf: Integer;
  anchoGraf: Integer;
  altoGraf: Integer;
  espacio: Integer;
  anchoCaja: Integer;
  xCentro: Integer;
  baseY: Integer;
  minGlobal: Double;
  maxGlobal: Double;
  rango: Double;
  numTicks: Integer;
  tick: Integer;
  yTick: Integer;
  valorTick: Double;
  textoTick: string;
  title: string;
  titleX: Integer;
  etiqueta: string;
  labelX: Integer;
  function EscalaY(const Valor: Double): Integer;
  begin
    if rango = 0 then
      Result := baseY
    else
      Result := baseY - Round((Valor - minGlobal) / rango * altoGraf);
  end;
  function EtiquetaAjustada(const Texto: string; const AnchoMax: Integer): string;
  var
    temp: string;
  begin
    temp := Texto;
    while (Length(temp) > 0) and (paintBoxClases.Canvas.TextWidth(temp) > AnchoMax) do
      Delete(temp, Length(temp), 1);
    if (temp <> Texto) and (Length(temp) > 0) then
      temp := Copy(temp, 1, Length(temp) - 1) + '.';
    Result := temp;
  end;
begin
  LimpiarGrafica('');

  if (not Assigned(boxLabels)) or (boxLabels.Count = 0) then
  begin
    LimpiarGrafica('No hay datos para graficar');
    Exit;
  end;

  n := boxLabels.Count;
  if (Length(boxMin) < n) or (Length(boxMax) < n) or (Length(boxQ1) < n) or
    (Length(boxMed) < n) or (Length(boxQ3) < n) then
  begin
    LimpiarGrafica('No hay datos para graficar');
    Exit;
  end;

  minGlobal := boxMin[0];
  maxGlobal := boxMax[0];
  for i := 1 to n - 1 do
  begin
    if boxMin[i] < minGlobal then
      minGlobal := boxMin[i];
    if boxMax[i] > maxGlobal then
      maxGlobal := boxMax[i];
  end;

  margenIzq := 70;
  margenDer := 20;
  margenSup := 30;
  margenInf := 60;
  anchoGraf := paintBoxClases.Width - margenIzq - margenDer;
  altoGraf := paintBoxClases.Height - margenSup - margenInf;
  if (anchoGraf <= 0) or (altoGraf <= 0) then
    Exit;

  title := 'BoxPlot de atributos';
  paintBoxClases.Canvas.Font.Style := [fsBold];
  paintBoxClases.Canvas.Font.Color := clBlack;
  titleX := margenIzq + (anchoGraf - paintBoxClases.Canvas.TextWidth(title)) div 2;
  paintBoxClases.Canvas.TextOut(titleX, 4, title);
  paintBoxClases.Canvas.Font.Style := [];

  baseY := margenSup + altoGraf;
  rango := maxGlobal - minGlobal;
  if rango = 0 then
    rango := 1;

  numTicks := 5;
  if altoGraf > 320 then
    numTicks := 6
  else if altoGraf < 180 then
    numTicks := 4;

  paintBoxClases.Canvas.Pen.Width := 1;
  paintBoxClases.Canvas.Pen.Color := clSilver;
  for tick := 0 to numTicks do
  begin
    yTick := baseY - Round((tick / numTicks) * altoGraf);
    paintBoxClases.Canvas.MoveTo(margenIzq, yTick);
    paintBoxClases.Canvas.LineTo(margenIzq + anchoGraf, yTick);

    valorTick := minGlobal + (tick / numTicks) * rango;
    textoTick := FormatFloat('0.##', valorTick);
    paintBoxClases.Canvas.Font.Color := clBlack;
    paintBoxClases.Canvas.TextOut(
      margenIzq - paintBoxClases.Canvas.TextWidth(textoTick) - 6,
      yTick - (paintBoxClases.Canvas.TextHeight(textoTick) div 2),
      textoTick
    );
  end;

  paintBoxClases.Canvas.Pen.Color := clBlack;
  paintBoxClases.Canvas.Pen.Width := 2;
  paintBoxClases.Canvas.MoveTo(margenIzq, margenSup);
  paintBoxClases.Canvas.LineTo(margenIzq, baseY);
  paintBoxClases.Canvas.LineTo(margenIzq + anchoGraf, baseY);

  espacio := 10;
  if n > 1 then
    anchoCaja := (anchoGraf - (n - 1) * espacio) div n
  else
    anchoCaja := anchoGraf;

  if anchoCaja < 10 then
    anchoCaja := 10;

  paintBoxClases.Canvas.Pen.Color := clGray;
  paintBoxClases.Canvas.Brush.Color := clMoneyGreen;

  for i := 0 to n - 1 do
  begin
    xCentro := margenIzq + i * (anchoCaja + espacio) + (anchoCaja div 2);

    paintBoxClases.Canvas.Pen.Width := 1;
    paintBoxClases.Canvas.MoveTo(xCentro, EscalaY(boxMin[i]));
    paintBoxClases.Canvas.LineTo(xCentro, EscalaY(boxMax[i]));
    paintBoxClases.Canvas.LineTo(xCentro - 6, EscalaY(boxMax[i]));
    paintBoxClases.Canvas.MoveTo(xCentro, EscalaY(boxMin[i]));
    paintBoxClases.Canvas.LineTo(xCentro + 6, EscalaY(boxMin[i]));

    paintBoxClases.Canvas.Rectangle(
      xCentro - (anchoCaja div 2),
      EscalaY(boxQ3[i]),
      xCentro + (anchoCaja div 2),
      EscalaY(boxQ1[i])
    );
    paintBoxClases.Canvas.Pen.Width := 2;
    paintBoxClases.Canvas.MoveTo(xCentro - (anchoCaja div 2), EscalaY(boxMed[i]));
    paintBoxClases.Canvas.LineTo(xCentro + (anchoCaja div 2), EscalaY(boxMed[i]));

    etiqueta := EtiquetaAjustada(boxLabels[i], anchoCaja + espacio);
    labelX := xCentro - (paintBoxClases.Canvas.TextWidth(etiqueta) div 2);
    paintBoxClases.Canvas.TextOut(labelX, baseY + 6, etiqueta);
  end;
end;

procedure TForm1.paintBoxClasesPaint(Sender: TObject);
begin
  case tipoGraficaActual of
    tgBarras: DibujarGraficaClases;
    tgDispersion: DibujarGraficaDispersion;
    tgBoxPlot: DibujarGraficaBoxPlot;
  else
    LimpiarGrafica('Seleccione grafica y presione Graficar');
  end;
end;

procedure TForm1.ExportarMatrizCSV(const Matriz: TMatrizString);
begin
  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
  begin
    ShowMessage('No hay datos para exportar.');
    Exit;
  end;

  if Length(Matriz) = 0 then
  begin
    ShowMessage('No hay datos para exportar.');
    Exit;
  end;

  saveDialogExportar.Title := 'Guardar CSV';
  saveDialogExportar.Filter := 'CSV (*.csv)|*.csv|Todos los archivos|*.*';
  saveDialogExportar.DefaultExt := 'csv';

  if not saveDialogExportar.Execute then
    Exit;
  Matrices.ExportarMatrizCSV(Matriz, nombresColumnas, totalFilasDatos,
    totalColumnasDatos, delimitadorArchivo, saveDialogExportar.FileName);
end;

procedure TForm1.CargarGridDesdeMatriz(const Matriz: TMatrizString);
var
  filaDatos: Integer;
  filaGrid: Integer;
  col: Integer;
  filasMostrar: Integer;
begin
  if totalColumnasDatos <= 0 then
    Exit;

  filasMostrar := totalFilasDatos;
  if Length(Matriz) < filasMostrar then
    filasMostrar := Length(Matriz);

  gridDatos.BeginUpdate;
  try
    gridDatos.FixedCols := 0;
    gridDatos.FixedRows := 1;
    gridDatos.RowCount := filasMostrar + 1;
    gridDatos.ColCount := totalColumnasDatos;

    for col := 0 to totalColumnasDatos - 1 do
      gridDatos.Cells[col, 0] := nombresColumnas[col];

    for filaDatos := 0 to filasMostrar - 1 do
    begin
      filaGrid := filaDatos + 1;
      for col := 0 to totalColumnasDatos - 1 do
        gridDatos.Cells[col, filaGrid] := Matriz[filaDatos][col];
    end;
  finally
    gridDatos.EndUpdate;
  end;
end;

// Normalization logic moved to Normalizacion.pas - call Normalizacion.NormalizarDatos where needed.

procedure TForm1.LeerNombresColumnas(const LineaAtributos: string;
  const TotalColumnas: Integer; const Delimitador: Char);
begin
  // Conservado por compatibilidad con llamadas existentes.
  // Los nombres se cargan desde Matrices.CargarDatosDesdeCSV.
end;


procedure TForm1.OrdenarValores(var Valores: TArregloDouble);
begin
  Estadisticas.OrdenarValores(Valores);
end;

procedure TForm1.CalcularMediaDesviacionMuestral(const Valores: TArregloDouble;
  out Media, Desviacion: Double);
begin
  Estadisticas.CalcularMediaDesviacionMuestral(Valores, Media, Desviacion);
end;

procedure TForm1.CalcularMediaDesviacionPoblacional(const Valores: TArregloDouble;
  out Media, Desviacion: Double);
begin
  Estadisticas.CalcularMediaDesviacionPoblacional(Valores, Media, Desviacion);
end;

procedure TForm1.CalcularEstadisticasNumericas(out Medias, Medianas,
  Desviaciones: TArregloDouble; out ColumnasCalculadas: TArregloBool);
begin
  Estadisticas.CalcularEstadisticasNumericas(matrizDatosOriginales,
    totalColumnasDatos, totalFilasDatos, indiceColumnaClase,
    Medias, Medianas, Desviaciones, ColumnasCalculadas);
end;

procedure TForm1.AgregarFilaEstadistica(const Valores: TArregloDouble;
  const ColumnasCalculadas: TArregloBool; const FilaDestino: Integer);
var
  col: Integer;
  formatos: TFormatSettings;
begin
  if (totalColumnasDatos = 0) or (FilaDestino < 0) then
    Exit;

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  gridDatos.BeginUpdate;
  try
    if gridDatos.RowCount <= FilaDestino then
      gridDatos.RowCount := FilaDestino + 1;

    for col := 0 to totalColumnasDatos - 1 do
    begin
      if (col < Length(ColumnasCalculadas)) and ColumnasCalculadas[col] then
        gridDatos.Cells[col, FilaDestino] := FormatFloat('0.######', Valores[col], formatos)
      else
        gridDatos.Cells[col, FilaDestino] := '';
    end;
  finally
    gridDatos.EndUpdate;
  end;
end;

procedure TForm1.EjecutarEstadistica(const Tipo: TTipoEstadistica);
var
  medias: TArregloDouble;
  medianas: TArregloDouble;
  desviaciones: TArregloDouble;
  columnasCalculadas: TArregloBool;
  filaBase: Integer;
  filaDestino: Integer;
begin
  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
  begin
    ShowMessage('No hay datos cargados.');
    Exit;
  end;

  CalcularEstadisticasNumericas(medias, medianas, desviaciones, columnasCalculadas);

  filaBase := totalFilasDatos + 1;
  if gridDatos.RowCount < filaBase + 3 then
    gridDatos.RowCount := filaBase + 3;

  case Tipo of
    teMedia:
      begin
        filaDestino := filaBase;
        AgregarFilaEstadistica(medias, columnasCalculadas, filaDestino);
      end;
    teMediana:
      begin
        filaDestino := filaBase + 1;
        AgregarFilaEstadistica(medianas, columnasCalculadas, filaDestino);
      end;
    teDesviacion:
      begin
        filaDestino := filaBase + 2;
        AgregarFilaEstadistica(desviaciones, columnasCalculadas, filaDestino);
      end;
  end;
end;

procedure TForm1.EntrenarNaiveBayes;
begin
  NaiveBayes.EntrenarNaiveBayes(matrizDatosOriginales, totalFilasDatos,
    totalColumnasDatos, indiceColumnaClase, nbModelo);

  nbEntrenado := nbModelo.Entrenado;
  nbNumAtributos := nbModelo.NumAtributos;
  nbPriors := Copy(nbModelo.Priors, 0, Length(nbModelo.Priors));
  nbConteos := Copy(nbModelo.Conteos, 0, Length(nbModelo.Conteos));
  nbMedias := Copy(nbModelo.Medias, 0, Length(nbModelo.Medias));
  nbDesv := Copy(nbModelo.Desv, 0, Length(nbModelo.Desv));

  if Assigned(nbClases) then
    nbClases.Free;
  nbClases := TStringList.Create;
  if Assigned(nbModelo.Clases) then
    nbClases.Assign(nbModelo.Clases);
end;

function TForm1.ProbabilidadGaussiana(const X, Media, Desv: Double): Double;
begin
  Result := NaiveBayes.ProbabilidadGaussiana(X, Media, Desv);
end;

procedure TForm1.ObtenerProbabilidadesPorClase(const Registro: TArregloDouble;
  out Probabilidades: TArregloDouble);
begin
  NaiveBayes.ObtenerProbabilidadesPorClase(Registro, nbModelo, Probabilidades);
end;

function TForm1.ClasificarRegistro(const Registro: TArregloDouble;
  out Probabilidades: TArregloDouble): string;
begin
  Result := NaiveBayes.ClasificarRegistro(Registro, nbModelo, Probabilidades);
end;

procedure TForm1.CargarDatosDesdeCSV(const NombreArchivo: string;
  out Matriz: TMatrizString; out Nombres: TNombresColumnas;
  out TotalFilas, TotalColumnas, IndiceClase: Integer; out Delimitador: Char);
begin
  Matrices.CargarDatosDesdeCSV(NombreArchivo, Matriz, Nombres,
    TotalFilas, TotalColumnas, IndiceClase, Delimitador);
end;

procedure TForm1.InicializarGridResultados;
begin
  gridResultados.FixedCols := 0;
  gridResultados.FixedRows := 1;
  gridResultados.ColCount := 1;
  gridResultados.RowCount := 1;
  gridResultados.Cells[0, 0] := 'Resultados';
end;

procedure TForm1.CargarDatosPrueba(const NombreArchivo: string);
begin
  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
  begin
    ShowMessage('Primero cargue el conjunto de entrenamiento T.');
    Exit;
  end;

  CargarDatosDesdeCSV(NombreArchivo, matrizDatosPrueba, nombresColumnasPrueba,
    totalFilasPrueba, totalColumnasPrueba, indiceColumnaClasePrueba,
    delimitadorArchivoPrueba);

  if totalColumnasPrueba <= 0 then
    Exit;

  if totalColumnasPrueba <> totalColumnasDatos then
  begin
    ShowMessage('El conjunto de prueba no tiene la misma cantidad de columnas que T.');
    SetLength(matrizDatosPrueba, 0);
    SetLength(nombresColumnasPrueba, 0);
    totalFilasPrueba := 0;
    totalColumnasPrueba := 0;
    indiceColumnaClasePrueba := -1;
    Exit;
  end;
  InicializarGridResultados;
end;

function TForm1.ObtenerIndiceClase(const Clase: string;
  const Clases: TStringList): Integer;
begin
  Result := -1;
  if not Assigned(Clases) then
    Exit;
  Result := Clases.IndexOf(Clase);
end;

procedure TForm1.ConstruirMatrizConfusion(const ClasesReales,
  ClasesPredichas: TArregloString; out ClasesUnicas: TStringList;
  out MatrizConfusion: TArregloEntero2D);
begin
  NaiveBayes.ConstruirMatrizConfusion(ClasesReales, ClasesPredichas,
    ClasesUnicas, MatrizConfusion);
end;

procedure TForm1.MostrarMatrizConfusion(const ClasesUnicas: TStringList;
  const MatrizConfusion: TArregloEntero2D);
var
  i: Integer;
  j: Integer;
begin
  if not Assigned(ClasesUnicas) then
    Exit;

  gridResultados.FixedCols := 1;
  gridResultados.FixedRows := 1;
  gridResultados.ColCount := ClasesUnicas.Count + 1;
  gridResultados.RowCount := ClasesUnicas.Count + 1;

  gridResultados.Cells[0, 0] := 'Real\\Pred';
  for i := 0 to ClasesUnicas.Count - 1 do
  begin
    gridResultados.Cells[i + 1, 0] := ClasesUnicas[i];
    gridResultados.Cells[0, i + 1] := ClasesUnicas[i];
  end;

  for i := 0 to ClasesUnicas.Count - 1 do
    for j := 0 to ClasesUnicas.Count - 1 do
      gridResultados.Cells[j + 1, i + 1] := IntToStr(MatrizConfusion[i][j]);
end;

procedure TForm1.EvaluarConjuntoPrueba;
var
  resultado: TNaiveBayesResultadoEvaluacion;
  resumen: string;
begin
  if totalFilasDatos <= 0 then
  begin
    ShowMessage('No hay datos de entrenamiento cargados.');
    Exit;
  end;

  if totalFilasPrueba <= 0 then
  begin
    ShowMessage('No hay conjunto de prueba cargado.');
    Exit;
  end;

  if totalColumnasPrueba <> totalColumnasDatos then
  begin
    ShowMessage('El conjunto de prueba no coincide con la estructura de T.');
    Exit;
  end;

  if indiceColumnaClasePrueba <> indiceColumnaClase then
  begin
    ShowMessage('La ultima columna del conjunto de prueba debe representar la clase.');
    Exit;
  end;

  if not nbEntrenado then
    EntrenarNaiveBayes;

  if not nbEntrenado then
  begin
    ShowMessage('No se pudo entrenar Naive Bayes con los datos originales.');
    Exit;
  end;

  NaiveBayes.EvaluarConjuntoPruebaNaiveBayes(matrizDatosPrueba,
    totalFilasPrueba, totalColumnasPrueba, indiceColumnaClasePrueba,
    nbModelo, resultado);

  if resultado.TotalRegistros = 0 then
  begin
    ShowMessage('No se encontraron registros validos para evaluar.');
    Exit;
  end;

  if (not Assigned(resultado.EtiquetasConfusion)) or
     (resultado.EtiquetasConfusion.Count = 0) then
  begin
    ShowMessage('No fue posible construir la matriz de confusion.');
    Exit;
  end;

  try
    MostrarMatrizConfusion(resultado.EtiquetasConfusion, resultado.MatrizConfusion);
  finally
    resultado.EtiquetasConfusion.Free;
  end;

  resumen := 'Total registros: ' + IntToStr(resultado.TotalRegistros) + LineEnding +
    'Aciertos: ' + IntToStr(resultado.Aciertos) + LineEnding +
    'Errores: ' + IntToStr(resultado.Errores) + LineEnding +
    'Accuracy: ' + FormatFloat('0.00', resultado.Accuracy) + ' %' + LineEnding +
    'Error: ' + FormatFloat('0.00', resultado.TasaError) + ' %';

  if resultado.Invalidos > 0 then
    resumen := resumen + LineEnding + 'Registros invalidos omitidos: ' +
      IntToStr(resultado.Invalidos);

  ShowMessage(resumen);
end;

//Metodo para determinar si el delimitador va a ser , o ;
function TForm1.DetectarDelimitador(const Linea: string): Char;
begin
  Result := Matrices.DetectarDelimitador(Linea);
end;

procedure TForm1.paintBoxClasesClick(Sender: TObject);
begin

end;

procedure TForm1.CargarGridDatos(const NombreArchivo: string);
begin
  CargarDatosDesdeCSV(NombreArchivo, matrizDatosOriginales, nombresColumnas,
    totalFilasDatos, totalColumnasDatos, indiceColumnaClase, delimitadorArchivo);

  SetLength(matrizDatosPrueba, 0);
  SetLength(matrizDatosPruebaNormalizados, 0);
  totalFilasPrueba := 0;
  totalColumnasPrueba := 0;
  indiceColumnaClasePrueba := -1;

  SetLength(matrizDatosNormalizados, 0);
  SetLength(minValoresNormalizacion, 0);
  SetLength(maxValoresNormalizacion, 0);
  SetLength(mediasNormalizacion, 0);
  SetLength(desviacionesNormalizacion, 0);
  SetLength(factoresDecimalScaling, 0);

  if (totalFilasDatos > 0) and (totalColumnasDatos > 0) then
  begin
    { Inicializar el ComboBox en Min-Max y recalcular con el método actual }
    cmbMetodoNormalizacion.ItemIndex := 0;
    AplicarNormalizacionActual;
  end;

  CargarGridDesdeMatriz(matrizDatosOriginales);
  tipoGraficaActual := tgNinguna;
  CargarComboBoxColumnas;
  EntrenarNaiveBayes;
end;

//Funcion para cargar el archvio
procedure TForm1.btnCargarArchivosClick(Sender: TObject);
begin
  dialogoAbrirArchivo.Title := 'Seleccionar archivo';
  dialogoAbrirArchivo.Filter := 'CSV o TXT (*.csv;*.txt)|*.csv;*.txt|Todos los archivos|*.*';
  dialogoAbrirArchivo.Options := dialogoAbrirArchivo.Options + [ofFileMustExist, ofPathMustExist];
  if dialogoAbrirArchivo.Execute then
    CargarGridDatos(dialogoAbrirArchivo.FileName);
end;

procedure TForm1.btnOriginalesClick(Sender: TObject);
begin
  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
  begin
    ShowMessage('No hay datos cargados.');
    Exit;
  end;

  CargarGridDesdeMatriz(matrizDatosOriginales);
end;

procedure TForm1.btnNormalizadosClick(Sender: TObject);
begin
  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
  begin
    ShowMessage('No hay datos cargados.');
    Exit;
  end;

  AplicarNormalizacionActual;
end;

procedure TForm1.btnGraficarClick(Sender: TObject);
begin
  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
  begin
    ShowMessage('No hay datos cargados.');
    Exit;
  end;

  case cmbTipoGrafica.ItemIndex of

    // Barras
    1:
    begin
      tipoGraficaActual := tgBarras;

      cBoxColumnaA.Enabled := False;
      cBoxColumnaB.Enabled := False;

      PrepararGraficaClases;
    end;

    // Dispersion
    2:
    begin
      tipoGraficaActual := tgDispersion;

      cBoxColumnaA.Enabled := True;
      cBoxColumnaB.Enabled := True;

      if (cBoxColumnaA.ItemIndex < 0) or
         (cBoxColumnaB.ItemIndex < 0) then
      begin
        ShowMessage('Seleccione ambas columnas para la grafica de dispersion.');
        Exit;
      end;

      if cBoxColumnaA.ItemIndex =
         cBoxColumnaB.ItemIndex then
      begin
        ShowMessage('Las columnas seleccionadas deben ser diferentes.');
        Exit;
      end;

      PrepararGraficaDispersion;
    end;

    // BoxPlot
    3:
    begin
      tipoGraficaActual := tgBoxPlot;

      cBoxColumnaA.Enabled := True;
      cBoxColumnaB.Enabled := False;

      if cBoxColumnaA.ItemIndex < 0 then
      begin
        ShowMessage('Seleccione una columna para BoxPlot.');
        Exit;
      end;

      PrepararGraficaBoxPlot;
    end;

  else
    tipoGraficaActual := tgNinguna;
  end;

  paintBoxClases.Invalidate;
end;

procedure TForm1.btnExportarNormalizadosClick(Sender: TObject);
begin
  if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
  begin
    ShowMessage('No hay datos cargados.');
    Exit;
  end;

  if not NormalizadosDisponibles then
  begin
    ShowMessage('No hay datos normalizados para exportar.');
    Exit;
  end;

  ExportarMatrizCSV(matrizDatosNormalizados);
end;

procedure TForm1.btnMediaClick(Sender: TObject);
begin
  EjecutarEstadistica(teMedia);
end;

procedure TForm1.btnMedianaClick(Sender: TObject);
begin
  EjecutarEstadistica(teMediana);
end;

procedure TForm1.btnDesviacionClick(Sender: TObject);
begin
  EjecutarEstadistica(teDesviacion);
end;



end.


