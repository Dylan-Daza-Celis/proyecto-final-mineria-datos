unit Estadisticas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Matrices;

procedure OrdenarValores(var Valores: TArregloDouble);
procedure CalcularMediaDesviacionMuestral(const Valores: TArregloDouble;
  out Media, Desviacion: Double);
procedure CalcularMediaDesviacionPoblacional(const Valores: TArregloDouble;
  out Media, Desviacion: Double);
procedure CalcularEstadisticasNumericas(const MatrizDatosOriginales: TMatrizString;
  const TotalColumnasDatos, TotalFilasDatos, IndiceColumnaClase: Integer;
  out Medias, Medianas, Desviaciones: TArregloDouble;
  out ColumnasCalculadas: TArregloBool);

implementation

procedure OrdenarValores(var Valores: TArregloDouble);
  procedure QuickSort(var A: TArregloDouble; Izq, Der: Integer);
  var
    i: Integer;
    j: Integer;
    pivote: Double;
    temp: Double;
  begin
    i := Izq;
    j := Der;
    pivote := A[(Izq + Der) div 2];
    repeat
      while A[i] < pivote do
        Inc(i);
      while A[j] > pivote do
        Dec(j);
      if i <= j then
      begin
        temp := A[i];
        A[i] := A[j];
        A[j] := temp;
        Inc(i);
        Dec(j);
      end;
    until i > j;

    if Izq < j then
      QuickSort(A, Izq, j);
    if i < Der then
      QuickSort(A, i, Der);
  end;
begin
  if Length(Valores) > 1 then
    QuickSort(Valores, 0, High(Valores));
end;

procedure CalcularMediaDesviacionBase(const Valores: TArregloDouble;
  out Media, Desviacion: Double; const UsarMuestral: Boolean);
var
  i: Integer;
  suma: Double;
  sumaVarianza: Double;
begin
  Media := 0;
  Desviacion := 0;
  if Length(Valores) = 0 then
    Exit;

  suma := 0;
  for i := 0 to High(Valores) do
    suma := suma + Valores[i];
  Media := suma / Length(Valores);

  sumaVarianza := 0;
  for i := 0 to High(Valores) do
    sumaVarianza := sumaVarianza + (Valores[i] - Media) * (Valores[i] - Media);

  if UsarMuestral then
  begin
    if Length(Valores) > 1 then
      Desviacion := Sqrt(sumaVarianza / (Length(Valores) - 1))
    else
      Desviacion := 0;
  end
  else
  begin
    if Length(Valores) > 0 then
      Desviacion := Sqrt(sumaVarianza / Length(Valores))
    else
      Desviacion := 0;
  end;
end;

procedure CalcularMediaDesviacionMuestral(const Valores: TArregloDouble;
  out Media, Desviacion: Double);
begin
  CalcularMediaDesviacionBase(Valores, Media, Desviacion, True);
end;

procedure CalcularMediaDesviacionPoblacional(const Valores: TArregloDouble;
  out Media, Desviacion: Double);
begin
  CalcularMediaDesviacionBase(Valores, Media, Desviacion, False);
end;

procedure CalcularEstadisticasNumericas(const MatrizDatosOriginales: TMatrizString;
  const TotalColumnasDatos, TotalFilasDatos, IndiceColumnaClase: Integer;
  out Medias, Medianas, Desviaciones: TArregloDouble;
  out ColumnasCalculadas: TArregloBool);
var
  valores: TArregloDouble;
  col: Integer;
  fila: Integer;
  indice: Integer;
  totalValores: Integer;
  media: Double;
  mediana: Double;
  desviacion: Double;
  numero: Double;
  valorTexto: string;
  formatos: TFormatSettings;
begin
  SetLength(Medias, TotalColumnasDatos);
  SetLength(Medianas, TotalColumnasDatos);
  SetLength(Desviaciones, TotalColumnasDatos);
  SetLength(ColumnasCalculadas, TotalColumnasDatos);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  for col := 0 to TotalColumnasDatos - 1 do
  begin
    Medias[col] := 0;
    Medianas[col] := 0;
    Desviaciones[col] := 0;
    ColumnasCalculadas[col] := False;

    if col = IndiceColumnaClase then
      Continue;

    totalValores := 0;
    SetLength(valores, 0);

    for fila := 0 to TotalFilasDatos - 1 do
    begin
      valorTexto := Trim(MatrizDatosOriginales[fila][col]);
      if valorTexto = '' then
        Continue;

      if not TryStrToFloat(valorTexto, numero, formatos) then
        Continue;

      Inc(totalValores);
      SetLength(valores, totalValores);
      valores[totalValores - 1] := numero;
    end;

    if totalValores = 0 then
    begin
      ColumnasCalculadas[col] := False;
      Continue;
    end;

    CalcularMediaDesviacionMuestral(valores, media, desviacion);

    OrdenarValores(valores);
    if (totalValores mod 2) = 1 then
      mediana := valores[totalValores div 2]
    else
      mediana := (valores[(totalValores div 2) - 1] + valores[totalValores div 2]) / 2;

    Medias[col] := media;
    Medianas[col] := mediana;
    Desviaciones[col] := desviacion;
    ColumnasCalculadas[col] := True;
  end;
end;

end.

