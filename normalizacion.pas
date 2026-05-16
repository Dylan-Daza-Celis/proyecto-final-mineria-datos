unit Normalizacion;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Matrices, Estadisticas;

procedure CalcularMinMaxNormalizacion(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  out MinValoresNormalizacion, MaxValoresNormalizacion: TArregloDouble);
procedure CalcularParametrosZScore(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  out MediasNormalizacion, DesviacionesNormalizacion: TArregloDouble);
procedure CalcularParametrosDecimalScaling(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  out FactoresDecimalScaling: TArregloEntero);

procedure NormalizarMatrizMinMax(const MatrizEntrada: TMatrizString;
  const TotalColumnasDatos, IndiceColumnaClase: Integer;
  const MinValoresNormalizacion, MaxValoresNormalizacion: TArregloDouble;
  out MatrizSalida: TMatrizString);
procedure NormalizarMatrizZScore(const MatrizEntrada: TMatrizString;
  const TotalColumnasDatos, IndiceColumnaClase: Integer;
  const MediasNormalizacion, DesviacionesNormalizacion: TArregloDouble;
  out MatrizSalida: TMatrizString);
procedure NormalizarMatrizDecimalScaling(const MatrizEntrada: TMatrizString;
  const TotalColumnasDatos, IndiceColumnaClase: Integer;
  const FactoresDecimalScaling: TArregloEntero;
  out MatrizSalida: TMatrizString);

procedure NormalizarDatos(const Tipo: TTipoNormalizacion;
  const MatrizDatosOriginales: TMatrizString; const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  var MinValoresNormalizacion, MaxValoresNormalizacion, MediasNormalizacion, DesviacionesNormalizacion: TArregloDouble;
  var FactoresDecimalScaling: TArregloEntero;
  const MatrizDatosPrueba: TMatrizString; const TotalFilasPrueba, TotalColumnasPrueba: Integer;
  out MatrizDatosNormalizados, MatrizDatosPruebaNormalizados: TMatrizString);

implementation

procedure CalcularMinMaxNormalizacion(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  out MinValoresNormalizacion, MaxValoresNormalizacion: TArregloDouble);
var
  col: Integer;
  fila: Integer;
  valor: Double;
  texto: string;
  formatos: TFormatSettings;
  tieneMinMax: TArregloBool;
begin
  SetLength(MinValoresNormalizacion, TotalColumnasDatos);
  SetLength(MaxValoresNormalizacion, TotalColumnasDatos);
  SetLength(tieneMinMax, TotalColumnasDatos);

  for col := 0 to TotalColumnasDatos - 1 do
  begin
    MinValoresNormalizacion[col] := 0;
    MaxValoresNormalizacion[col] := 0;
    tieneMinMax[col] := False;
  end;

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  for fila := 0 to TotalFilasDatos - 1 do
  begin
    for col := 0 to TotalColumnasDatos - 1 do
    begin
      if col = IndiceColumnaClase then
        Continue;

      texto := Trim(MatrizDatosOriginales[fila][col]);
      if (texto = '') or (not TryStrToFloat(texto, valor, formatos)) then
        Continue;

      if not tieneMinMax[col] then
      begin
        MinValoresNormalizacion[col] := valor;
        MaxValoresNormalizacion[col] := valor;
        tieneMinMax[col] := True;
      end
      else
      begin
        if valor < MinValoresNormalizacion[col] then
          MinValoresNormalizacion[col] := valor;
        if valor > MaxValoresNormalizacion[col] then
          MaxValoresNormalizacion[col] := valor;
      end;
    end;
  end;
end;

procedure CalcularParametrosZScore(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  out MediasNormalizacion, DesviacionesNormalizacion: TArregloDouble);
var
  col: Integer;
  fila: Integer;
  valor: Double;
  texto: string;
  formatos: TFormatSettings;
  valores: TArregloDouble;
  indice: Integer;
  media: Double;
  desviacion: Double;
begin
  SetLength(MediasNormalizacion, TotalColumnasDatos);
  SetLength(DesviacionesNormalizacion, TotalColumnasDatos);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  for col := 0 to TotalColumnasDatos - 1 do
  begin
    if col = IndiceColumnaClase then
    begin
      MediasNormalizacion[col] := 0;
      DesviacionesNormalizacion[col] := 0;
      Continue;
    end;

    SetLength(valores, 0);
    indice := 0;

    for fila := 0 to TotalFilasDatos - 1 do
    begin
      texto := Trim(MatrizDatosOriginales[fila][col]);
      if (texto = '') or (not TryStrToFloat(texto, valor, formatos)) then
        Continue;

      if indice >= Length(valores) then
        SetLength(valores, indice + 1);
      valores[indice] := valor;
      Inc(indice);
    end;

    SetLength(valores, indice);
    CalcularMediaDesviacionPoblacional(valores, media, desviacion);
    MediasNormalizacion[col] := media;
    DesviacionesNormalizacion[col] := desviacion;
  end;
end;

procedure CalcularParametrosDecimalScaling(const MatrizDatosOriginales: TMatrizString;
  const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  out FactoresDecimalScaling: TArregloEntero);
var
  col: Integer;
  fila: Integer;
  valor: Double;
  texto: string;
  formatos: TFormatSettings;
  j: Integer;
  maxAbs: Double;
  temp: Double;
begin
  SetLength(FactoresDecimalScaling, TotalColumnasDatos);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  for col := 0 to TotalColumnasDatos - 1 do
  begin
    if col = IndiceColumnaClase then
    begin
      FactoresDecimalScaling[col] := 0;
      Continue;
    end;

    maxAbs := 0;
    for fila := 0 to TotalFilasDatos - 1 do
    begin
      texto := Trim(MatrizDatosOriginales[fila][col]);
      if (texto = '') or (not TryStrToFloat(texto, valor, formatos)) then
        Continue;

      if Abs(valor) > maxAbs then
        maxAbs := Abs(valor);
    end;

    if maxAbs = 0 then
      FactoresDecimalScaling[col] := 0
    else
    begin
      j := 0;
      temp := maxAbs;
      while temp >= 1 do
      begin
        temp := temp / 10;
        Inc(j);
      end;
      FactoresDecimalScaling[col] := j;
    end;
  end;
end;

procedure NormalizarMatrizMinMax(const MatrizEntrada: TMatrizString;
  const TotalColumnasDatos, IndiceColumnaClase: Integer;
  const MinValoresNormalizacion, MaxValoresNormalizacion: TArregloDouble;
  out MatrizSalida: TMatrizString);
var
  formatos: TFormatSettings;
  fila: Integer;
  col: Integer;
  valor: Double;
  rango: Double;
  texto: string;
  filasEntrada: Integer;
begin
  filasEntrada := Length(MatrizEntrada);
  SetLength(MatrizSalida, filasEntrada);
  for fila := 0 to filasEntrada - 1 do
    SetLength(MatrizSalida[fila], TotalColumnasDatos);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  for fila := 0 to filasEntrada - 1 do
  begin
    for col := 0 to TotalColumnasDatos - 1 do
    begin
      if col >= Length(MatrizEntrada[fila]) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      texto := MatrizEntrada[fila][col];
      if col = IndiceColumnaClase then
      begin
        MatrizSalida[fila][col] := texto;
        Continue;
      end;

      if (Trim(texto) = '') or (not TryStrToFloat(Trim(texto), valor, formatos)) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      if (col >= Length(MinValoresNormalizacion)) or
         (col >= Length(MaxValoresNormalizacion)) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      rango := MaxValoresNormalizacion[col] - MinValoresNormalizacion[col];
      if rango = 0 then
        valor := 0
      else
        valor := (valor - MinValoresNormalizacion[col]) / rango;

      MatrizSalida[fila][col] := FormatFloat('0.######', valor, formatos);
    end;
  end;
end;

procedure NormalizarMatrizZScore(const MatrizEntrada: TMatrizString;
  const TotalColumnasDatos, IndiceColumnaClase: Integer;
  const MediasNormalizacion, DesviacionesNormalizacion: TArregloDouble;
  out MatrizSalida: TMatrizString);
var
  formatos: TFormatSettings;
  fila: Integer;
  col: Integer;
  valor: Double;
  texto: string;
  filasEntrada: Integer;
  epsilon: Double;
begin
  filasEntrada := Length(MatrizEntrada);
  SetLength(MatrizSalida, filasEntrada);
  for fila := 0 to filasEntrada - 1 do
    SetLength(MatrizSalida[fila], TotalColumnasDatos);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';
  epsilon := 1e-10;

  for fila := 0 to filasEntrada - 1 do
  begin
    for col := 0 to TotalColumnasDatos - 1 do
    begin
      if col >= Length(MatrizEntrada[fila]) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      texto := MatrizEntrada[fila][col];
      if col = IndiceColumnaClase then
      begin
        MatrizSalida[fila][col] := texto;
        Continue;
      end;

      if (Trim(texto) = '') or (not TryStrToFloat(Trim(texto), valor, formatos)) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      if (col >= Length(MediasNormalizacion)) or
         (col >= Length(DesviacionesNormalizacion)) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      if Abs(DesviacionesNormalizacion[col]) < epsilon then
        valor := 0
      else
        valor := (valor - MediasNormalizacion[col]) / DesviacionesNormalizacion[col];

      MatrizSalida[fila][col] := FormatFloat('0.######', valor, formatos);
    end;
  end;
end;

procedure NormalizarMatrizDecimalScaling(const MatrizEntrada: TMatrizString;
  const TotalColumnasDatos, IndiceColumnaClase: Integer;
  const FactoresDecimalScaling: TArregloEntero;
  out MatrizSalida: TMatrizString);
var
  formatos: TFormatSettings;
  fila: Integer;
  col: Integer;
  valor: Double;
  texto: string;
  filasEntrada: Integer;
  divisor: Double;
  j: Integer;
  k: Integer;
begin
  filasEntrada := Length(MatrizEntrada);
  SetLength(MatrizSalida, filasEntrada);
  for fila := 0 to filasEntrada - 1 do
    SetLength(MatrizSalida[fila], TotalColumnasDatos);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  for fila := 0 to filasEntrada - 1 do
  begin
    for col := 0 to TotalColumnasDatos - 1 do
    begin
      if col >= Length(MatrizEntrada[fila]) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      texto := MatrizEntrada[fila][col];
      if col = IndiceColumnaClase then
      begin
        MatrizSalida[fila][col] := texto;
        Continue;
      end;

      if (Trim(texto) = '') or (not TryStrToFloat(Trim(texto), valor, formatos)) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      if (col >= Length(FactoresDecimalScaling)) then
      begin
        MatrizSalida[fila][col] := '';
        Continue;
      end;

      j := FactoresDecimalScaling[col];
      divisor := 1;
      for k := 0 to j - 1 do
        divisor := divisor * 10;

      if divisor > 0 then
        valor := valor / divisor;

      MatrizSalida[fila][col] := FormatFloat('0.######', valor, formatos);
    end;
  end;
end;

procedure NormalizarDatos(const Tipo: TTipoNormalizacion;
  const MatrizDatosOriginales: TMatrizString; const TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase: Integer;
  var MinValoresNormalizacion, MaxValoresNormalizacion, MediasNormalizacion, DesviacionesNormalizacion: TArregloDouble;
  var FactoresDecimalScaling: TArregloEntero;
  const MatrizDatosPrueba: TMatrizString; const TotalFilasPrueba, TotalColumnasPrueba: Integer;
  out MatrizDatosNormalizados, MatrizDatosPruebaNormalizados: TMatrizString);
begin
  SetLength(MatrizDatosNormalizados, 0);
  SetLength(MatrizDatosPruebaNormalizados, 0);

  if (TotalFilasDatos <= 0) or (TotalColumnasDatos <= 0) then
    Exit;

  case Tipo of
    tnMinMax:
      begin
        if (Length(MinValoresNormalizacion) <> TotalColumnasDatos) or
           (Length(MaxValoresNormalizacion) <> TotalColumnasDatos) then
          CalcularMinMaxNormalizacion(MatrizDatosOriginales, TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase,
            MinValoresNormalizacion, MaxValoresNormalizacion);
        NormalizarMatrizMinMax(MatrizDatosOriginales, TotalColumnasDatos, IndiceColumnaClase,
          MinValoresNormalizacion, MaxValoresNormalizacion, MatrizDatosNormalizados);
      end;
    tnZScore:
      begin
        CalcularParametrosZScore(MatrizDatosOriginales, TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase,
          MediasNormalizacion, DesviacionesNormalizacion);
        NormalizarMatrizZScore(MatrizDatosOriginales, TotalColumnasDatos, IndiceColumnaClase,
          MediasNormalizacion, DesviacionesNormalizacion, MatrizDatosNormalizados);
      end;
    tnDecimalScaling:
      begin
        CalcularParametrosDecimalScaling(MatrizDatosOriginales, TotalFilasDatos, TotalColumnasDatos, IndiceColumnaClase,
          FactoresDecimalScaling);
        NormalizarMatrizDecimalScaling(MatrizDatosOriginales, TotalColumnasDatos, IndiceColumnaClase,
          FactoresDecimalScaling, MatrizDatosNormalizados);
      end;
  end;

  if (TotalFilasPrueba > 0) and (TotalColumnasPrueba > 0) then
  begin
    case Tipo of
      tnMinMax:
        NormalizarMatrizMinMax(MatrizDatosPrueba, TotalColumnasDatos, IndiceColumnaClase,
          MinValoresNormalizacion, MaxValoresNormalizacion, MatrizDatosPruebaNormalizados);
      tnZScore:
        NormalizarMatrizZScore(MatrizDatosPrueba, TotalColumnasDatos, IndiceColumnaClase,
          MediasNormalizacion, DesviacionesNormalizacion, MatrizDatosPruebaNormalizados);
      tnDecimalScaling:
        NormalizarMatrizDecimalScaling(MatrizDatosPrueba, TotalColumnasDatos, IndiceColumnaClase,
          FactoresDecimalScaling, MatrizDatosPruebaNormalizados);
    end;
  end;
end;

end.

