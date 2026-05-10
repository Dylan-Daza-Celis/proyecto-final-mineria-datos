unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Menus, Grids,
  Buttons;

type

  { TForm1 }

  TTipoColumna = (tcContinua, tcCategorica, tcClase);

  TForm1 = class(TForm)
    btnCargarArchivos: TButton;
    Button1: TButton;
    gridDatos: TStringGrid;
    dialogoAbrirArchivo: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure btnCargarArchivosClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CargarGridDatos(const NombreArchivo: string);
    function DetectarDelimitador(const Linea: string): Char;
    procedure StaticText1Click(Sender: TObject);
  private
    tiposColumnas: array of TTipoColumna;
    categoriasPorColumna: array of Integer;
    nombresColumnas: array of string;
    indiceColumnaClase: Integer;
    procedure LeerNombresColumnas(const LineaAtributos: string;
      const TotalColumnas: Integer; const Delimitador: Char);
    procedure AnalizarColumnasDatos(const LineasArchivo: TStrings;
      const TotalColumnas: Integer; const Delimitador: Char);
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

  if Length(tiposColumnas) = 0 then
    Label1.Caption := 'Sin columnas'
  else
    begin
    Label1.Caption := Format('Continuas: %d',[totalContinuas]);
    Label2.Caption := Format('Categoricas: %d',
                   [totalCategoricas]);
    Label3.Caption := Format('Clase: %d',
      [indiceColumnaClase + 1]);

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

procedure TForm1.AnalizarColumnasDatos(const LineasArchivo: TStrings;
  const TotalColumnas: Integer; const Delimitador: Char);
var
  valoresFila: TStringList;
  unicosPorColumna: array of TStringList;
  esNumerica: array of Boolean;
  tieneDecimales: array of Boolean;
  formatos: TFormatSettings;
  col: Integer;
  fila: Integer;
  totalFilas: Integer;
  umbralCategorico: Integer;
  valor: string;
  numero: Double;
begin
  if TotalColumnas <= 0 then
  begin
    SetLength(tiposColumnas, 0);
    SetLength(categoriasPorColumna, 0);
    indiceColumnaClase := -1;
    ActualizarResumenColumnas;
    Exit;
  end;

  SetLength(tiposColumnas, TotalColumnas);
  SetLength(categoriasPorColumna, TotalColumnas);
  indiceColumnaClase := TotalColumnas - 1;

  if LineasArchivo.Count <= 1 then
  begin
    for col := 0 to TotalColumnas - 1 do
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

  SetLength(unicosPorColumna, TotalColumnas);
  SetLength(esNumerica, TotalColumnas);
  SetLength(tieneDecimales, TotalColumnas);

  for col := 0 to TotalColumnas - 1 do
  begin
    unicosPorColumna[col] := TStringList.Create;
    unicosPorColumna[col].Sorted := True;
    unicosPorColumna[col].Duplicates := dupIgnore;
    esNumerica[col] := True;
    tieneDecimales[col] := False;
  end;

  formatos := DefaultFormatSettings;
  formatos.DecimalSeparator := '.';

  valoresFila := TStringList.Create;
  try
    valoresFila.StrictDelimiter := True;
    valoresFila.Delimiter := Delimitador;

    for fila := 1 to LineasArchivo.Count - 1 do
    begin
      valoresFila.DelimitedText := LineasArchivo[fila];

      for col := 0 to TotalColumnas - 1 do
      begin
        if col >= valoresFila.Count then
          Continue;

        valor := Trim(valoresFila[col]);
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

    totalFilas := LineasArchivo.Count - 1;
    if totalFilas < 1 then
      totalFilas := 1;

    umbralCategorico := totalFilas div 10;
    if umbralCategorico < 10 then
      umbralCategorico := 10;

    for col := 0 to TotalColumnas - 1 do
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
    valoresFila.Free;
    for col := 0 to High(unicosPorColumna) do
      unicosPorColumna[col].Free;
  end;

  ActualizarResumenColumnas;
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

procedure TForm1.StaticText1Click(Sender: TObject);
begin

end;

procedure TForm1.CargarGridDatos(const NombreArchivo: string);
var
  lineasArchivo: TStringList; // Arreglo de String para almacenar las filas del CSV
  valoresFila: TStringList; // Arreglo de cadenas para almacenar los elementos
  textoLinea: string;  //Variable para almacenar una fila de CSV
  i: Integer;
  j: Integer;
  filaGrid: Integer;
  maxColumnas: Integer;
  totalFilasDatos: Integer;
  delimitador: Char;  //Caracter que vamos a usar para separar filas de CSV
begin
  lineasArchivo := TStringList.Create;
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
    //Se recorre cada elemnto del arreglo de filas del CSV
    //Y se determinan las columnas dependiendo de los elementos al separar la fila del CSV
    for i := 0 to lineasArchivo.Count - 1 do
    begin
      textoLinea := lineasArchivo[i];
      valoresFila.DelimitedText := textoLinea;

      if valoresFila.Count > maxColumnas then
        maxColumnas := valoresFila.Count;
    end;

    if maxColumnas = 0 then
      maxColumnas := 1;

    //Primera fila = atributos (nombres), se ignora para el analisis
    LeerNombresColumnas(lineasArchivo[0], maxColumnas, delimitador);
    AnalizarColumnasDatos(lineasArchivo, maxColumnas, delimitador);

    totalFilasDatos := lineasArchivo.Count - 1;
    if totalFilasDatos < 0 then
      totalFilasDatos := 0;

    gridDatos.BeginUpdate;
    try
      gridDatos.FixedCols := 0;
      gridDatos.FixedRows := 1;
      gridDatos.RowCount := totalFilasDatos + 1;
      gridDatos.ColCount := maxColumnas;

      for j := 0 to maxColumnas - 1 do
        gridDatos.Cells[j, 0] := nombresColumnas[j];

      //Se agregan los valores al GRID ignorando la primera fila (atributos)
      if totalFilasDatos > 0 then
      begin
        for i := 1 to lineasArchivo.Count - 1 do
        begin
          filaGrid := i;
          valoresFila.DelimitedText := lineasArchivo[i];

          for j := 0 to maxColumnas - 1 do
          begin
            if (j < valoresFila.Count) and (valoresFila.Count > 0) then
              gridDatos.Cells[j, filaGrid] := valoresFila[j]
            else
              gridDatos.Cells[j, filaGrid] := '';
          end;
        end;
      end;
    finally
      gridDatos.EndUpdate;
    end;
  finally
    valoresFila.Free;
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

procedure TForm1.Button1Click(Sender: TObject);
begin

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin

end;


end.

