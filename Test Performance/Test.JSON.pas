unit Test.JSON;

interface

uses
  System.Diagnostics,
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
  DUnitX.utils,
  XSuperJSON,
  XSuperObject,
  test.res_json,
  test.json_br,
  test.xsuper;

procedure TTestJSON.Setup;
begin

end;

procedure TTestJSON.TearDown;
begin

end;

procedure TTestJSON.XSuperObjectJsonToObject;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _XSuperObjectJsonToObject;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando 1 objeto do json object(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.XSuperObjectJsonToObjectList;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _XSuperObjectJsonToObjectList;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando uma list com 5000 objetos de um json array(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.XSuperObjectLoop50000;
var
  Stopwatch: TStopwatch;
begin
  SetColorConsole(clPurple);
  System.Writeln(' ');
  System.Writeln('.XSuperJSON');

  Stopwatch := TStopwatch.StartNew;
  _XSuperObjectLoop50000;
  Stopwatch.Stop;

  System.Writeln(Format('..Loop gerando 50.000 objetos de um json object(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.XSuperObjectObjectListToJson;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _XSuperObjectObjectListToJson;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando json array de uma lista com 5000 objetos(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.XSuperObjectObjectToJson;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _XSuperObjectObjectToJson;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando 1 json object de um objeto(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.JSONBrJsonToObject;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _JSONBrJsonToObject;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando 1 objeto do json object(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.JSONBrJsonToObjectList;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _JSONBrJsonToObjectList;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando uma list com 5000 objetos de um json array(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.JSONBrLoop50000;
var
  Stopwatch: TStopwatch;
begin
  SetColorConsole(clGreen);
  System.Writeln(' ');
  System.Writeln('.JSONBr Framework');

  Stopwatch := TStopwatch.StartNew;
  _JSONBrLoop50000;
  Stopwatch.Stop;

  System.Writeln(Format('..Loop gerando 50.000 objetos de um json object(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.JSONBrObjectListToJson;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _JSONBrObjectListToJson;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando json array de uma lista com 5000 objetos(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.JSONBrObjectToJson;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _JSONBrObjectToJson;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando 1 json object de um objeto(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.RESTJsonJsonToObject;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _RESTJsonJsonToObject;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando 1 objeto do json object(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.RESTJsonJsonToObjectList;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _RESTJsonJsonToObjectList;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando uma list com 5000 objetos de um json array(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.RESTJsonLoop50000;
var
  Stopwatch: TStopwatch;
begin
  SetColorConsole(clRed);
  System.Writeln(' ');
  System.Writeln('.REST.Json Delphi');

  Stopwatch := TStopwatch.StartNew;
  _RESTJsonLoop50000;
  Stopwatch.Stop;

  System.Writeln(Format('..Loop gerando 50.000 objetos de um json object(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.RESTJsonObjectListToJson;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _RESTJsonObjectListToJson;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando json array de uma lista com 5000 objetos(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

procedure TTestJSON.RESTJsonObjectToJson;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  _RESTJsonObjectToJson;
  Stopwatch.Stop;

  System.Writeln(Format('Gerando 1 json object de um objeto(' + cMESSAGE, [Stopwatch.ElapsedMilliseconds / 100, Stopwatch.ElapsedMilliseconds]) + ')');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestJSON);

end.
