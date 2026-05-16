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

end.

