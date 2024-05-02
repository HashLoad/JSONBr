{
                   Copyright (c) 2020, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
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
  Rtti,
  SysUtils,
  StrUtils,
  Classes,
  Variants,
  Generics.Collections,
  jsonbr.types,
  jsonbr.writer,
  jsonbr.reader,
  jsonbr.builders;

type
  TJsonBr = class
  private
    class var FJsonBuilder: TJsonBuilder;
    class var FJsonWriter: TJsonWriter;
    class var FJsonReader: TJsonReader;
    class procedure SetNotifyEventGetValue(const Value: TNotifyEventGetValue); static; inline;
    class procedure SetNotifyEventSetValue(const Value: TNotifyEventSetValue); static; inline;
    class function GetFormatSettings: TFormatSettings; static; inline;
    class procedure SetFormatSettings(const Value: TFormatSettings); static; inline;
  public
    class constructor Create;
    class destructor Destroy;
    class function ObjectToJsonString(AObject: TObject;
      AStoreClassName: Boolean = False): String; inline;
    class function ObjectListToJsonString(AObjectList: TObjectList<TObject>;
      AStoreClassName: Boolean = False): String; overload; inline;
    class function ObjectListToJsonString<T: class, constructor>(AObjectList: TObjectList<T>;
      AStoreClassName: Boolean = False): String; overload; inline;
    class function JsonToObject<T: class, constructor>(const AJson: String): T; overload; inline;
    class function JsonToObject<T: class>(const AObject: T;
      const AJson: String): Boolean; overload; inline;
    class function JsonToObjectList<T: class, constructor>(const AJson: String): TObjectList<T>; overload; inline;
    class function JsonToObjectList(const AJson: String; const AType: TClass): TObjectList<TObject>; overload; inline;
    class procedure JsonToObject(const AJson: String; AObject: TObject); overload; inline;
    // Write
    class function BeginObject(const AValue: String = ''): TJsonWriter; inline;
    class function BeginArray: TJsonWriter; inline;
    // Reader
    class procedure ParseFromFile(const AFileName: String; const AUtf8: Boolean = True); inline;
    class procedure SaveJsonToFile(const AFileName: String; const AUtf8: Boolean = True); inline;
    class function Write: TJsonWriter; inline;
    class function Reader: TJsonReader; inline;
    class function Data: TJsonData;
    // Events GetValue and SetValue
    class property OnSetValue: TNotifyEventSetValue write SetNotifyEventSetValue;
    class property OnGetValue: TNotifyEventGetValue write SetNotifyEventGetValue;
    class property FormatSettings: TFormatSettings read GetFormatSettings write SetFormatSettings;
  end;

implementation

{ TJSONBr }

class function TJsonBr.BeginArray: TJsonWriter;
begin
  Result := FJsonWriter.BeginArray;
end;

class function TJsonBr.BeginObject(const AValue: String = ''): TJsonWriter;
begin
  Result := FJsonWriter.BeginObject(AValue);
end;

class constructor TJsonBr.Create;
begin
  FJsonBuilder := TJsonBuilder.Create;
  FJsonWriter := TJsonWriter.Create(FJsonBuilder);
  FJsonReader := TJsonReader.Create;
end;

class destructor TJsonBr.Destroy;
begin
  FJsonBuilder.Free;
  FJsonWriter.Free;
  FJsonReader.Free;
  inherited;
end;

class function TJsonBr.GetFormatSettings: TFormatSettings;
begin
  Result := JsonBrFormatSettings;
end;

class procedure TJsonBr.SaveJsonToFile(const AFileName: String;
  const AUtf8: Boolean);
begin
  FJsonReader.SaveJsonToFile(AFileName, AUtf8);
end;

class procedure TJsonBr.SetFormatSettings(const Value: TFormatSettings);
begin
  JsonBrFormatSettings := Value;
end;

class procedure TJsonBr.SetNotifyEventGetValue(const Value: TNotifyEventGetValue);
begin
  FJsonBuilder.OnGetValue := Value;
end;

class procedure TJsonBr.JsonToObject(const AJson: String; AObject: TObject);
begin
  FJsonBuilder.JSONToObject(AObject, AJson);
end;

class function TJsonBr.JsonToObject<T>(const AObject: T;
  const AJson: String): Boolean;
begin
  Result := FJsonBuilder.JSONToObject(TObject(AObject), AJson);
end;

class function TJsonBr.JsonToObject<T>(const AJson: String): T;
begin
  Result := FJsonBuilder.JSONToObject<T>(AJson);
end;

class function TJsonBr.ObjectListToJsonString(AObjectList: TObjectList<TObject>;
  AStoreClassName: Boolean): String;
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

class function TJsonBr.ObjectListToJsonString<T>(AObjectList: TObjectList<T>;
  AStoreClassName: Boolean): String;
var
  LFor: integer;
  LResultBuilder: TStringBuilder;
begin
  LResultBuilder := TStringBuilder.Create;
  try
    LResultBuilder.Append('[');
    for LFor := 0 to AObjectList.Count -1 do
    begin
      LResultBuilder.Append(FJsonBuilder.ObjectToJSON(AObjectList.Items[LFor] as T, AStoreClassName));
      if LFor < AObjectList.Count -1 then
        LResultBuilder.Append(', ');
    end;
    LResultBuilder.ReplaceLastChar(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

class function TJsonBr.ObjectToJsonString(AObject: TObject;
  AStoreClassName: Boolean): String;
begin
  Result := FJsonBuilder.ObjectToJSON(AObject, AStoreClassName);
end;

class procedure TJsonBr.ParseFromFile(const AFileName: String;
  const AUtf8: Boolean);
begin
  FJsonReader.ParseFromFile(AFileName, AUtf8);
end;

class function TJsonBr.Reader: TJsonReader;
begin
  Result := FJsonReader;
end;

class function TJsonBr.Data: TJsonData;
begin
  Result := FJsonReader.CurrentData;
end;

class procedure TJsonBr.SetNotifyEventSetValue(const Value: TNotifyEventSetValue);
begin
  FJsonBuilder.OnSetValue := Value;
end;

class function TJsonBr.Write: TJsonWriter;
begin
  Result := FJsonWriter;
end;

class function TJsonBr.JsonToObjectList(const AJson: String;
  const AType: TClass): TObjectList<TObject>;
begin
  Result := FJsonBuilder.JsonToObjectList(AJson, AType);
end;

class function TJsonBr.JsonToObjectList<T>(const AJson: String): TObjectList<T>;
begin
  Result := FJsonBuilder.JsonToObjectList<T>(AJson);
end;

end.
