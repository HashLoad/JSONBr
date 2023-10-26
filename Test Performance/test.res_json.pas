unit test.res_json;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics,
  Generics.Collections,
  Test.Model,
  Test.Consts,
  JSON,
  REST.Json;

procedure _RESTJsonLoop50000;
procedure _RESTJsonJsonToObject;
procedure _RESTJsonObjectToJson;
procedure _RESTJsonObjectListToJson;
procedure _RESTJsonJsonToObjectList;

implementation

procedure _RESTJsonLoop50000;
var
  LList: TObjectList<TRootDTO>;
  LObject: TRootDTO;
  LFor: Integer;
begin
  LList := TObjectList<TRootDTO>.Create;
  try
    for LFor := 1 to SAMPLE_JSON_1_COUNT do
    begin
      LObject := REST.Json.TJson.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
      LList.Add(LObject);
    end;
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure _RESTJsonJsonToObject;
var
  LObject: TRootDTO;
begin
  try
    LObject := REST.Json.TJson.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
  finally
    LObject.Free;
  end;
end;

procedure _RESTJsonObjectToJson;
var
  LJson: String;
begin
  LJson := REST.Json.TJson.ObjectToJsonString(FObject);
end;

procedure _RESTJsonObjectListToJson;
var
  LJsonArray: String;
begin
  LJsonArray := REST.Json.TJson.ObjectToJsonString(FObjectList5000);
end;

procedure _RESTJsonJsonToObjectList;
var
  LList: TObjectList<TRootDTO>;
begin
  LList := TObjectList<TRootDTO>.Create;
  try
    LList := REST.Json.TJson.JsonToObject<TObjectList<TRootDTO>>(FJsonArray);
  finally
    LList.Clear;
    LList.Free;
  end;
end;

end.
