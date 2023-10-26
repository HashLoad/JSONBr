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

{ @abstract(JSONBr Framework)
  @created(23 Nov 2020)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Telegram : @IsaquePinheiro)
}

{$INCLUDE ..\jsonbr.inc}

unit jsonbr.reader;

interface

uses
  Rtti,
  SysUtils,
  Classes,
  Variants,
  Generics.Collections,
  generics.Defaults,
  jsonbr.builders;

type
  TJsonReader = class
  private
    FJsonData: TJsonData;
    FCurrentData: TJsonData;
    function _Kind: TJsonValueKind;
    function _SplitString(const AString: string;
      const ADelimiter: string): TArray<string>;
//    procedure SetJsonData(const Value: TJsonData);
  public
    function IsObject: boolean;
    function IsArray: boolean;
    function IsEmpty: boolean;
    function IsNull: boolean;
    function IsInteger: boolean;
    function IsString: boolean;
    function IsFloat: boolean;
    function GetObject(const APath: TArray<string>): TJsonReader; overload;
    function GetObject(const APath: string): TJsonReader; overload;
    function GetArray(const AName: string): TJsonReader;
    function GetValue<T>(const AName: string): T;
    function GetItem<T>(const AIndex: integer): T;
    function ParseFromFile(const AFileName: string;
      const AUtf8: boolean = true): TJsonReader;
    procedure SaveJsonToFile(const AFileName: string;
      const AUtf8: boolean = true);
    property CurrentData: TJsonData read FCurrentData;
//    property JsonData: TJsonData read FJsonData write SetJsonData;
   end;

implementation

{ TJsonReader }

function TJsonReader.GetArray(const AName: string): TJsonReader;
var
  LValue: Variant;
begin
  Result := Self;
  if FCurrentData.Count = 0 then
    exit;
  LValue := FCurrentData.Value[AName];
  if VarIsEmpty(LValue) then
    exit;
  FCurrentData.Clear;
  FCurrentData := TJsonData(LValue);
  if FCurrentData.Kind <> jtkArray then
    exit;
end;

function TJsonReader.GetObject(const APath: TArray<string>): TJsonReader;
var
  LFor: integer;
  LValue: Variant;
begin
  Result := Self;
  FCurrentData.Clear;
  FCurrentData := FJsonData;
  for LFor := Low(APath) to High(APath) do
  begin
    if FCurrentData.Count = 0 then
      break;
    LValue := FCurrentData.Value[APath[LFor]];
    if VarIsEmpty(LValue) then
      break;
    FCurrentData.Clear;
    FCurrentData.Init(LValue);
    if FCurrentData.Kind <> jtkObject then
      break;
  end;
end;

function TJsonReader.GetValue<T>(const AName: string): T;
var
  LValue: Variant;
begin
  Result := Default(T);
  if FCurrentData.Count = 0 then
    exit;
  LValue := FCurrentData.Value[AName];
  if VarIsEmpty(LValue) then
    exit;
  Result := TValue.From(LValue).AsType<T>;
  FCurrentData.Clear;
  FCurrentData := FJsonData;
end;

function TJsonReader.GetItem<T>(const AIndex: integer): T;
var
  LValue: Variant;
begin
  Result := Default(T);
  if AIndex > FCurrentData.Count then
    exit;
  LValue := FCurrentData.Item[AIndex];
  if VarIsEmpty(LValue) then
    exit;
  Result := TValue.From(LValue).AsType<T>;
  FCurrentData := FJsonData;
end;

function TJsonReader.GetObject(const APath: string): TJsonReader;
var
  LPath: TArray<string>;
begin
  LPath := _SplitString(APath, '/');
  Result := GetObject(LPath);
end;

function TJsonReader.IsArray: boolean;
begin
  Result := FJsonData.Kind = jtkArray;
end;

function TJsonReader.IsEmpty: boolean;
begin
  Result := FJsonData.Count = 0;
end;

function TJsonReader.IsFloat: boolean;
begin
  Result := _Kind = jvkFloat;
end;

function TJsonReader.IsInteger: boolean;
begin
  Result := _Kind = jvkInteger;
end;

function TJsonReader.IsNull: boolean;
begin
  Result := _Kind = jvkNull;
end;

function TJsonReader.IsObject: boolean;
begin
  Result := FJsonData.Kind = jtkObject;
end;

function TJsonReader.IsString: boolean;
begin
  Result := _Kind = jvkString;
end;

function TJsonReader._Kind: TJsonValueKind;
begin
  Result := FJsonData.DataType;
end;

function TJsonReader.ParseFromFile(const AFileName: string;
  const AUtf8: boolean): TJsonReader;
var
  LStream: TFileStream;
  LStreamReader: TStreamReader;
  LJsonString: string;
begin
  Result := Self;
  LStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    if AUtf8 then
      LStreamReader := TStreamReader.Create(LStream, TEncoding.UTF8)
    else
      LStreamReader := TStreamReader.Create(LStream);
    try
      LJsonString := LStreamReader.ReadToEnd();
    finally
      LStreamReader.Free;
    end;
    FJsonData.Clear;
    FJsonData.Init(LJsonString);
    FCurrentData.Clear;
    FCurrentData := FJsonData;
  finally
    LStream.Free;
  end;
end;

procedure TJsonReader.SaveJsonToFile(const AFileName: string;
  const AUtf8: boolean);
var
  LStreamWriter: TStreamWriter;
begin
  if AUtf8 then
    LStreamWriter := TStreamWriter.Create(AFileName, false, TEncoding.UTF8)
  else
    LStreamWriter := TStreamWriter.Create(AFileName, false);
  try
    LStreamWriter.Write(FJsonData.ToJson);
  finally
    LStreamWriter.Free;
  end;
end;

//procedure TJsonReader.SetJsonData(const Value: TJsonData);
//begin
//  FJsonData.Clear;
//  FCurrentData.Clear;
//  FJsonData := Value;
//  FCurrentData := Value;
//end;

function TJsonReader._SplitString(const AString: string;
  const ADelimiter: string): TArray<string>;
var
  LDelimiterPos, LLastDelimiterPos: integer;
  LPart: string;
begin
  LLastDelimiterPos := 1;
  SetLength(Result, 0);
  repeat
    LDelimiterPos := Pos(ADelimiter, AString, LLastDelimiterPos);
    if LDelimiterPos > 0 then
    begin
      LPart := Copy(AString, LLastDelimiterPos, LDelimiterPos - LLastDelimiterPos);
      LLastDelimiterPos := LDelimiterPos + Length(ADelimiter);
    end
    else
      LPart := Copy(AString, LLastDelimiterPos, Length(AString));
    if LPart <> '' then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := LPart;
    end;
  until LDelimiterPos = 0;
end;

end.

