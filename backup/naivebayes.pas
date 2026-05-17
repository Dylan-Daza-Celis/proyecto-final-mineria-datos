unit NaiveBayes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math, Matrices, Estadisticas;

type
  TNaiveBayesModel = record
    Clases: TStringList;
    Priors: TArregloDouble;
    Medias: TArregloDoble2D;
    Desv: TArregloDoble2D;
    Conteos: TArregloEntero;
    NumAtributos: Integer;
    Entrenado: Boolean;
  end;

  TNaiveBayesResultadoEvaluacion = record
    TotalRegistros: Integer;
    Aciertos: Integer;
    Errores: Integer;
    Invalidos: Integer;
    Accuracy: Double;
    TasaError: Double;
    ClasesReales: TArregloString;
    ClasesPredichas: TArregloString;
    MatrizConfusion: TArregloEntero2D;
    EtiquetasConfusion: TStringList;
  end;

  TIndiceFold = array of Integer;
  TFolds = array of TIndiceFold;
  TResultadoFold = record
    Accuracy: Double;
    TasaError: Double;
    Correctos: Integer;
    Incorrectos: Integer;
    TotalRegistros: Integer;
  end;
  TResultadosFoldArray = array of TResultadoFold;
  TResultadoKFold = record
    NumFolds: Integer;
    ResultadosPorFold: TResultadosFoldArray;
    AccuracyPromedio: Double;
    TasaErrorPromedio: Double;
    DesviacionEstandar: Double;
    MatrizConfusionGlobal: TArregloEntero2D;
    EtiquetasConfusionGlobal: TStringList;
    TotalCorrectos: Integer;
    TotalIncorrectos: Integer;
  end;

procedure InicializarModeloNaiveBayes(var Modelo: TNaiveBayesModel);
procedure LiberarModeloNaiveBayes(var Modelo: TNaiveBayesModel);

procedure EntrenarNaiveBayes(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  var Modelo: TNaiveBayesModel);

function ProbabilidadGaussiana(const X, Media, Desv: Double): Double;
procedure ObtenerProbabilidadesPorClase(const Registro: TArregloDouble;
  const Modelo: TNaiveBayesModel; out Probabilidades: TArregloDouble);
function ClasificarRegistro(const Registro: TArregloDouble;
  const Modelo: TNaiveBayesModel; out Probabilidades: TArregloDouble): string;

procedure ConstruirMatrizConfusion(const ClasesReales,
  ClasesPredichas: TArregloString; out ClasesUnicas: TStringList;
  out MatrizConfusion: TArregloEntero2D);

procedure EvaluarConjuntoPruebaNaiveBayes(const MatrizDatosPrueba: TMatrizString;
  const TotalFilasPrueba, TotalColumnasPrueba, IndiceColumnaClasePrueba: Integer;
  const Modelo: TNaiveBayesModel; out Resultado: TNaiveBayesResultadoEvaluacion);

procedure MezclarIndices(var Indices: array of Integer);
procedure ValidarClasesParaKFold(const MatrizDatos: TMatrizString;
  const TotalFilas, IndiceColumnaClase, NumFolds: Integer; out MensajeError: string);
procedure CrearFoldsEstratificados(const MatrizDatos: TMatrizString;
  const TotalFilas, IndiceColumnaClase: Integer; const NumFolds: Integer;
  out Folds: TFolds);
procedure ExtraerSubmatriz(const MatrizOrigen: TMatrizString;
  const Indices: array of Integer; out MatrizDestino: TMatrizString);
procedure InitializeEvaluacion(out Resultado: TNaiveBayesResultadoEvaluacion);
procedure EjecutarKFold(const MatrizDatos: TMatrizString;
  const TotalFilas, TotalColumnas, IndiceColumnaClase: Integer;
  const NumFolds: Integer; out ResultadoKFold: TResultadoKFold);

implementation

procedure InicializarModeloNaiveBayes(var Modelo: TNaiveBayesModel);
begin
  Modelo.Clases := nil;
  SetLength(Modelo.Priors, 0);
  SetLength(Modelo.Medias, 0);
  SetLength(Modelo.Desv, 0);
  SetLength(Modelo.Conteos, 0);
  Modelo.NumAtributos := 0;
  Modelo.Entrenado := False;
end;

procedure LiberarModeloNaiveBayes(var Modelo: TNaiveBayesModel);
begin
  if Assigned(Modelo.Clases) then
  begin
    Modelo.Clases.Free;
    Modelo.Clases := nil;
  end;
  SetLength(Modelo.Priors, 0);
  SetLength(Modelo.Medias, 0);
  SetLength(Modelo.Desv, 0);
  SetLength(Modelo.Conteos, 0);
  Modelo.NumAtributos := 0;
  Modelo.Entrenado := False;
end;

procedure EntrenarNaiveBayes(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  var Modelo: TNaiveBayesModel);
var
  clasesTemp: TStringList;
  conteosTemp: TArregloEntero;
  valoresClaseAttr: array of array of TArregloDouble;
  i: Integer;
  j: Integer;
  fila: Integer;
  idxClase: Integer;
  numAtrib: Integer;
  numero: Double;
  clase: string;
  formatos: TFormatSettings;
begin
  Modelo.Entrenado := False;
  Modelo.NumAtributos := 0;
  SetLength(Modelo.Priors, 0);
  SetLength(Modelo.Medias, 0);
  SetLength(Modelo.Desv, 0);
  SetLength(Modelo.Conteos, 0);

  if (TotalFilasDatos <= 0) or (TotalColumnasDatos <= 1) then
    Exit;

  numAtrib := IndiceColumnaClase;
  if numAtrib <= 0 then
    Exit;

  clasesTemp := TStringList.Create;
  try
    SetLength(conteosTemp, 0);

    for fila := 0 to TotalFilasDatos - 1 do
    begin
      clase := Trim(MatrizDatosOriginales[fila][IndiceColumnaClase]);
      if clase = '' then
        clase := 'SinClase';

      idxClase := clasesTemp.IndexOf(clase);
      if idxClase < 0 then
      begin
        idxClase := clasesTemp.Add(clase);
        SetLength(conteosTemp, clasesTemp.Count);
        conteosTemp[idxClase] := 1;
      end
      else
        Inc(conteosTemp[idxClase]);
    end;

    if clasesTemp.Count = 0 then
      Exit;

    if Assigned(Modelo.Clases) then
      Modelo.Clases.Free;
    Modelo.Clases := TStringList.Create;
    Modelo.Clases.Assign(clasesTemp);

    Modelo.NumAtributos := numAtrib;

    SetLength(Modelo.Priors, Modelo.Clases.Count);
    SetLength(Modelo.Conteos, Modelo.Clases.Count);
    for i := 0 to Modelo.Clases.Count - 1 do
      Modelo.Conteos[i] := conteosTemp[i];

    for i := 0 to Modelo.Clases.Count - 1 do
      Modelo.Priors[i] := Modelo.Conteos[i] / TotalFilasDatos;

    SetLength(Modelo.Medias, Modelo.Clases.Count);
    SetLength(Modelo.Desv, Modelo.Clases.Count);
    for i := 0 to Modelo.Clases.Count - 1 do
    begin
      SetLength(Modelo.Medias[i], Modelo.NumAtributos);
      SetLength(Modelo.Desv[i], Modelo.NumAtributos);
    end;

    SetLength(valoresClaseAttr, Modelo.Clases.Count);
    for i := 0 to Modelo.Clases.Count - 1 do
    begin
      SetLength(valoresClaseAttr[i], Modelo.NumAtributos);
      for j := 0 to Modelo.NumAtributos - 1 do
        SetLength(valoresClaseAttr[i][j], 0);
    end;

    formatos := DefaultFormatSettings;
    formatos.DecimalSeparator := '.';

    for fila := 0 to TotalFilasDatos - 1 do
    begin
      clase := Trim(MatrizDatosOriginales[fila][IndiceColumnaClase]);
      if clase = '' then
        clase := 'SinClase';

      idxClase := Modelo.Clases.IndexOf(clase);
      if idxClase < 0 then
        Continue;

      for j := 0 to Modelo.NumAtributos - 1 do
      begin
        if not TryStrToFloat(Trim(MatrizDatosOriginales[fila][j]), numero, formatos) then
          Continue;

        SetLength(valoresClaseAttr[idxClase][j],
          Length(valoresClaseAttr[idxClase][j]) + 1);
        valoresClaseAttr[idxClase][j][High(valoresClaseAttr[idxClase][j])] := numero;
      end;
    end;

    for i := 0 to Modelo.Clases.Count - 1 do
    begin
      for j := 0 to Modelo.NumAtributos - 1 do
      begin
        if Length(valoresClaseAttr[i][j]) = 0 then
        begin
          Modelo.Medias[i][j] := 0;
          Modelo.Desv[i][j] := 1e-3;
        end
        else
        begin
          CalcularMediaDesviacionMuestral(valoresClaseAttr[i][j],
            Modelo.Medias[i][j], Modelo.Desv[i][j]);
          if Modelo.Desv[i][j] < 1e-3 then
            Modelo.Desv[i][j] := 1e-3;
        end;
      end;
    end;

    Modelo.Entrenado := True;
  finally
    clasesTemp.Free;
  end;
end;

function ProbabilidadGaussiana(const X, Media, Desv: Double): Double;
var
  sigma: Double;
begin
  sigma := Desv;
  if sigma <= 0 then
    sigma := 1e-3;

  Result := (1 / (Sqrt(2 * Pi) * sigma)) *
    Exp(-Sqr(X - Media) / (2 * Sqr(sigma)));
end;

procedure ObtenerProbabilidadesPorClase(const Registro: TArregloDouble;
  const Modelo: TNaiveBayesModel; out Probabilidades: TArregloDouble);
var
  i: Integer;
  j: Integer;
  logProb: Double;
  maxLog: Double;
  suma: Double;
  p: Double;
  logProbs: TArregloDouble;
begin
  SetLength(Probabilidades, 0);

  if not Modelo.Entrenado then
    Exit;

  if Length(Registro) < Modelo.NumAtributos then
    Exit;

  SetLength(logProbs, Modelo.Clases.Count);
  maxLog := -1.0e300;

  for i := 0 to Modelo.Clases.Count - 1 do
  begin
    if Modelo.Priors[i] <= 0 then
      logProb := -1.0e300
    else
      logProb := Ln(Modelo.Priors[i]);

    for j := 0 to Modelo.NumAtributos - 1 do
    begin
      p := ProbabilidadGaussiana(Registro[j], Modelo.Medias[i][j], Modelo.Desv[i][j]);
      if p <= 0 then
        logProb := logProb + Ln(1e-12)
      else
        logProb := logProb + Ln(p);
    end;

    logProbs[i] := logProb;
    if logProb > maxLog then
      maxLog := logProb;
  end;

  suma := 0;
  SetLength(Probabilidades, Modelo.Clases.Count);
  for i := 0 to Modelo.Clases.Count - 1 do
  begin
    Probabilidades[i] := Exp(logProbs[i] - maxLog);
    suma := suma + Probabilidades[i];
  end;

  if suma > 0 then
    for i := 0 to Modelo.Clases.Count - 1 do
      Probabilidades[i] := Probabilidades[i] / suma;
end;

function ClasificarRegistro(const Registro: TArregloDouble;
  const Modelo: TNaiveBayesModel; out Probabilidades: TArregloDouble): string;
var
  i: Integer;
  idxMax: Integer;
  maxProb: Double;
begin
  Result := '';
  ObtenerProbabilidadesPorClase(Registro, Modelo, Probabilidades);
  if (not Modelo.Entrenado) or (Length(Probabilidades) = 0) then
    Exit;

  idxMax := 0;
  maxProb := Probabilidades[0];
  for i := 1 to High(Probabilidades) do
  begin
    if Probabilidades[i] > maxProb then
    begin
      maxProb := Probabilidades[i];
      idxMax := i;
    end;
  end;

  if (idxMax >= 0) and (idxMax < Modelo.Clases.Count) then
    Result := Modelo.Clases[idxMax];
end;

function ObtenerIndiceClase(const Clase: string; const Clases: TStringList): Integer;
begin
  Result := -1;
  if not Assigned(Clases) then
    Exit;
  Result := Clases.IndexOf(Clase);
end;

procedure ConstruirMatrizConfusion(const ClasesReales,
  ClasesPredichas: TArregloString; out ClasesUnicas: TStringList;
  out MatrizConfusion: TArregloEntero2D);
var
  i: Integer;
  idxReal: Integer;
  idxPred: Integer;
begin
  ClasesUnicas := TStringList.Create;
  SetLength(MatrizConfusion, 0);

  if Length(ClasesReales) <> Length(ClasesPredichas) then
    Exit;

  for i := 0 to High(ClasesReales) do
  begin
    if ObtenerIndiceClase(ClasesReales[i], ClasesUnicas) < 0 then
      ClasesUnicas.Add(ClasesReales[i]);
    if ObtenerIndiceClase(ClasesPredichas[i], ClasesUnicas) < 0 then
      ClasesUnicas.Add(ClasesPredichas[i]);
  end;

  SetLength(MatrizConfusion, ClasesUnicas.Count);
  for i := 0 to ClasesUnicas.Count - 1 do
  begin
    SetLength(MatrizConfusion[i], ClasesUnicas.Count);
    FillChar(MatrizConfusion[i][0], ClasesUnicas.Count * SizeOf(Integer), 0);
  end;

  for i := 0 to High(ClasesReales) do
  begin
    idxReal := ObtenerIndiceClase(ClasesReales[i], ClasesUnicas);
    idxPred := ObtenerIndiceClase(ClasesPredichas[i], ClasesUnicas);
    if (idxReal >= 0) and (idxPred >= 0) then
      Inc(MatrizConfusion[idxReal][idxPred]);
  end;
end;

procedure EvaluarConjuntoPruebaNaiveBayes(const MatrizDatosPrueba: TMatrizString;
  const TotalFilasPrueba, TotalColumnasPrueba, IndiceColumnaClasePrueba: Integer;
  const Modelo: TNaiveBayesModel; out Resultado: TNaiveBayesResultadoEvaluacion);
var
  fila: Integer;
  col: Integer;
  registrosValidos: Integer;
  registro: TArregloDouble;
  probabilidades: TArregloDouble;
  claseReal: string;
  clasePredicha: string;
  formatos: TFormatSettings;
  valorNumero: Double;
begin
  Resultado.TotalRegistros := 0;
  Resultado.Aciertos := 0;
  Resultado.Errores := 0;
  Resultado.Invalidos := 0;
  Resultado.Accuracy := 0;
  Resultado.TasaError := 0;
  Resultado.EtiquetasConfusion := nil;
  SetLength(Resultado.ClasesReales, 0);
  SetLength(Resultado.ClasesPredichas, 0);
  SetLength(Resultado.MatrizConfusion, 0);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  registrosValidos := 0;

  for fila := 0 to TotalFilasPrueba - 1 do
  begin
    SetLength(registro, TotalColumnasPrueba - 1);
    claseReal := Trim(MatrizDatosPrueba[fila][IndiceColumnaClasePrueba]);
    if claseReal = '' then
      claseReal := 'SinClase';

    for col := 0 to TotalColumnasPrueba - 2 do
    begin
      if not TryStrToFloat(Trim(MatrizDatosPrueba[fila][col]), valorNumero, formatos) then
      begin
        Inc(Resultado.Invalidos);
        SetLength(registro, 0);
        Break;
      end;
      registro[col] := valorNumero;
    end;

    if Length(registro) <> (TotalColumnasPrueba - 1) then
      Continue;

    clasePredicha := ClasificarRegistro(registro, Modelo, probabilidades);
    if clasePredicha = '' then
      clasePredicha := 'SinPrediccion';

    Inc(Resultado.TotalRegistros);
    SetLength(Resultado.ClasesReales, Resultado.TotalRegistros);
    SetLength(Resultado.ClasesPredichas, Resultado.TotalRegistros);
    Resultado.ClasesReales[Resultado.TotalRegistros - 1] := claseReal;
    Resultado.ClasesPredichas[Resultado.TotalRegistros - 1] := clasePredicha;

    if SameText(claseReal, clasePredicha) then
      Inc(Resultado.Aciertos)
    else
      Inc(Resultado.Errores);

    Inc(registrosValidos);
  end;

  if registrosValidos = 0 then
    Exit;

  ConstruirMatrizConfusion(Resultado.ClasesReales, Resultado.ClasesPredichas,
    Resultado.EtiquetasConfusion, Resultado.MatrizConfusion);

  if Resultado.TotalRegistros > 0 then
  begin
    Resultado.Accuracy := (Resultado.Aciertos / Resultado.TotalRegistros) * 100;
    Resultado.TasaError := (Resultado.Errores / Resultado.TotalRegistros) * 100;
  end;
end;

{ ========== K-Fold Cross Validation Estratificado ========== }

procedure MezclarIndices(var Indices: array of Integer);
var
  i, j, temp: Integer;
begin
  for i := High(Indices) downto 1 do
  begin
    j := Random(i + 1);
    temp := Indices[i];
    Indices[i] := Indices[j];
    Indices[j] := temp;
  end;
end;

procedure ValidarClasesParaKFold(const MatrizDatos: TMatrizString;
  const TotalFilas, IndiceColumnaClase, NumFolds: Integer; out MensajeError: string);
var
  clasesPresentes: TStringList;
  contadoresClases: array of Integer;
  clase: string;
  indiceClase: Integer;
  i, fila, clasesUnicas: Integer;
begin
  MensajeError := '';

  if (TotalFilas <= 0) or (NumFolds < 2) then
    Exit;

  clasesPresentes := TStringList.Create;
  try
    { Contar registros por clase }
    for fila := 0 to TotalFilas - 1 do
    begin
      if fila < Length(MatrizDatos) then
      begin
        if IndiceColumnaClase < Length(MatrizDatos[fila]) then
        begin
          clase := Trim(MatrizDatos[fila][IndiceColumnaClase]);
          if clase = '' then
            clase := 'SinClase';
          indiceClase := clasesPresentes.IndexOf(clase);
          if indiceClase < 0 then
            clasesPresentes.Add(clase);
        end;
      end;
    end;

    clasesUnicas := clasesPresentes.Count;
    SetLength(contadoresClases, clasesUnicas);
    for i := 0 to clasesUnicas - 1 do
      contadoresClases[i] := 0;

    { Contar registros por clase }
    for fila := 0 to TotalFilas - 1 do
    begin
      if fila < Length(MatrizDatos) then
      begin
        if IndiceColumnaClase < Length(MatrizDatos[fila]) then
        begin
          clase := Trim(MatrizDatos[fila][IndiceColumnaClase]);
          if clase = '' then
            clase := 'SinClase';
          indiceClase := clasesPresentes.IndexOf(clase);
          if indiceClase >= 0 then
            Inc(contadoresClases[indiceClase]);
        end;
      end;
    end;

    { Validar que cada clase tenga al menos NumFolds registros }
    for i := 0 to clasesUnicas - 1 do
    begin
      if contadoresClases[i] < NumFolds then
      begin
        MensajeError := 'La clase "' + clasesPresentes[i] + '" tiene ' +
          IntToStr(contadoresClases[i]) + ' registros, pero se requieren al menos ' +
          IntToStr(NumFolds) + ' para K-Fold con K=' + IntToStr(NumFolds) + '.';
        Break;
      end;
    end;

    SetLength(contadoresClases, 0);
  finally
    clasesPresentes.Free;
  end;
end;

procedure CrearFoldsEstratificados(const MatrizDatos: TMatrizString;
  const TotalFilas, IndiceColumnaClase: Integer; const NumFolds: Integer;
  out Folds: TFolds);
var
  indicesClases: array of array of Integer;
  contadoresClases: array of Integer;
  clasesPresentes: TStringList;
  clase: string;
  indiceClase: Integer;
  i, j, k, fila, idxFold, cantidadPorClase: Integer;
  clasesUnicas: Integer;
  indicesEnFold: array of Integer;
begin
  Randomize;
  SetLength(Folds, NumFolds);
  for i := 0 to NumFolds - 1 do
    SetLength(Folds[i], 0);

  if (TotalFilas <= 0) or (NumFolds < 2) or (NumFolds > TotalFilas) then
    Exit;

  clasesPresentes := TStringList.Create;
  try
    { Identificar clases únicas }
    for fila := 0 to TotalFilas - 1 do
    begin
      if fila < Length(MatrizDatos) then
      begin
        if IndiceColumnaClase < Length(MatrizDatos[fila]) then
        begin
          clase := Trim(MatrizDatos[fila][IndiceColumnaClase]);
          if clase = '' then
            clase := 'SinClase';
          if clasesPresentes.IndexOf(clase) < 0 then
            clasesPresentes.Add(clase);
        end;
      end;
    end;

    clasesUnicas := clasesPresentes.Count;
    SetLength(indicesClases, clasesUnicas);
    SetLength(contadoresClases, clasesUnicas);

    for i := 0 to clasesUnicas - 1 do
    begin
      SetLength(indicesClases[i], 0);
      contadoresClases[i] := 0;
    end;

    { Agrupar índices por clase }
    for fila := 0 to TotalFilas - 1 do
    begin
      if fila < Length(MatrizDatos) then
      begin
        if IndiceColumnaClase < Length(MatrizDatos[fila]) then
        begin
          clase := Trim(MatrizDatos[fila][IndiceColumnaClase]);
          if clase = '' then
            clase := 'SinClase';
          indiceClase := clasesPresentes.IndexOf(clase);
          if indiceClase >= 0 then
          begin
            SetLength(indicesClases[indiceClase], contadoresClases[indiceClase] + 1);
            indicesClases[indiceClase][contadoresClases[indiceClase]] := fila;
            Inc(contadoresClases[indiceClase]);
          end;
        end;
      end;
    end;

    { Mezclar índices en cada clase }
    for i := 0 to clasesUnicas - 1 do
      if contadoresClases[i] > 0 then
        MezclarIndices(indicesClases[i]);

    { Distribuir registros estratificadamente }
    SetLength(indicesEnFold, NumFolds);
    for i := 0 to NumFolds - 1 do
      indicesEnFold[i] := 0;

    for i := 0 to clasesUnicas - 1 do
    begin
      for j := 0 to contadoresClases[i] - 1 do
      begin
        idxFold := j mod NumFolds;
        cantidadPorClase := indicesEnFold[idxFold];
        SetLength(Folds[idxFold], cantidadPorClase + 1);
        Folds[idxFold][cantidadPorClase] := indicesClases[i][j];
        Inc(indicesEnFold[idxFold]);
      end;
    end;

    SetLength(indicesEnFold, 0);
  finally
    clasesPresentes.Free;
    SetLength(indicesClases, 0);
    SetLength(contadoresClases, 0);
  end;
end;

procedure ExtraerSubmatriz(const MatrizOrigen: TMatrizString;
  const Indices: array of Integer; out MatrizDestino: TMatrizString);
var
  i, j, cantReg: Integer;
begin
  SetLength(MatrizDestino, 0);

  if Length(Indices) = 0 then
    Exit;

  cantReg := Length(Indices);
  SetLength(MatrizDestino, cantReg);

  for i := 0 to cantReg - 1 do
  begin
    if Indices[i] < Length(MatrizOrigen) then
    begin
      SetLength(MatrizDestino[i], Length(MatrizOrigen[Indices[i]]));
      for j := 0 to Length(MatrizOrigen[Indices[i]]) - 1 do
        MatrizDestino[i][j] := MatrizOrigen[Indices[i]][j];
    end;
  end;
end;

procedure EjecutarKFold(const MatrizDatos: TMatrizString;
  const TotalFilas, TotalColumnas, IndiceColumnaClase: Integer;
  const NumFolds: Integer; out ResultadoKFold: TResultadoKFold);
var
  Folds: TFolds;
  indicesFold: array of Integer;
  indicesEntrenamiento: array of Integer;
  matrizEntrenamiento, matrizPrueba: TMatrizString;
  modeloTemp: TNaiveBayesModel;
  resultadoEval: TNaiveBayesResultadoEvaluacion;
  i, j, k, cantEntrenamiento: Integer;
  sumAccuracy, sumError, varianza: Double;
  clasesRealCopy, clasesPredCopy: TArregloString;
  m, n: Integer;
  mensajeErrorClases: string;
begin
  { Inicializar }
  ResultadoKFold.NumFolds := 0;
  SetLength(ResultadoKFold.ResultadosPorFold, 0);
  ResultadoKFold.AccuracyPromedio := 0;
  ResultadoKFold.TasaErrorPromedio := 0;
  ResultadoKFold.DesviacionEstandar := 0;
  SetLength(ResultadoKFold.MatrizConfusionGlobal, 0);
  ResultadoKFold.EtiquetasConfusionGlobal := nil;
  ResultadoKFold.TotalCorrectos := 0;
  ResultadoKFold.TotalIncorrectos := 0;

  { Validar entrada }
  if (TotalFilas <= 0) or (TotalColumnas <= 0) or (NumFolds < 2) or (NumFolds > TotalFilas) then
    Exit;

  { Validar que cada clase tenga suficientes registros }
  ValidarClasesParaKFold(MatrizDatos, TotalFilas, IndiceColumnaClase, NumFolds, mensajeErrorClases);
  { Se omite el Exit para permitir ejecución con clases con pocos registros }

  { Crear folds estratificados }
  CrearFoldsEstratificados(MatrizDatos, TotalFilas, IndiceColumnaClase, NumFolds, Folds);

  ResultadoKFold.NumFolds := NumFolds;
  SetLength(ResultadoKFold.ResultadosPorFold, NumFolds);

  sumAccuracy := 0;
  sumError := 0;

  { Acumular resultados para matriz global }
  SetLength(clasesRealCopy, 0);
  SetLength(clasesPredCopy, 0);
  m := 0;

  { Iterar sobre cada fold }
  for i := 0 to NumFolds - 1 do
  begin
    { Construir conjuntos de entrenamiento y prueba }
    SetLength(indicesEntrenamiento, 0);
    cantEntrenamiento := 0;

    for j := 0 to NumFolds - 1 do
    begin
      if j <> i then
      begin
        for k := 0 to High(Folds[j]) do
        begin
          SetLength(indicesEntrenamiento, cantEntrenamiento + 1);
          indicesEntrenamiento[cantEntrenamiento] := Folds[j][k];
          Inc(cantEntrenamiento);
        end;
      end;
    end;

    { Extraer submatrices }
    ExtraerSubmatriz(MatrizDatos, indicesEntrenamiento, matrizEntrenamiento);
    ExtraerSubmatriz(MatrizDatos, Folds[i], matrizPrueba);

    { Entrenar modelo }
    InicializarModeloNaiveBayes(modeloTemp);
    if Length(matrizEntrenamiento) > 0 then
    begin
      EntrenarNaiveBayes(matrizEntrenamiento, Length(matrizEntrenamiento),
        TotalColumnas, IndiceColumnaClase, modeloTemp);

      { Evaluar en fold de prueba }
      if modeloTemp.Entrenado and (Length(matrizPrueba) > 0) then
      begin
        InitializeEvaluacion(resultadoEval);
        EvaluarConjuntoPruebaNaiveBayes(matrizPrueba, Length(matrizPrueba),
          TotalColumnas, IndiceColumnaClase, modeloTemp, resultadoEval);

        { Guardar resultado del fold }
        ResultadoKFold.ResultadosPorFold[i].Accuracy := resultadoEval.Accuracy;
        ResultadoKFold.ResultadosPorFold[i].TasaError := resultadoEval.TasaError;
        ResultadoKFold.ResultadosPorFold[i].Correctos := resultadoEval.Aciertos;
        ResultadoKFold.ResultadosPorFold[i].Incorrectos := resultadoEval.Errores;
        ResultadoKFold.ResultadosPorFold[i].TotalRegistros := resultadoEval.TotalRegistros;

        sumAccuracy := sumAccuracy + resultadoEval.Accuracy;
        sumError := sumError + resultadoEval.TasaError;

        Inc(ResultadoKFold.TotalCorrectos, resultadoEval.Aciertos);
        Inc(ResultadoKFold.TotalIncorrectos, resultadoEval.Errores);

        { Acumular clases para matriz global }
        for j := 0 to High(resultadoEval.ClasesReales) do
        begin
          SetLength(clasesRealCopy, m + 1);
          SetLength(clasesPredCopy, m + 1);
          clasesRealCopy[m] := resultadoEval.ClasesReales[j];
          clasesPredCopy[m] := resultadoEval.ClasesPredichas[j];
          Inc(m);
        end;

        { Liberar resultado }
        if Assigned(resultadoEval.EtiquetasConfusion) then
          resultadoEval.EtiquetasConfusion.Free;
        SetLength(resultadoEval.ClasesReales, 0);
        SetLength(resultadoEval.ClasesPredichas, 0);
        SetLength(resultadoEval.MatrizConfusion, 0);
      end;
    end;

    LiberarModeloNaiveBayes(modeloTemp);
    SetLength(matrizEntrenamiento, 0);
    SetLength(matrizPrueba, 0);
    SetLength(indicesEntrenamiento, 0);
  end;

  { Calcular promedios y desviación estándar }
  if NumFolds > 0 then
  begin
    ResultadoKFold.AccuracyPromedio := sumAccuracy / NumFolds;
    ResultadoKFold.TasaErrorPromedio := sumError / NumFolds;

    { Calcular varianza y desviación estándar }
    varianza := 0;
    for i := 0 to NumFolds - 1 do
      varianza := varianza + Sqr(ResultadoKFold.ResultadosPorFold[i].Accuracy - ResultadoKFold.AccuracyPromedio);

    if NumFolds > 1 then
      varianza := varianza / (NumFolds - 1)
    else
      varianza := 0;

    ResultadoKFold.DesviacionEstandar := Sqrt(varianza);
  end;

  { Construir matriz de confusión global }
  if m > 0 then
  begin
    ConstruirMatrizConfusion(clasesRealCopy, clasesPredCopy,
      ResultadoKFold.EtiquetasConfusionGlobal, ResultadoKFold.MatrizConfusionGlobal);
  end;

  { Limpiar memoria }
  SetLength(Folds, 0);
  SetLength(clasesRealCopy, 0);
  SetLength(clasesPredCopy, 0);
  SetLength(indicesFold, 0);
  SetLength(indicesEntrenamiento, 0);
end;

procedure InitializeEvaluacion(out Resultado: TNaiveBayesResultadoEvaluacion);
begin
  Resultado.TotalRegistros := 0;
  Resultado.Aciertos := 0;
  Resultado.Errores := 0;
  Resultado.Invalidos := 0;
  Resultado.Accuracy := 0;
  Resultado.TasaError := 0;
  SetLength(Resultado.ClasesReales, 0);
  SetLength(Resultado.ClasesPredichas, 0);
  SetLength(Resultado.MatrizConfusion, 0);
  Resultado.EtiquetasConfusion := TStringList.Create;
end;

end.
