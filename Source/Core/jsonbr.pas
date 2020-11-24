{
                   Copyright (c) 2020, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Versão 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos é permitido copiar e distribuir cópias deste documento de
       licença, mas mudá-lo não é permitido.

       Esta versão da GNU Lesser General Public License incorpora
       os termos e condições da versão 3 da GNU General Public License
       Licença, complementado pelas permissões adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(JSONBr Framework.)
  @created(23 Nov 2020)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Telegram : @IsaquePinheiro)
}

unit jsonbr;

interface

uses
  Generics.Collections,
  jsonbr.builders;

type
  TJSONBrObject = jsonbr.builders.TJSONBrObject;

  TJSONBr = class
  private
    class var
    FJSONObject: TJSONBrObject;
    class procedure SetNotifyEventGetValue(const Value: TNotifyEventGetValue); static;
    class procedure SetNotifyEventSetValue(const Value: TNotifyEventSetValue); static;
  public
    class constructor Create;
    class destructor Destroy;
    class function ObjectToJsonString(AObject: TObject;
      AStoreClassName: Boolean = False): string;
    class function ObjectListToJsonString(AObjectList: TObjectList<TObject>;
      AStoreClassName: Boolean = False): string; overload;
    class function ObjectListToJsonString<T: class, constructor>(AObjectList: TObjectList<T>;
      AStoreClassName: Boolean = False): string; overload;
    class function JsonToObject<T: class, constructor>(const AJson: string{;
      AOptions: TJSONBrOptions = [joDateIsUTC, joDateFormatISO8601]}): T; overload;
    class function JsonToObject<T: class>(AObject: T;
      const AJson: string): Boolean; overload;
    class function JsonToObjectList<T: class, constructor>(const AJson: string): TObjectList<T>;
    class procedure JsonToObject(const AJson: string; AObject: TObject); overload;
    // Create functional
    class function BeginObject: TJSONBrObject;
    class function BeginArray: TJSONBrObject;
    class function EndObject: TJSONBrObject;
    class function EndArray: TJSONBrObject;
    class function AddPair(const APair: String; const AValue: String): TJSONBrObject; overload;
    class function AddPair(const APair: String; const AValue: Integer): TJSONBrObject; overload;
    class function AddPair(const APair: String; const AValue: TJSONBrObject): TJSONBrObject; overload;
    class function ToJSON: String;
    // Events GetValue and SetValue
    class property OnSetValue: TNotifyEventSetValue write SetNotifyEventSetValue;
    class property OnGetValue: TNotifyEventGetValue write SetNotifyEventGetValue;
  end;

implementation

{ TJSONBr }

class function TJSONBr.AddPair(const APair, AValue: String): TJSONBrObject;
begin
  Result := FJSONObject.AddPair(APair, AValue);
end;

class function TJSONBr.AddPair(const APair: String; const AValue: Integer): TJSONBrObject;
begin
  Result := FJSONObject.AddPair(APair, AValue);
end;

class function TJSONBr.AddPair(const APair: String; const AValue: TJSONBrObject): TJSONBrObject;
begin
  Result := FJSONObject.AddPair(APair, AValue);
end;

class function TJSONBr.BeginArray: TJSONBrObject;
begin
  Result := FJSONObject.BeginArray;
end;

class function TJSONBr.BeginObject: TJSONBrObject;
begin
  Result := FJSONObject.BeginObject;
end;

class constructor TJSONBr.Create;
begin
  FJSONObject := TJSONBrObject.Create;
end;

class destructor TJSONBr.Destroy;
begin
  FJSONObject.Free;
  inherited;
end;

class function TJSONBr.EndArray: TJSONBrObject;
begin
  Result := FJSONObject.EndArray;
end;

class function TJSONBr.EndObject: TJSONBrObject;
begin
  Result := FJSONObject.EndObject;
end;

class procedure TJSONBr.SetNotifyEventGetValue(const Value: TNotifyEventGetValue);
begin
  FJSONObject.OnGetValue := Value;
end;

class procedure TJSONBr.JsonToObject(const AJson: string; AObject: TObject);
begin
  FJSONObject.JSONToObject(AObject, AJson);
end;

class function TJSONBr.JsonToObject<T>(AObject: T;
  const AJson: string): Boolean;
begin
  Result := FJSONObject.JSONToObject(TObject(AObject), AJson);
end;

class function TJSONBr.JsonToObject<T>(const AJson: string{;
  AOptions: TJSONBrOptions}): T;
begin
  Result := FJSONObject.JSONToObject<T>(AJson);
end;

class function TJSONBr.ObjectListToJsonString(AObjectList: TObjectList<TObject>;
  AStoreClassName: Boolean): string;
var
  LFor: Integer;
begin
  Result := '[';
  for LFor := 0 to AObjectList.Count -1 do
  begin
    Result := Result + ObjectToJsonString(AObjectList.Items[LFor], AStoreClassName);
    if LFor < AObjectList.Count -1 then
      Result := Result + ', ';
  end;
  Result := Result + ']';
end;

class function TJSONBr.ObjectListToJsonString<T>(AObjectList: TObjectList<T>;
  AStoreClassName: Boolean): string;
var
  LFor: Integer;
begin
  Result := '[';
  for LFor := 0 to AObjectList.Count -1 do
  begin
    Result := Result + ObjectToJsonString(T(AObjectList.Items[LFor]), AStoreClassName);
    if LFor < AObjectList.Count -1 then
      Result := Result + ', ';
  end;
  Result := Result + ']';
end;

class function TJSONBr.ObjectToJsonString(AObject: TObject;
  AStoreClassName: Boolean): string;
begin
  Result := FJSONObject.ObjectToJSON(AObject, AStoreClassName);
end;

class procedure TJSONBr.SetNotifyEventSetValue(const Value: TNotifyEventSetValue);
begin
  FJSONObject.OnSetValue := Value;
end;

class function TJSONBr.ToJSON: String;
begin
  Result := FJSONObject.ToJSON;
end;

class function TJSONBr.JsonToObjectList<T>(const AJson: string): TObjectList<T>;
begin
  Result := FJSONObject.JSONToObjectList<T>(AJson);
end;

end.
