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
  Rtti,
  SysUtils,
  StrUtils,
  Classes,
  Variants,
  Generics.Collections,
  jsonbr.utils,
  jsonbr.types,
  jsonbr.writer,
  jsonbr.reader,
  jsonbr.builders;

type
  TJsonBr = class
  strict private
    class var FJsonBuilder: TJsonBuilder;
    class var FJsonWriter: IJsonWriter;
    class var FJsonReader: IJsonReader;
    class procedure _SetNotifyEventGetValue(const Value: TNotifyEventGetValue); static; inline;
    class procedure _SetNotifyEventSetValue(const Value: TNotifyEventSetValue); static; inline;
    class procedure _SetFormatSettings(const Value: TFormatSettings); static; inline;
    class function _GetFormatSettings: TFormatSettings; static; inline;
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
    class function BeginObject(const AValue: String = ''): IJsonWriter; inline;
    class function BeginArray: IJsonWriter; inline;
    // Reader
    class procedure ParseFromFile(const AFileName: String; const AUtf8: Boolean = True); inline;
    class procedure SaveJsonToFile(const AFileName: String; const AUtf8: Boolean = True); inline;
    class function Write: IJsonWriter; inline;
    class function Reader: IJsonReader; inline;
    // Middlewares GetValue/SetValue
    class procedure AddMiddleware(const AEventMiddleware: IEventMiddleware);
    {$MESSAGE WARN 'This property [OnSetValue] has been deprecated, Use middlewares instead.'}
    class property OnSetValue: TNotifyEventSetValue write _SetNotifyEventSetValue;
    {$MESSAGE WARN 'This property [OnGetValue] has been deprecated, Use middlewares instead.'}
    class property OnGetValue: TNotifyEventGetValue write _SetNotifyEventGetValue;
    class property FormatSettings: TFormatSettings read _GetFormatSettings write _SetFormatSettings;
  end;

implementation

{ TJSONBr }

class procedure TJsonBr.AddMiddleware(const AEventMiddleware: IEventMiddleware);
begin
  FJsonBuilder.AddMiddleware(AEventMiddleware);
end;

class function TJsonBr.BeginArray: IJsonWriter;
begin
  Result := FJsonWriter.BeginArray;
end;

class function TJsonBr.BeginObject(const AValue: String = ''): IJsonWriter;
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
  inherited;
end;

class function TJsonBr._GetFormatSettings: TFormatSettings;
begin
  Result := GJsonBrFormatSettings;
end;

class procedure TJsonBr.SaveJsonToFile(const AFileName: String;
  const AUtf8: Boolean);
begin
  FJsonReader.SaveJsonToFile(AFileName, AUtf8);
end;

class procedure TJsonBr._SetFormatSettings(const Value: TFormatSettings);
begin
  GJsonBrFormatSettings := Value;
end;

class procedure TJsonBr._SetNotifyEventGetValue(const Value: TNotifyEventGetValue);
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
  LFor: Integer;
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

class function TJsonBr.Reader: IJsonReader;
begin
  Result := FJsonReader;
end;

class procedure TJsonBr._SetNotifyEventSetValue(const Value: TNotifyEventSetValue);
begin
  FJsonBuilder.OnSetValue := Value;
end;

class function TJsonBr.Write: IJsonWriter;
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
