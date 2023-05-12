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
  SysUtils,
  Generics.Collections,
  jsonbr.utils,
  jsonbr.writer,
  jsonbr.builders;

type
  TJSONBr = class
  private
    class var FJSONObject: TJSONBrObject;
    class var FJSONWriter: TJSONWriter;
    class procedure SetNotifyEventGetValue(const Value: TNotifyEventGetValue); static;
    class procedure SetNotifyEventSetValue(const Value: TNotifyEventSetValue); static;
    class function GetFormatSettings: TFormatSettings; static;
    class procedure SetFormatSettings(const Value: TFormatSettings); static;
  public
    class constructor Create;
    class destructor Destroy;
    class function ObjectToJsonString(AObject: TObject;
      AStoreClassName: Boolean = False): string;
    class function ObjectListToJsonString(AObjectList: TObjectList<TObject>;
      AStoreClassName: Boolean = False): string; overload;
    class function ObjectListToJsonString<T: class, constructor>(AObjectList: TObjectList<T>;
      AStoreClassName: Boolean = False): string; overload;
    class function JsonToObject<T: class, constructor>(const AJson: string): T; overload;
    class function JsonToObject<T: class>(AObject: T;
      const AJson: string): Boolean; overload;
    class function JsonToObjectList<T: class, constructor>(const AJson: string): TObjectList<T>;
    class procedure JsonToObject(const AJson: string; AObject: TObject); overload;
    //
    class function BeginObject(const AValue: String = ''): TJSONWriter;
    class function BeginArray: TJSONWriter;
    // Events GetValue and SetValue
    class property OnSetValue: TNotifyEventSetValue write SetNotifyEventSetValue;
    class property OnGetValue: TNotifyEventGetValue write SetNotifyEventGetValue;
    class property FormatSettings: TFormatSettings read GetFormatSettings write SetFormatSettings;
  end;

implementation

{ TJSONBr }

class function TJSONBr.BeginArray: TJSONWriter;
begin
  Result := FJSONWriter.BeginArray;
end;

class function TJSONBr.BeginObject(const AValue: String = ''): TJSONWriter;
begin
  Result := FJSONWriter.BeginObject(AValue);
end;

class constructor TJSONBr.Create;
begin
  FJSONWriter := TJSONWriter.Create;
  FJSONObject := TJSONBrObject.Create;
end;

class destructor TJSONBr.Destroy;
begin
  FJSONObject.Free;
  FJSONWriter.Free;
  inherited;
end;

class function TJSONBr.GetFormatSettings: TFormatSettings;
begin
  Result := JsonBrFormatSettings;
end;

class procedure TJSONBr.SetFormatSettings(const Value: TFormatSettings);
begin
  JsonBrFormatSettings := Value;
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

class function TJSONBr.JsonToObject<T>(const AJson: string): T;
begin
  Result := FJSONObject.JSONToObject<T>(AJson);
end;

class function TJSONBr.ObjectListToJsonString(AObjectList: TObjectList<TObject>;
  AStoreClassName: Boolean): string;
var
  LFor: Integer;
  LResultBuilder: TStringBuilder;
begin
  LResultBuilder := TStringBuilder.Create;
  try
    LResultBuilder.Append('[');
    for LFor := 0 to AObjectList.Count -1 do
    begin
      LResultBuilder.Append(ObjectToJsonString(AObjectList.Items[LFor], AStoreClassName));
      if LFor < AObjectList.Count -1 then
       LResultBuilder.Append(', ');
    end;
    LResultBuilder.ReplaceLastChar(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

class function TJSONBr.ObjectListToJsonString<T>(AObjectList: TObjectList<T>;
  AStoreClassName: Boolean): string;
var
  LFor: Integer;
  LResultBuilder: TStringBuilder;
begin
  LResultBuilder := TStringBuilder.Create;
  try
    LResultBuilder.Append('[');
    for LFor := 0 to AObjectList.Count -1 do
    begin
      LResultBuilder.Append(ObjectToJsonString(T(AObjectList.Items[LFor]), AStoreClassName));
      if LFor < AObjectList.Count -1 then
        LResultBuilder.Append(', ');
    end;
    LResultBuilder.ReplaceLastChar(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
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

class function TJSONBr.JsonToObjectList<T>(const AJson: string): TObjectList<T>;
begin
  Result := FJSONObject.JSONToObjectList<T>(AJson);
end;

end.
