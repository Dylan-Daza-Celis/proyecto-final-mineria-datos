unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls, Menus, Grids,
  Buttons, ExtCtrls, Spin, Matrices, Estadisticas, Normalizacion,
  NaiveBayes, Graficas, DatosSinteticos, Agrupamiento, Agnes;

type

  { TForm1 }

  TTipoEstadistica = Matrices.TTipoEstadistica;
  TMatrizString = Matrices.TMatrizString;
  TArregloDouble = Matrices.TArregloDouble;
  TTipoGrafica = Matrices.TTipoGrafica;
  TArregloEntero = Matrices.TArregloEntero;
  TTipoNormalizacion = Matrices.TTipoNormalizacion;
  TArregloEntero2D = Matrices.TArregloEntero2D;
  TNombresColumnas = Matrices.TNombresColumnas;
  TArregloDoble2D = Matrices.TArregloDoble2D;
  

  TTipoVistaResultados =
  (
    vrNinguna,
    vrResultadosP,
    vrKFold,
    vrMatrizConfusion
  );

  TForm1 = class(TForm)
    btnCargarArchivos: TButton;
    btnOriginales: TButton;
    btnNormalizados: TButton;

    btnKFolds: TButton;
    btnCrearClases: TButton;
    btnGuardarSinteticos: TButton;
    btnLimpiarCanvas: TButton;
    cBoxColumnaA: TComboBox;
    cBoxColumnaB: TComboBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    cmbMetodoNormalizacion: TComboBox;
    cBoxClaseActual: TComboBox;
    dialogoAbrirArchivo: TOpenDialog;
    imgDatosSinteticos: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    btnExportarNormalizados: TButton;
    btnCargarPrueba: TButton;
    btnEvaluarPrueba: TButton;
    Label7: TLabel;
    lblPuntos: TLabel;
    lblNumClases: TLabel;
    btnDesviacion: TButton;
    btnGraficar: TButton;
    Label8: TLabel;
    cBoxTipoGrafica: TComboBox;
    gridDatos: TStringGrid;
    gridResultados: TStringGrid;
    Label9: TLabel;
    memoEvaluacion: TMemo;
    saveDialogExportar: TSaveDialog;
    lblKFolds: TLabel;
    spinNumClusters: TSpinEdit;
    lblNumClusters: TLabel;
    btnAGNES: TButton;
    btnMedia: TButton;
    btnMediana: TButton;
    lblClaseActual: TLabel;
    paintBoxClases: TPaintBox;
    spinNumClases: TSpinEdit;
    spinKFolds: TSpinEdit;
    procedure btnCargarArchivosClick(Sender: TObject);
    procedure btnCargarPruebaClick(Sender: TObject);
    procedure btnOriginalesClick(Sender: TObject);
    procedure btnNormalizadosClick(Sender: TObject);
    procedure btnExportarNormalizadosClick(Sender: TObject);
    procedure btnGraficarClick(Sender: TObject);
    procedure btnEvaluarPruebaClick(Sender: TObject);
    procedure btnKFoldsClick(Sender: TObject);
    procedure btnAGNESClick(Sender: TObject);
    procedure btnCrearClasesClick(Sender: TObject);
    procedure btnGuardarSinteticosClick(Sender: TObject);
    procedure btnLimpiarCanvasClick(Sender: TObject);
    procedure btnMediaClick(Sender: TObject);
    procedure btnMedianaClick(Sender: TObject);
    procedure btnDesviacionClick(Sender: TObject);
    procedure cBoxColumnaAChange(Sender: TObject);
    procedure cBoxColumnaBChange(Sender: TObject);
    procedure cBoxTipoGraficaChange(Sender: TObject);
    procedure cmbMetodoNormalizacionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgDatosSinteticosMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgDatosSinteticosResize(Sender: TObject);
    procedure gridResultadosClick(Sender: TObject);
    procedure gridResultadosSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure CargarGridDatos(const NombreArchivo: string);
    procedure paintBoxClasesPaint(Sender: TObject);
    procedure CargarComboBoxColumnas;
    procedure ValidarColumnasSeleccionadas(Sender: TObject);
    procedure ActualizarControlesGrafica;
    procedure ExportarMatrizNormalizada;
    procedure EjecutarEstadisticaSeleccionada(const Tipo: TTipoEstadistica);
    procedure EntrenarNaiveBayes;
    procedure LimpiarGridResultados;
    procedure MostrarMatrizConfusionEnGrid(const ClasesUnicas: TStringList;
      const MatrizConfusion: TArregloEntero2D);
    procedure MostrarResultadosKFoldEnGrid(const ResultadoKFold: NaiveBayes.TResultadoKFold);
    procedure MostrarResultadosClasificacionEnGrid;
    procedure EvaluarConjuntoPrueba;
    procedure InicializarGridResultados;
    procedure ActualizarContadorPuntosSinteticos;
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
    vistaActualResultados: TTipoVistaResultados;
    resultadoAGNES: Agrupamiento.TResultadoAGNES;
    procedure CargarDatosPrueba(const NombreArchivo: string);
    procedure AplicarNormalizacionActual;
    function NormalizadosDisponibles: Boolean;
    


  public

  end;

var
  Form1: TForm1;
  i: Integer;
  j: Integer;

implementation

{$R *.lfm}

{ TForm1 }

  procedure TForm1.FormCreate(Sender: TObject);
  begin
    totalFilasDatos := 0;
    totalColumnasDatos := 0;
    totalFilasPrueba := 0;
    indiceColumnaClasePrueba := -1;
    SetLength(matrizDatosOriginales, 0);
    SetLength(matrizDatosNormalizados, 0);
    SetLength(matrizDatosPrueba, 0);
    cBoxTipoGrafica.Items.Clear;
    cBoxTipoGrafica.Items.Add('Ninguna');
    cBoxTipoGrafica.Items.Add('Barras');
    SetLength(matrizDatosPruebaNormalizados, 0);
    SetLength(minValoresNormalizacion, 0);
    SetLength(maxValoresNormalizacion, 0);
    delimitadorArchivo := ',';
    delimitadorArchivoPrueba := ',';
    tipoGraficaActual := tgNinguna;
    dispersionLabelX := '';
    dispersionLabelY := '';
    totalColumnasPrueba := 0;
    indiceColumnaClase := -1;
    nbClases := nil;
    nbNumAtributos := 0;
    nbEntrenado := False;
    vistaActualResultados := vrNinguna;
    NaiveBayes.InicializarModeloNaiveBayes(nbModelo);
    SetLength(nbPriors, 0);
    SetLength(nbMedias, 0);
    cBoxTipoGrafica.Items.Add('Dispersion');
    cBoxTipoGrafica.Items.Add('BoxPlot');
    cBoxTipoGrafica.Items.Add('AGNES');
    cBoxTipoGrafica.ItemIndex := 0;
    cmbMetodoNormalizacion.Items.Clear;
    cmbMetodoNormalizacion.Items.Add('Min-Max');
    cmbMetodoNormalizacion.Items.Add('Z-Score');
    cBoxColumnaA.Visible := False;
    cBoxColumnaB.Visible := False;
    cmbMetodoNormalizacion.Items.Add('Decimal Scaling');
    cmbMetodoNormalizacion.ItemIndex := 0;
    tipoNormalizacionActual := tnMinMax;
    cBoxColumnaA.Items.Clear;
    cBoxColumnaB.Items.Clear;
    cBoxColumnaA.Enabled := False;
    cBoxColumnaB.Enabled := False;
    SetLength(nbDesv, 0);
    SetLength(nbConteos, 0);
    InicializarGridResultados;
    ActualizarControlesGrafica;
    cBoxClaseActual.Items.Clear;
    cBoxClaseActual.Text := '';
    cBoxClaseActual.ItemIndex := -1;
    memoEvaluacion.Clear;
    imgDatosSinteticos.Stretch := False;
    imgDatosSinteticos.Center := False;
    imgDatosSinteticos.Proportional := False;
    InicializarCanvas(imgDatosSinteticos);
    btnCrearClasesClick(nil);
    ActualizarContadorPuntosSinteticos;
    memoEvaluacion.ScrollBars := ssVertical;
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
    resumen: string;
  begin
    //Primero validamos que se haya cargado el conjunto P
    if totalFilasDatos <= 0 then
    begin
      ShowMessage('No hay datos de entrenamiento cargados.');
      Exit;
    end;
    //En caso de que aun no este entrenado el modelo, lo entrenamos
    if not nbEntrenado then
      EntrenarNaiveBayes;

    //Asignamos y validamos el numero de Folds
    numFolds := spinKFolds.Value;
    if numFolds < 2 then
    begin
      ShowMessage('El numero de folds debe ser mayor o igual a 2.');
      Exit;
    end;

    //Validamos que los Folds sean menores al numero de registros
    if numFolds > totalFilasDatos then
    begin
      ShowMessage('El numero de folds no puede ser mayor que el numero total de registros.');
      Exit;
    end;

    //Validamos que cada clase tenga suficientes registros
    NaiveBayes.ValidarClasesParaKFold(matrizDatosOriginales, totalFilasDatos,
      indiceColumnaClase, numFolds, mensajeValidacion);

    //Validamos que la funcion validarClases... haya funcionado correctamente
    if mensajeValidacion <> '' then
    begin
      ShowMessage('No se puede ejecutar K-Fold: ' + LineEnding + mensajeValidacion);
      Exit;
    end;

    //Ejecutamos K-Fold Cross Validation
    try
      NaiveBayes.EjecutarKFold(matrizDatosOriginales, totalFilasDatos, totalColumnasDatos,
        indiceColumnaClase, numFolds, resultadoKFold);
    except
      on E: Exception do
      begin
        ShowMessage('Error en K-Fold: ' + E.Message);
        Exit;
      end;
    end;

    //Validamos que se hayan procesado correctamente los Folds
    if resultadoKFold.NumFolds = 0 then
    begin
      ShowMessage('Error al ejecutar K-Fold Cross Validation.');
      Exit;
    end;

    //Mostramos al usuario los resultados
    MostrarResultadosKFoldEnGrid(resultadoKFold);
    vistaActualResultados := vrKFold;
    Graficas.LimpiarGrafica(paintBoxClases, '');

    //Validamos la existencia del memo
    if memoEvaluacion <> nil then
    begin
      memoEvaluacion.Lines.Clear;

      // Mostramos el resumen en memo con formato
      resumen := ' VALIDACION DE K-FOLD CROSS ' + LineEnding + LineEnding +
        'Configuracion:' + LineEnding +
        '  Numero de folds: ' + IntToStr(resultadoKFold.NumFolds) + LineEnding +
        '  Total registros: ' + IntToStr(totalFilasDatos) + LineEnding + LineEnding +

        'Resultados Globales:' + LineEnding +
        '  Accuracy Promedio: ' + FormatFloat('0.00', resultadoKFold.AccuracyPromedio) + '%' + LineEnding +
        '  Desviacion Estandar: ' + FormatFloat('0.0000', resultadoKFold.DesviacionEstandar) + LineEnding +
        '  Error Promedio: ' + FormatFloat('0.00', resultadoKFold.TasaErrorPromedio) + '%' + LineEnding +
        '  Total Correctos: ' + IntToStr(resultadoKFold.TotalCorrectos) + LineEnding +
        '  Total Incorrectos: ' + IntToStr(resultadoKFold.TotalIncorrectos) + LineEnding + LineEnding +

        'RESULTADOS POR FOLD: ' + LineEnding;

      //Detalles por fold
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

    //Liberamos espacios de memoria
    if Assigned(resultadoKFold.EtiquetasConfusionGlobal) then
      resultadoKFold.EtiquetasConfusionGlobal.Free;

    SetLength(resultadoKFold.ResultadosPorFold, 0);
    SetLength(resultadoKFold.MatrizConfusionGlobal, 0);
  end;

  procedure TForm1.btnAGNESClick(Sender: TObject);
  begin
    Agnes.EjecutarAGNESConGrafica(gridDatos, nombresColumnas, totalFilasDatos,
      cBoxColumnaA.ItemIndex, cBoxColumnaB.ItemIndex, spinNumClusters.Value,
      paintBoxClases, memoEvaluacion, resultadoAGNES);
  end;
  //Cargamos columnas disponibles para graficar y seleccionamos valores iniciales.
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

    // Se cargan todas las columnas excepto la ultima a los combBox para graficar
    for col := 0 to indiceColumnaClase - 1 do
    begin
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


  //Validamos que no se repita la columna en dispersion y AGNES.
  procedure TForm1.ValidarColumnasSeleccionadas(Sender: TObject);
  begin
    if (cBoxTipoGrafica.ItemIndex <> 2) and (cBoxTipoGrafica.ItemIndex <> 4) then
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

  procedure TForm1.cBoxTipoGraficaChange(Sender: TObject);
  begin
    ActualizarControlesGrafica;
  end;

  procedure TForm1.AplicarNormalizacionActual;
  var
    tipo: TTipoNormalizacion;
  begin
    //Validamos que tipo de normalizacion se escogio
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

    Matrices.CargarGridDesdeMatriz(gridDatos, matrizDatosNormalizados, nombresColumnas, totalFilasDatos, totalColumnasDatos);
  end;

  procedure TForm1.cmbMetodoNormalizacionChange(Sender: TObject);
  begin
    if cmbMetodoNormalizacion.ItemIndex < 0 then
      Exit;

    AplicarNormalizacionActual;
  end;

  //Validacion de que comboBox esta activo para las graficas, dependiendo del grafico utilizado
  procedure TForm1.ActualizarControlesGrafica;
  begin
    cBoxColumnaA.Visible := False;
    cBoxColumnaB.Visible := False;
    cBoxColumnaA.Enabled := False;
    cBoxColumnaB.Enabled := False;

    case cBoxTipoGrafica.ItemIndex of
      1:
        begin
          cBoxColumnaA.Visible := False;
          cBoxColumnaB.Visible := False;
          cBoxColumnaA.Enabled := False;
          cBoxColumnaB.Enabled := False;
        end;
      2, 4:
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

  //Validamos que todo este correcto antes de comenzar a normalizar
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

  procedure TForm1.ExportarMatrizNormalizada;
  begin
    saveDialogExportar.Title := 'Guardar CSV';
    saveDialogExportar.Filter := 'CSV (*.csv)|*.csv|Todos los archivos|*.*';
    saveDialogExportar.DefaultExt := 'csv';

    if not saveDialogExportar.Execute then
      Exit;

    Matrices.ExportarMatrizCSV(matrizDatosNormalizados, nombresColumnas,
      totalFilasDatos, totalColumnasDatos, delimitadorArchivo,
      saveDialogExportar.FileName);
  end;

  procedure TForm1.EjecutarEstadisticaSeleccionada(const Tipo: TTipoEstadistica);
  begin
    if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
    begin
      ShowMessage('No hay datos cargados.');
      Exit;
    end;

    Estadisticas.EjecutarEstadistica(gridDatos, matrizDatosOriginales,
      totalColumnasDatos, totalFilasDatos, indiceColumnaClase, Tipo);
  end;

  procedure TForm1.LimpiarGridResultados;
  begin
    if gridResultados = nil then
      Exit;

    gridResultados.Clean;
    gridResultados.FixedCols := 0;
    gridResultados.FixedRows := 0;
    gridResultados.ColCount := 1;
    gridResultados.RowCount := 1;
    gridResultados.Cells[0, 0] := '';
  end;

  procedure TForm1.InicializarGridResultados;
  begin
    LimpiarGridResultados;
    gridResultados.FixedRows := 1;
    gridResultados.Cells[0, 0] := 'Resultados';
  end;

  //Validamos que tipo de grafica se va pintar
  procedure TForm1.paintBoxClasesPaint(Sender: TObject);
  var
    mensajeError: string;
  begin
    case tipoGraficaActual of
      tgBarras:
        Graficas.MostrarGraficaClases(paintBoxClases, matrizDatosOriginales,
          totalFilasDatos, indiceColumnaClase);
      tgDispersion:
        begin
          Graficas.MostrarGraficaDispersion(paintBoxClases, matrizDatosOriginales,
            nombresColumnas, totalFilasDatos, indiceColumnaClase,
            cBoxColumnaA.ItemIndex, cBoxColumnaB.ItemIndex, mensajeError);
          if (Sender = nil) and (mensajeError <> '') then
            ShowMessage(mensajeError);
        end;
      tgBoxPlot:
        begin
          Graficas.MostrarGraficaBoxPlot(paintBoxClases, matrizDatosOriginales,
            totalFilasDatos, indiceColumnaClase, cBoxColumnaA.ItemIndex,
            mensajeError);
          if (Sender = nil) and (mensajeError <> '') then
            ShowMessage(mensajeError);
        end;
    else
      Graficas.LimpiarGrafica(paintBoxClases, 'Seleccione grafica y presione Graficar');
    end;
  end;

  procedure TForm1.CargarDatosPrueba(const NombreArchivo: string);
  begin
    if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
    begin
      ShowMessage('Primero cargue el conjunto de entrenamiento T.');
      Exit;
    end;

    Matrices.CargarDatosDesdeCSV(NombreArchivo, matrizDatosPrueba, nombresColumnasPrueba, totalFilasPrueba, totalColumnasPrueba, indiceColumnaClasePrueba, delimitadorArchivoPrueba);
    //Validamos que el archivo de prueba se haya cargado correctamente
    if totalColumnasPrueba <= 0 then
      Exit;

    //Validamos que contengan la misma cantidad de atributos
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

    NaiveBayes.LimpiarResultadosClasificacion;
    InicializarGridResultados;
    vistaActualResultados := vrNinguna;
    Graficas.LimpiarGrafica(paintBoxClases, '');
  end;

  //Hacemos una copia local de los atributos del entrenamiento
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

  //Funcion para pintar la matriz de confusion
  procedure TForm1.MostrarMatrizConfusionEnGrid(const ClasesUnicas: TStringList;
    const MatrizConfusion: TArregloEntero2D);
  begin
    //Valdamos que ya se hayan cargado las clases
    if not Assigned(ClasesUnicas) then
      Exit;

    LimpiarGridResultados;
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

    vistaActualResultados := vrMatrizConfusion;
    Graficas.LimpiarGrafica(paintBoxClases, '');
  end;

  //Funcion para mostrar los resultados de K Fold en el Grid
  procedure TForm1.MostrarResultadosKFoldEnGrid(const ResultadoKFold: NaiveBayes.TResultadoKFold);
  begin
    LimpiarGridResultados;
    gridResultados.FixedCols := 1;
    gridResultados.FixedRows := 1;
    gridResultados.ColCount := 5;
    gridResultados.RowCount := ResultadoKFold.NumFolds + 2;

    gridResultados.Cells[0, 0] := 'Fold';
    gridResultados.Cells[1, 0] := 'Accuracy %';
    gridResultados.Cells[2, 0] := 'Error %';
    gridResultados.Cells[3, 0] := 'Correctos';
    gridResultados.Cells[4, 0] := 'Incorrectos';

    for i := 0 to ResultadoKFold.NumFolds - 1 do
    begin
      gridResultados.Cells[0, i + 1] := 'Fold ' + IntToStr(i + 1);
      gridResultados.Cells[1, i + 1] := FormatFloat('0.00', ResultadoKFold.ResultadosPorFold[i].Accuracy) + '%';
      gridResultados.Cells[2, i + 1] := FormatFloat('0.00', ResultadoKFold.ResultadosPorFold[i].TasaError) + '%';
      gridResultados.Cells[3, i + 1] := IntToStr(ResultadoKFold.ResultadosPorFold[i].Correctos);
      gridResultados.Cells[4, i + 1] := IntToStr(ResultadoKFold.ResultadosPorFold[i].Incorrectos);
    end;

    gridResultados.Cells[0, ResultadoKFold.NumFolds + 1] := 'Promedio';
    gridResultados.Cells[1, ResultadoKFold.NumFolds + 1] := FormatFloat('0.00', ResultadoKFold.AccuracyPromedio) + '%';
    gridResultados.Cells[2, ResultadoKFold.NumFolds + 1] := FormatFloat('0.00', ResultadoKFold.TasaErrorPromedio) + '%';
    gridResultados.Cells[3, ResultadoKFold.NumFolds + 1] := IntToStr(ResultadoKFold.TotalCorrectos);
    gridResultados.Cells[4, ResultadoKFold.NumFolds + 1] := IntToStr(ResultadoKFold.TotalIncorrectos);

    vistaActualResultados := vrKFold;
    Graficas.LimpiarGrafica(paintBoxClases, '');
  end;

  //Funcion para llenar el Grid con los resultados de la clasificacion
  procedure TForm1.MostrarResultadosClasificacionEnGrid;
  var
    resultado: NaiveBayes.TResultadoClasificacion;
  begin
    LimpiarGridResultados;
    gridResultados.FixedCols := 1;
    gridResultados.FixedRows := 1;
    gridResultados.ColCount := 3;
    gridResultados.RowCount := NaiveBayes.ObtenerCantidadResultadosClasificacion + 1;

    gridResultados.Cells[0, 0] := 'Registro';
    gridResultados.Cells[1, 0] := 'Clase real';
    gridResultados.Cells[2, 0] := 'Clase predicha';

    for i := 0 to NaiveBayes.ObtenerCantidadResultadosClasificacion - 1 do
    begin
      resultado := NaiveBayes.ObtenerResultadoClasificacion(i);
      gridResultados.Cells[0, i + 1] := IntToStr(i + 1);
      gridResultados.Cells[1, i + 1] := resultado.ClaseReal;
      gridResultados.Cells[2, i + 1] := resultado.ClasePredicha;
    end;

    vistaActualResultados := vrResultadosP;
    Graficas.LimpiarGrafica(paintBoxClases, '');
  end;


  procedure TForm1.EvaluarConjuntoPrueba;
  var
    resultado: TNaiveBayesResultadoEvaluacion;
    resumen: string;
  begin
    //Validamos que se haya cargado el archivo T
    if totalFilasDatos <= 0 then
    begin
      ShowMessage('No hay datos de entrenamiento cargados.');
      Exit;
    end;

    //Validamos que se haya cargado el archivo P
    if totalFilasPrueba <= 0 then
    begin
      ShowMessage('No hay conjunto de prueba cargado.');
      Exit;
    end;
    //Validamos que los atributos de ambos conjuntos de datos
    if totalColumnasPrueba <> totalColumnasDatos then
    begin
      ShowMessage('El conjunto de prueba no coincide con la estructura de T.');
      Exit;
    end;
     //Valdiamos que las columnas de clase coincidan
    if indiceColumnaClasePrueba <> indiceColumnaClase then
    begin
      ShowMessage('La ultima columna del conjunto de prueba debe representar la clase.');
      Exit;
    end;
    //En caso de que un no este entrenado el clasificador lo entrenamos
    if not nbEntrenado then
      EntrenarNaiveBayes;
    //En caso que se haya intentado entrenar y no se haya podido se aborta la operacion
    if not nbEntrenado then
    begin
      ShowMessage('No se pudo entrenar Naive Bayes con los datos originales.');
      Exit;
    end;

    NaiveBayes.EvaluarConjuntoPruebaNaiveBayes(matrizDatosPrueba,
      totalFilasPrueba, totalColumnasPrueba, indiceColumnaClasePrueba,
      nbModelo, resultado);
    //E caso de que no se hayan encontrado registro abortamos
    if resultado.TotalRegistros = 0 then
    begin
      ShowMessage('No se encontraron registros validos para evaluar.');
      Exit;
    end;

    try
      MostrarResultadosClasificacionEnGrid;
      vistaActualResultados := vrResultadosP;
      Graficas.LimpiarGrafica(paintBoxClases, 'Seleccione una fila para ver probabilidades');
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

  procedure TForm1.imgDatosSinteticosMouseDown(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    claseActual: Integer;
    XCartesiano: Double;
    YCartesiano: Double;
  begin
    if Button <> mbLeft then
      Exit;

    if (cBoxClaseActual.ItemIndex < 0) or (cBoxClaseActual.ItemIndex >= cBoxClaseActual.Items.Count) then
    begin
      ShowMessage('Primero cree y seleccione una clase.');
      Exit;
    end;

    if spinNumClases.Value < 1 then
    begin
      ShowMessage('Debe crear al menos una clase.');
      Exit;
    end;

    claseActual := cBoxClaseActual.ItemIndex;
    ConvertirCoordenadasPantallaACartesianas(imgDatosSinteticos, X, Y,
      XCartesiano, YCartesiano);
    AgregarPuntoSintetico(XCartesiano, YCartesiano, claseActual);
    DibujarPunto(imgDatosSinteticos, XCartesiano, YCartesiano, claseActual);
    ActualizarContadorPuntosSinteticos;
  end;

  procedure TForm1.imgDatosSinteticosResize(Sender: TObject);
  begin
    if imgDatosSinteticos <> nil then
      RedibujarPuntos(imgDatosSinteticos);
  end;

  procedure TForm1.gridResultadosClick(Sender: TObject);
  begin
  end;

  procedure TForm1.gridResultadosSelectCell(Sender: TObject; Col, Row: Integer;
    var CanSelect: Boolean);
  var
    resultado: NaiveBayes.TResultadoClasificacion;
  begin
    CanSelect := True;

    if Row <= 0 then
      Exit;

    if vistaActualResultados <> vrResultadosP then
      Exit;

    if (Row - 1 < 0) or
        (Row - 1 >= NaiveBayes.ObtenerCantidadResultadosClasificacion) then
      Exit;

    resultado := NaiveBayes.ObtenerResultadoClasificacion(Row - 1);

    if Length(resultado.Probabilidades) = 0 then
      Exit;

    memoEvaluacion.Clear;
    memoEvaluacion.Lines.Add('Registro seleccionado: ' + IntToStr(Row));
    memoEvaluacion.Lines.Add('Clase real: ' + resultado.ClaseReal);
    memoEvaluacion.Lines.Add('Clase predicha: ' + resultado.ClasePredicha);
    memoEvaluacion.Lines.Add('');
    memoEvaluacion.Lines.Add('Probabilidades:');

    for i := 0 to High(resultado.Probabilidades) do
    begin
      if Assigned(nbClases) and (i < nbClases.Count) then
        memoEvaluacion.Lines.Add(
          nbClases[i] + ' -> ' +
          FormatFloat('0.00%', resultado.Probabilidades[i])
        );
    end;

    Graficas.MostrarGraficaProbabilidades(paintBoxClases, nbClases,
      resultado.Probabilidades);
  end;

  procedure TForm1.CargarGridDatos(const NombreArchivo: string);
  begin
    Matrices.CargarDatosDesdeCSV(NombreArchivo, matrizDatosOriginales, nombresColumnas, totalFilasDatos, totalColumnasDatos, indiceColumnaClase, delimitadorArchivo);

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
    InicializarGridResultados;

    if (totalFilasDatos > 0) and (totalColumnasDatos > 0) then
    begin
      { Inicializar el ComboBox en Min-Max y recalcular con el mÃ©todo actual }
      cmbMetodoNormalizacion.ItemIndex := 0;
      AplicarNormalizacionActual;
    end;

    Matrices.CargarGridDesdeMatriz(gridDatos, matrizDatosOriginales, nombresColumnas, totalFilasDatos, totalColumnasDatos);
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

  //Procedimiento para mostrar los datos originales
  procedure TForm1.btnOriginalesClick(Sender: TObject);
  begin
    if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
    begin
      ShowMessage('No hay datos cargados.');
      Exit;
    end;

    Matrices.CargarGridDesdeMatriz(gridDatos, matrizDatosOriginales, nombresColumnas, totalFilasDatos, totalColumnasDatos);
  end;

  //Procedimiento para mostrar los datos normalizados, no se recalculan si ya esta la matriz solo se muestran
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
    //Validamos que el conjunto T este cargado
    if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
    begin
      ShowMessage('No hay datos cargados.');
      Exit;
    end;

    case cBoxTipoGrafica.ItemIndex of

      //Opcion para grafica de barras
      1:
      begin
        tipoGraficaActual := tgBarras;

        cBoxColumnaA.Enabled := False;
        cBoxColumnaB.Enabled := False;

        paintBoxClasesPaint(nil);
      end;

      // Opcion para grafica de dispersion
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

        paintBoxClasesPaint(nil);
      end;

      // Opcion para grafica de boxPlot
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

        paintBoxClasesPaint(nil);
      end;

      // Opcion en caso de que sea la grafica AGNES
      4:
      begin
        Agnes.EjecutarAGNESConGrafica(gridDatos, nombresColumnas, totalFilasDatos,
          cBoxColumnaA.ItemIndex, cBoxColumnaB.ItemIndex, spinNumClusters.Value,
          paintBoxClases, memoEvaluacion, resultadoAGNES);
        Exit;
      end;

    else
      tipoGraficaActual := tgNinguna;
    end;

    paintBoxClases.Invalidate;
  end;

  procedure TForm1.btnExportarNormalizadosClick(Sender: TObject);
  begin
    //Validamos que haya datos cargados
    if (totalFilasDatos <= 0) or (totalColumnasDatos <= 0) then
    begin
      ShowMessage('No hay datos cargados.');
      Exit;
    end;
    //Si no se han normalizado los datos, no se pueden exportar
    if not NormalizadosDisponibles then
    begin
      ShowMessage('No hay datos normalizados para exportar.');
      Exit;
    end;

    ExportarMatrizNormalizada;
  end;

  procedure TForm1.btnMediaClick(Sender: TObject);
  begin
    EjecutarEstadisticaSeleccionada(teMedia);
  end;

  procedure TForm1.btnMedianaClick(Sender: TObject);
  begin
    EjecutarEstadisticaSeleccionada(teMediana);
  end;

  procedure TForm1.btnDesviacionClick(Sender: TObject);
  begin
    EjecutarEstadisticaSeleccionada(teDesviacion);
  end;

  procedure TForm1.ActualizarContadorPuntosSinteticos;
  begin
    if lblPuntos <> nil then
      lblPuntos.Caption := 'Puntos: ' + IntToStr(ObtenerCantidadPuntos);
  end;


  procedure TForm1.btnCrearClasesClick(Sender: TObject);
  begin
    cBoxClaseActual.Items.Clear;
    for i := 0 to spinNumClases.Value - 1 do
      cBoxClaseActual.Items.Add('Clase ' + IntToStr(i));

    if cBoxClaseActual.Items.Count > 0 then
      cBoxClaseActual.ItemIndex := 0;
  end;

  procedure TForm1.btnLimpiarCanvasClick(Sender: TObject);
  begin
    LimpiarDatosSinteticos(imgDatosSinteticos);
    ActualizarContadorPuntosSinteticos;
  end;

  procedure TForm1.btnGuardarSinteticosClick(Sender: TObject);
  begin
    //Validamos que haya puntos existentes para exportar
    if ObtenerCantidadPuntos = 0 then
    begin
      ShowMessage('No hay puntos para exportar.');
      Exit;
    end;

    saveDialogExportar.Title := 'Guardar datos sinteticos';
    saveDialogExportar.Filter := 'CSV (*.csv)|*.csv|Todos los archivos|*.*';
    saveDialogExportar.DefaultExt := 'csv';

    if not saveDialogExportar.Execute then
      Exit;

    ExportarDatosSinteticosCSV(saveDialogExportar.FileName, ',');
    ShowMessage('Datos sinteticos exportados correctamente a: ' + ExtractFileName(saveDialogExportar.FileName));
  end;



end.





