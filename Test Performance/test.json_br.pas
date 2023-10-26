unit test.json_br;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics,
  Generics.Collections,
  Test.Model,
  Test.Consts,
  jsonbr,
  jsonbr.builders;

procedure _JSONBrLoop50000;
procedure _JSONBrJsonToObject;
procedure _JSONBrObjectToJson;
procedure _JSONBrObjectListToJson;
procedure _JSONBrJsonToObjectList;

implementation

procedure _JSONBrLoop50000;
var
  LList: TObjectList<TRootDTO>;
  LObject: TRootDTO;
  LFor: Integer;
begin
  LList := TObjectList<TRootDTO>.Create;
  try
    for LFor := 1 to SAMPLE_JSON_1_COUNT do
    begin
      LObject := TJSONBr.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
      LList.Add(LObject);
    end;
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure _JSONBrJsonToObject;
var
  LObject: TRootDTO;
begin
  try
    LObject := TJSONBr.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
  finally
    LObject.Free;
  end;
end;

procedure _JSONBrObjectToJson;
var
  LJson: String;
begin
  LJson := TJSONBr.ObjectToJsonString(FObject);
end;

procedure _JSONBrObjectListToJson;
var
  LJsonArray: String;
begin
  LJsonArray := TJSONBr.ObjectListToJsonString<TRootDTO>(FObjectList5000);
end;

procedure _JSONBrJsonToObjectList;
var
  LList: TObjectList<TRootDTO>;
begin
  try
    LList := TJSONBr.JsonToObjectList<TRootDTO>(FJsonBrArray);
  finally
    LList.Clear;
    LList.Free;
  end;
end;

end.
