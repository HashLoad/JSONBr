unit Test.Consts;

interface

uses
  Vcl.Graphics,
  Winapi.Windows,
  Generics.Collections,
  Test.Model,
  jsonbr,
  JSON,
  REST.Json;
//  XSuperJSON,
//  XSuperObject;

procedure SetColorConsole(AColor: TColor);
procedure GeraObjectList;
procedure GeraObject;
procedure GeraJsonArray;

const
  cMESSAGE = 'segundos %f => milisegundos %d';
  SAMPLE_JSON_1_COUNT = 50000;
  SAMPLE_JSON_1 = // from http://json.org/example.html
    '{' + #13#10 +
    '"glossary": {' + #13#10 +
        '"title": "example glossary",' + #13#10 +
        '		"GlossDiv": {' + #13#10 +
            '"title": "S",' + #13#10 +
            '			"GlossList": {' + #13#10 +
                '"GlossEntry": {' + #13#10 +
                    '"ID": "SGML",' + #13#10 +
                    '					"SortAs": "SGML",' + #13#10 +
                    '					"GlossTerm": "Standard Generalized Markup Language",' + #13#10 +
                    '					"Acronym": "SGML",' + #13#10 +
                    '					"Abbrev": "ISO 8879:1986",' + #13#10 +
                    '					"GlossDef": {' + #13#10 +
                        '"para": "A meta-markup language, used to create markup languages such as DocBook.",' + #13#10 +
                        '						"GlossSeeAlso": ["1.93", "2.85"]' + #13#10 +
//                        '						"GlossSeeAlso": ["GML", "XML"]' + #13#10 +
                    '},' + #13#10 +
                    '					"GlossSee": "markup"' + #13#10 +
                '}' + #13#10 +
            '}' + #13#10 +
        '}' + #13#10 +
    '}' + #13#10 +
    '}';

//  SAMPLE_JSON_2 = '{"GlossDef":{"para":"A meta-markup language, used to create markup languages such as DocBook.", "GlossSeeAlso":["GML","XML"]}}';

var
  FObjectList: TObjectList<TRootDTO>;
  FObjectList5000: TObjectList<TRootDTO>;
  FObject: TRootDTO;
  FJsonArray: WideString;
  FJsonBrArray: WideString;

implementation

procedure SetColorConsole(AColor: TColor);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE);
  case AColor of
    clWhite:  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE);
    clRed:    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_INTENSITY);
    clGreen:  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_INTENSITY);
    clBlue:   SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    clMaroon: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY);
    clPurple: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
    clAqua: SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY);
  end;
end;

procedure GeraObjectList;
var
  LObject: TRootDTO;
  LObject5000: TRootDTO;
  LFor: Integer;
begin
  FObjectList := TObjectList<TRootDTO>.Create;
  for LFor := 1 to SAMPLE_JSON_1_COUNT do
  begin
    LObject := REST.Json.TJson.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
    FObjectList.Add(LObject);
  end;

  FObjectList5000 := TObjectList<TRootDTO>.Create;
  for LFor := 1 to 5000 do
  begin
    LObject5000 := REST.Json.TJson.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
    FObjectList5000.Add(LObject5000);
  end;
end;

procedure GeraObject;
begin
  FObject := REST.Json.TJson.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
end;

procedure GeraJsonArray;
begin
  FJsonArray := REST.Json.TJson.ObjectToJsonString(FObjectList5000);
  FJsonBrArray := TJSONBr.ObjectToJsonString(FObjectList5000);
end;

initialization
  SetColorConsole(clAqua);
  System.Writeln('Aguarde!!! Inicializando variáveis de ambiente para processamento!');
  System.Writeln(' ');
  GeraObjectList;
  GeraObject;
  GeraJsonArray;

end.
