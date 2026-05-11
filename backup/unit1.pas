unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, Grids,
  Buttons, ExtCtrls, Math;

type

  { TForm1 }

  TTipoColumna = (tcContinua, tcCategorica, tcClase);
  TTipoEstadistica = (teMedia, teMediana, teDesviacion);
  TMatrizString = array of array of string;
  TArregloDouble = array of Double;
  TArregloBool = array of Boolean;

  TForm1 = class(TForm)
    btnCargarArchivos: TButton;
    btnMedia: TButton;
    btnMediana: TButton;
    btnDesviacion: TButton;
    dialogoAbrirArchivo: TOpenDialog;
    Edit1: TEdit;
    gridDatos: TStringGrid;
    Panel1: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnCargarArchivosClick(Sender: TObject);
    procedure btnMediaClick(Sender: TObject);
    procedure btnMedianaClick(Sender: TObject);
    procedure btnDesviacionClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CargarGridDatos(const NombreArchivo: string);
    function DetectarDelimitador(const Linea: string): Char;
    procedure GroupBox1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
  private
    matrizDatos: TMatrizString;
    tiposColumnas: array of TTipoColumna;
    categoriasPorColumna: array of Integer;
    nombresColumnas: array of string;
    indiceColumnaClase: Integer;
    totalFilasDatos: Integer;
    totalColumnasDatos: Integer;
    procedure LeerNombresColumnas(const LineaAtributos: string;
      const TotalColumnas: Integer; const Delimitador: Char);
    procedure AnalizarColumnasDatos;
    procedure OrdenarValores(var Valores: TArregloDouble);
    procedure CalcularEstadisticasNumericas(out Medias, Medianas,
      Desviaciones: TArregloDouble; out ColumnasCalculadas: TArregloBool);
    procedure AgregarFilaEstadistica(const Valores: TArregloDouble;
      const ColumnasCalculadas: TArregloBool; const FilaDestino: Integer);
    procedure EjecutarEstadistica(const Tipo: TTipoEstadistica);
    procedure ActualizarResumenColumnas;


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
end;

procedure TForm1.ActualizarResumenColumnas;
var
  totalContinuas: Integer;
  totalCategoricas: Integer;
  col: Integer;
begin
  totalContinuas := 0;
  totalCategoricas := 0;

  for col := 0 to High(tiposColumnas) do
  begin
    case tiposColumnas[col] of
      tcContinua: Inc(totalContinuas);
      tcCategorica: Inc(totalCategoricas);
    end;
  end;
end;

procedure TForm1.LeerNombresColumnas(const LineaAtributos: string;
  const TotalColumnas: Integer; const Delimitador: Char);
var
  valoresAtributos: TStringList;
  col: Integer;
  nombreColumna: string;
begin
  SetLength(nombresColumnas, TotalColumnas);

  valoresAtributos := TStringList.Create;
  try
    valoresAtributos.StrictDelimiter := True;
    valoresAtributos.Delimiter := Delimitador;
    valoresAtributos.DelimitedText := LineaAtributos;

    for col := 0 to TotalColumnas - 1 do
    begin
      if col < valoresAtributos.Count then
        nombreColumna := Trim(valoresAtributos[col])
      else
        nombreColumna := '';

      if nombreColumna = '' then
        nombreColumna := Format('Col%d', [col + 1]);

      nombresColumnas[col] := nombreColumna;
    end;
  finally
    valoresAtributos.Free;
  end;
end;

procedure TForm1.AnalizarColumnasDatos;
var
  unicosPorColumna: array of TStringList;
  esNumerica: array of Boolean;
  tieneDecimales: array of Boolean;
  formatos: TFormatSettings;
  col: Integer;
  fila: Integer;
  umbralCategorico: Integer;
  valor: string;
  numero: Double;
begin
  if totalColumnasDatos <= 0 then
  begin
    SetLength(tiposColumnas, 0);
    SetLength(categoriasPorColumna, 0);
    indiceColumnaClase := -1;
    ActualizarResumenColumnas;
    Exit;
  end;

  SetLength(tiposColumnas, totalColumnasDatos);
  SetLength(categoriasPorColumna, totalColumnasDatos);
  indiceColumnaClase := totalColumnasDatos - 1;

  if totalFilasDatos <= 0 then
  begin
    for col := 0 to totalColumnasDatos - 1 do
    begin
      categoriasPorColumna[col] := 0;
      if col = indiceColumnaClase then
        tiposColumnas[col] := tcClase
      else
        tiposColumnas[col] := tcContinua;
    end;
    ActualizarResumenColumnas;
    Exit;
  end;

  SetLength(unicosPorColumna, totalColumnasDatos);
  SetLength(esNumerica, totalColumnasDatos);
  SetLength(tieneDecimales, totalColumnasDatos);

  for col := 0 to totalColumnasDatos - 1 do
  begin
    unicosPorColumna[col] := TStringList.Create;
    unicosPorColumna[col].Sorted := True;
    unicosPorColumna[col].Duplicates := dupIgnore;
    esNumerica[col] := True;
    tieneDecimales[col] := False;
  end;

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  try
    for fila := 0 to totalFilasDatos - 1 do
    begin
      for col := 0 to totalColumnasDatos - 1 do
      begin
        valor := Trim(matrizDatos[fila][col]);
        if valor = '' then
          Continue;

        unicosPorColumna[col].Add(valor);

        if (col <> indiceColumnaClase) and esNumerica[col] then
        begin
          if not TryStrToFloat(valor, numero, formatos) then
            esNumerica[col] := False
          else if Pos('.', valor) > 0 then
            tieneDecimales[col] := True;
        end;
      end;
    end;

    umbralCategorico := totalFilasDatos div 10;
    if umbralCategorico < 10 then
      umbralCategorico := 10;

    for col := 0 to totalColumnasDatos - 1 do
    begin
      categoriasPorColumna[col] := 0;

      if col = indiceColumnaClase then
        tiposColumnas[col] := tcClase
      else if not esNumerica[col] then
      begin
        tiposColumnas[col] := tcCategorica;
        categoriasPorColumna[col] := unicosPorColumna[col].Count;
      end
      else if tieneDecimales[col] then
        tiposColumnas[col] := tcContinua
      else if unicosPorColumna[col].Count <= umbralCategorico then
      begin
        tiposColumnas[col] := tcCategorica;
        categoriasPorColumna[col] := unicosPorColumna[col].Count;
      end
      else
        tiposColumnas[col] := tcContinua;
    end;
  finally
    for col := 0 to High(unicosPorColumna) do
      unicosPorColumna[col].Free;
  end;

  ActualizarResumenColumnas;
end;

procedure TForm1.OrdenarValores(var Valores: TArregloDouble);
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

procedure TForm1.CalcularEstadisticasNumericas(out Medias, Medianas,
  Desviaciones: TArregloDouble; out ColumnasCalculadas: TArregloBool);
var
  valores: TArregloDouble;
  col: Integer;
  fila: Integer;
  indice: Integer;
  totalValores: Integer;
  suma: Double;
  sumaVarianza: Double;
  media: Double;
  mediana: Double;
  varianza: Double;
  numero: Double;
  valorTexto: string;
  formatos: TFormatSettings;
begin
  SetLength(Medias, totalColumnasDatos);
  SetLength(Medianas, totalColumnasDatos);
  SetLength(Desviaciones, totalColumnasDatos);
  SetLength(ColumnasCalculadas, totalColumnasDatos);

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  for col := 0 to totalColumnasDatos - 1 do
  begin
    Medias[col] := 0;
    Medianas[col] := 0;
    Desviaciones[col] := 0;
    ColumnasCalculadas[col] := True;

    totalValores := 0;
    SetLength(valores, 0);

    for fila := 0 to totalFilasDatos - 1 do
    begin
      valorTexto := Trim(matrizDatos[fila][col]);
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

    suma := 0;
    for indice := 0 to High(valores) do
      suma := suma + valores[indice];
    media := suma / totalValores;

    OrdenarValores(valores);
    if (totalValores mod 2) = 1 then
      mediana := valores[totalValores div 2]
    else
      mediana := (valores[(totalValores div 2) - 1] + valores[totalValores div 2]) / 2;

    sumaVarianza := 0;
    for indice := 0 to High(valores) do
      sumaVarianza := sumaVarianza + (valores[indice] - media) *
        (valores[indice] - media);

    Medias[col] := media;
    Medianas[col] := mediana;
    varianza := sumaVarianza / totalValores;
    if varianza < 0 then
      varianza := 0;
    Desviaciones[col] := Sqrt(varianza);
  end;
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

//Metodo para determinar si el delimitador va a ser , o ;
function TForm1.DetectarDelimitador(const Linea: string): Char;
var
  i: Integer;
  conteoComa: Integer;
  conteoPuntoComa: Integer;
begin
  conteoComa := 0;
  conteoPuntoComa := 0;
  //Se recorre la cadena y se verifica cuantas , o ; para determinar
  //quien es el delimitador
  for i := 1 to Length(Linea) do
  begin
    case Linea[i] of
      ',': Inc(conteoComa);
      ';': Inc(conteoPuntoComa);
    end;
  end;
  //Se determina quien es
  if conteoPuntoComa > conteoComa then
    Result := ';'
  else
    Result := ',';
end;

procedure TForm1.GroupBox1Click(Sender: TObject);
begin

end;

procedure TForm1.Label1Click(Sender: TObject);
begin

end;

procedure TForm1.Label2Click(Sender: TObject);
begin

end;

procedure TForm1.Label3Click(Sender: TObject);
begin

end;

procedure TForm1.StaticText1Click(Sender: TObject);
begin

end;

procedure TForm1.CargarGridDatos(const NombreArchivo: string);
var
  lineasArchivo: TStringList; // Arreglo de String para almacenar las filas del CSV
  lineasDatos: TStringList; // Filas con informacion real (sin encabezado)
  valoresFila: TStringList; // Arreglo de cadenas para almacenar los elementos
  textoLinea: string;  //Variable para almacenar una fila de CSV
  i: Integer;
  j: Integer;
  filaDatos: Integer;
  filaGrid: Integer;
  maxColumnas: Integer;
  delimitador: Char;  //Caracter que vamos a usar para separar filas de CSV
  indice: Integer;
  tieneDatos: Boolean;
begin
  lineasArchivo := TStringList.Create;
  lineasDatos := TStringList.Create;
  valoresFila := TStringList.Create;
  try
    lineasArchivo.LoadFromFile(NombreArchivo);
    //Verificamos que no sea un archivo vacio
    if lineasArchivo.Count = 0 then
      Exit;

    delimitador := DetectarDelimitador(lineasArchivo[0]);

    valoresFila.StrictDelimiter := True;
    valoresFila.Delimiter := delimitador;

    maxColumnas := 0;
    //Se toma el encabezado para definir el minimo de columnas
    valoresFila.DelimitedText := lineasArchivo[0];
    if valoresFila.Count > maxColumnas then
      maxColumnas := valoresFila.Count;

    //Se filtran filas vacias y se calculan columnas reales
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

    totalColumnasDatos := maxColumnas;
    totalFilasDatos := lineasDatos.Count;

    SetLength(matrizDatos, totalFilasDatos);
    for filaDatos := 0 to totalFilasDatos - 1 do
      SetLength(matrizDatos[filaDatos], totalColumnasDatos);

    //Se cargan los datos en la matriz interna (sin encabezado)
    for i := 0 to lineasDatos.Count - 1 do
    begin
      filaDatos := i;
      valoresFila.DelimitedText := lineasDatos[i];

      for j := 0 to totalColumnasDatos - 1 do
      begin
        if (j < valoresFila.Count) and (valoresFila.Count > 0) then
          matrizDatos[filaDatos][j] := valoresFila[j]
        else
          matrizDatos[filaDatos][j] := '';
      end;
    end;

    //Primera fila = atributos (nombres), se ignora para el analisis
    LeerNombresColumnas(lineasArchivo[0], maxColumnas, delimitador);
    AnalizarColumnasDatos;

    gridDatos.BeginUpdate;
    try
      gridDatos.FixedCols := 0;
      gridDatos.FixedRows := 1;
      gridDatos.RowCount := totalFilasDatos + 1;
      gridDatos.ColCount := totalColumnasDatos;

      for j := 0 to maxColumnas - 1 do
        gridDatos.Cells[j, 0] := nombresColumnas[j];

      //Se agregan los valores al GRID ignorando la primera fila (atributos)
      for filaDatos := 0 to totalFilasDatos - 1 do
      begin
        filaGrid := filaDatos + 1;
        for j := 0 to totalColumnasDatos - 1 do
          gridDatos.Cells[j, filaGrid] := matrizDatos[filaDatos][j];
      end;
    finally
      gridDatos.EndUpdate;
    end;
  finally
    valoresFila.Free;
    lineasDatos.Free;
    lineasArchivo.Free;
  end;
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

procedure TForm1.Button1Click(Sender: TObject);
begin

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin

end;


end.


