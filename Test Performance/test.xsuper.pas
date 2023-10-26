unit test.xsuper;

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics,
  Generics.Collections,
  Test.Model,
  Test.Consts,
  XSuperJSON,
  XSuperObject;

procedure _XSuperObjectLoop50000;
procedure _XSuperObjectJsonToObject;
procedure _XSuperObjectObjectToJson;
procedure _XSuperObjectObjectListToJson;
procedure _XSuperObjectJsonToObjectList;

implementation

procedure _XSuperObjectLoop50000;
var
  LList: TObjectList<TRootDTO>;
  LObject: TRootDTO;
  LFor: Integer;
begin
  LList := TObjectList<TRootDTO>.Create;
  try
    for LFor := 1 to SAMPLE_JSON_1_COUNT do
    begin
      LObject := XSuperObject.TJSON.Parse<TRootDTO>(SAMPLE_JSON_1);
      LList.Add(LObject);
    end;
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure _XSuperObjectJsonToObject;
var
  LObject: TRootDTO;
begin
  try
    LObject := XSuperObject.TJSON.Parse<TRootDTO>(SAMPLE_JSON_1);
  finally
    LObject.Free;
  end;
end;

procedure _XSuperObjectJsonToObjectList;
var
  LList: TObjectList<TRootDTO>;
begin
  LList := TObjectList<TRootDTO>.Create;
  try
    LList := XSuperObject.TJSON.Parse<TObjectList<TRootDTO>>(FJsonArray);
  finally
    LList.Clear;
    LList.Free;
  end;
end;

procedure _XSuperObjectObjectListToJson;
var
  LJsonArray: String;
begin
  LJsonArray := XSuperObject.TJSON.Stringify<TObjectList<TRootDTO>>(FObjectList5000);
end;

procedure _XSuperObjectObjectToJson;
var
  LJson: String;
begin
  LJson := XSuperObject.TJSON.Stringify<TRootDTO>(FObject);
end;

end.


