unit Test.JSON;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics,
  DUnitX.TestFramework,
  Generics.Collections,
  Test.Model;

type
  [TestFixture]
  TTestJSON = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // JSONBr
    [Test]
    procedure JSONBrLoop50000;
    [Test]
    procedure JSONBrJsonToObject;
    [Test]
    procedure JSONBrObjectToJson;
    [Test]
    procedure JSONBrObjectListToJson;
    [Test]
    procedure JSONBrJsonToObjectList;
    // Nativo Delphi
    [Test]
    procedure RESTJsonLoop50000;
    [Test]
    procedure RESTJsonJsonToObject;
    [Test]
    procedure RESTJsonObjectToJson;
    [Test]
    procedure RESTJsonObjectListToJson;
    [Test]
    procedure RESTJsonJsonToObjectList;
    // x-superobject
    [Test]
    procedure XSuperObjectLoop50000;
    [Test]
    procedure XSuperObjectJsonToObject;
    [Test]
    procedure XSuperObjectObjectToJson;
    [Test]
    procedure XSuperObjectObjectListToJson;
    [Test]
    procedure XSuperObjectJsonToObjectList;
  end;

implementation

uses
  Test.Consts,
  jsonbr,
  jsonbr.builders,
  JSON,
  REST.Json,
  XSuperJSON,
  XSuperObject,
  JsonDataObjects;

const
  cMESSAGE = 'segundos %f => milisegundos %d';

procedure TTestJSON.Setup;
begin
  SetColorConsole(clGreen);
end;

procedure TTestJSON.TearDown;
begin

end;

procedure TTestJSON.XSuperObjectJsonToObject;
var
  LObject: TRootDTO;
  LInit, LEnd: Cardinal;
begin
  try
    LInit := GetTickCount;
    LObject := XSuperObject.TJSON.Parse<TRootDTO>(SAMPLE_JSON_1);
    LEnd := GetTickCount;
    //
    System.Writeln(Format('Gerando 1 objeto do json object(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LObject.Free;
  end;
end;

procedure TTestJSON.XSuperObjectJsonToObjectList;
var
  LInit, LEnd: Cardinal;
  LList: TObjectList<TRootDTO>;
begin
  LList := TObjectList<TRootDTO>.Create;
  try
    LInit := GetTickCount;
    LList := XSuperObject.TJSON.Parse<TObjectList<TRootDTO>>(FJsonArray);
    LEnd := GetTickCount;
    //
    System.Writeln(Format('Gerando uma list com 5000 objetos de um json array(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure TTestJSON.XSuperObjectLoop50000;
var
  LList: TObjectList<TRootDTO>;
  LObject: TRootDTO;
  LFor: Integer;
  LInit, LEnd: Cardinal;
begin
  System.Writeln(' ');
  LList := TObjectList<TRootDTO>.Create;
  try
    System.Writeln('X-SuperObject');
    LInit := GetTickCount;
    for LFor := 1 to SAMPLE_JSON_1_COUNT do
    begin
      LObject := XSuperObject.TJSON.Parse<TRootDTO>(SAMPLE_JSON_1);
      LList.Add(LObject);
    end;
    LEnd := GetTickCount;
    //
    System.Writeln(Format('..Loop gerando 50.000 objetos de um json object(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure TTestJSON.XSuperObjectObjectListToJson;
var
  LInit, LEnd: Cardinal;
  LJsonArray: String;
begin
  LInit := GetTickCount;
  LJsonArray := XSuperObject.TJSON.Stringify<TObjectList<TRootDTO>>(FObjectList5000);
  LEnd := GetTickCount;
  //
  System.Writeln(Format('Gerando json array de uma lista com 5000 objetos(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
end;

procedure TTestJSON.XSuperObjectObjectToJson;
var
  LJson: String;
  LInit, LEnd: Cardinal;
begin
  LInit := GetTickCount;
  LJson := XSuperObject.TJSON.Stringify<TRootDTO>(FObject);
  LEnd := GetTickCount;
  //
  System.Writeln(Format('Gerando 1 json object de um objeto(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
end;

procedure TTestJSON.JSONBrJsonToObject;
var
  LObject: TRootDTO;
  LInit, LEnd: Cardinal;
begin
  try
    LInit := GetTickCount;
    LObject := TJSONBr.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
    LEnd := GetTickCount;
    //
    System.Writeln(Format('Gerando 1 objeto do json object(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LObject.Free;
  end;
end;

procedure TTestJSON.JSONBrJsonToObjectList;
var
  LList: TObjectList<TRootDTO>;
  LInit, LEnd: Cardinal;
begin
  try
    LInit := GetTickCount;
    LList := TJSONBr.JsonToObjectList<TRootDTO>(FJsonBrArray);
    LEnd := GetTickCount;
    //
    System.Writeln(Format('Gerando uma list com 5000 objetos de um json array(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure TTestJSON.JSONBrObjectListToJson;
var
  LInit, LEnd: Cardinal;
  LJsonArray: String;
begin
  LInit := GetTickCount;
  LJsonArray := TJSONBr.ObjectListToJsonString<TRootDTO>(FObjectList5000);
  LEnd := GetTickCount;
  //
  System.Writeln(Format('Gerando json array de uma lista com 5000 objetos(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
end;

procedure TTestJSON.JSONBrObjectToJson;
var
  LJson: String;
  LInit, LEnd: Cardinal;
begin
  LInit := GetTickCount;
  LJson := TJSONBr.ObjectToJsonString(FObject);
  LEnd := GetTickCount;
  //
  System.Writeln(Format('Gerando 1 json object de um objeto(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
end;

procedure TTestJSON.JSONBrLoop50000;
var
  LList: TObjectList<TRootDTO>;
  LObject: TRootDTO;
  LFor: Integer;
  LInit, LEnd: Cardinal;
begin
  System.Writeln(' ');
  LList := TObjectList<TRootDTO>.Create;
  try
    System.Writeln('.JSONBr Framework');
    LInit := GetTickCount;
    for LFor := 1 to SAMPLE_JSON_1_COUNT do
    begin
      LObject := TJSONBr.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
      LList.Add(LObject);
    end;
    LEnd := GetTickCount;
    //
    System.Writeln(Format('..Loop gerando 50.000 objetos de um json object(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure TTestJSON.RESTJsonJsonToObject;
var
  LObject: TRootDTO;
  LInit, LEnd: Cardinal;
begin
  try
    LInit := GetTickCount;
    LObject := REST.Json.TJson.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
    LEnd := GetTickCount;
    //
    System.Writeln(Format('Gerando 1 objeto do json object(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LObject.Free;
  end;
end;

procedure TTestJSON.RESTJsonJsonToObjectList;
var
  LInit, LEnd: Cardinal;
  LList: TObjectList<TRootDTO>;
begin
  LList := TObjectList<TRootDTO>.Create;
  try
    LInit := GetTickCount;
    LList := REST.Json.TJson.JsonToObject<TObjectList<TRootDTO>>(FJsonArray);
    LEnd := GetTickCount;
    //
    System.Writeln(Format('Gerando uma list com 5000 objetos de um json array(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure TTestJSON.RESTJsonObjectListToJson;
var
  LInit, LEnd: Cardinal;
  LJsonArray: String;
begin
  LInit := GetTickCount;
  LJsonArray := REST.Json.TJson.ObjectToJsonString(FObjectList5000);
  LEnd := GetTickCount;
  //
  System.Writeln(Format('Gerando json array de uma lista com 5000 objetos(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
end;

procedure TTestJSON.RESTJsonObjectToJson;
var
  LJson: String;
  LInit, LEnd: Cardinal;
begin
  LInit := GetTickCount;
  LJson := REST.Json.TJson.ObjectToJsonString(FObject);
  LEnd := GetTickCount;
  //
  System.Writeln(Format('Gerando 1 json object de um objeto(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
end;

procedure TTestJSON.RESTJsonLoop50000;
var
  LList: TObjectList<TRootDTO>;
  LObject: TRootDTO;
  LFor: Integer;
  LInit, LEnd: Cardinal;
begin
  System.Writeln(' ');
  LList := TObjectList<TRootDTO>.Create;
  try
    System.Writeln('REST.Json Delphi');
    LInit := GetTickCount;
    for LFor := 1 to SAMPLE_JSON_1_COUNT do
    begin
      LObject := REST.Json.TJson.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
      LList.Add(LObject);
    end;
    LEnd := GetTickCount;
    //
    System.Writeln(Format('..Loop gerando 50.000 objetos de um json object(' + cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LList.Clear;
    LList.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestJSON);

end.
