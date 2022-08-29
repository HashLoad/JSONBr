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

unit jsonbr.writer;

interface

uses
  SysUtils,
  jsonbr.builders;

type
  TJSONWriter = class
  private
    FJSONObject: TJSONBrObject;
    FJSON: String;
  public
    constructor Create;
    destructor Destroy; override;
    function BeginObject(const AValue: String = ''): TJSONWriter;
    function BeginArray: TJSONWriter;
    function EndObject: TJSONWriter;
    function EndArray: TJSONWriter;
    function AddPair(const APair: String; const AValue: String): TJSONWriter; overload;
    function AddPair(const APair: String; const AValue: Integer): TJSONWriter; overload;
    function AddPair(const APair: String; const AValue: TJSONWriter): TJSONWriter; overload;
    function AddPairArray(const APair: String; const AValue: array of string): TJSONWriter; overload;
    function AddPairArray(const APair: String; const AValue: array of Integer): TJSONWriter; overload;
    function ToJSON: String;
  end;

implementation

{ TJSONWriter }

function TJSONWriter.AddPair(const APair: String; const AValue: String): TJSONWriter;
begin
  Result := Self;
  FJSON := FJSON + FJSONObject.StringToJSON(APair) + ':' + FJSONObject.ValueToJSON(AValue) + ',';
end;

function TJSONWriter.AddPair(const APair: String;
  const AValue: Integer): TJSONWriter;
begin
  Result := Self;
  FJSON := FJSON + FJSONObject.StringToJSON(APair) + ':' + FJSONObject.ValueToJSON(AValue) + ',';
end;

function TJSONWriter.AddPair(const APair: String;
  const AValue: TJSONWriter): TJSONWriter;
begin
  Result := Self;
  FJSON := FJSON + FJSONObject.StringToJSON(APair) + ':' + AValue.ToJSON;
end;

function TJSONWriter.AddPairArray(const APair: String;
  const AValue: array of Integer): TJSONWriter;
var
  LFor: Integer;
begin
  Result := Self;
  FJSON := FJSON + FJSONObject.StringToJSON(APair) + ':[';
  for LFor := Low(AValue) to High(AValue) do
    FJSON := FJSON + FJSONObject.ValueToJSON(AValue[LFor]) + ',';
  FJSON[Length(FJSON)] := ']';
  FJSON := FJSON + ',';
end;

function TJSONWriter.AddPairArray(const APair: String;
  const AValue: array of string): TJSONWriter;
var
  LFor: Integer;
begin
  Result := Self;
  FJSON := FJSON + FJSONObject.StringToJSON(APair) + ':[';
  for LFor := Low(AValue) to High(AValue) do
    FJSON := FJSON + FJSONObject.ValueToJSON(AValue[LFor]) + ',';
  FJSON[Length(FJSON)] := ']';
  FJSON := FJSON + ',';
end;

function TJSONWriter.BeginArray: TJSONWriter;
begin
  Result := Self;
  FJSON := FJSON + '[';
end;

function TJSONWriter.BeginObject(const AValue: String): TJSONWriter;
begin
  Result := Self;
  if Length(AValue) > 0 then
    FJSON := FJSON + FJSONObject.StringToJSON(AValue) + ':{'
  else
    FJSON := FJSON + '{';
end;

constructor TJSONWriter.Create;
begin
  FJSONObject := TJSONBrObject.Create;
end;

destructor TJSONWriter.Destroy;
begin
  FJSONObject.Free;
  inherited;
end;

function TJSONWriter.EndArray: TJSONWriter;
begin
  Result := Self;
  if FJSON[Length(FJSON)] = ',' then
    FJSON[Length(FJSON)] := ']'
  else
    FJSON := FJSON + ']';
end;

function TJSONWriter.EndObject: TJSONWriter;
begin
  Result := Self;
  // Tratamento para objeto vazio
  if Length(FJSON) = 1 then
  begin
    if FJSON[Length(FJSON)] = '{' then
    begin
      FJSON := '{}';
      Exit;
    end;
  end;
  FJSON[Length(FJSON)] := '}';
  FJSON := FJSON + ',';
end;

function TJSONWriter.ToJSON: String;
begin
  if FJSON[Length(FJSON)] = ',' then
    FJSON[Length(FJSON)] := ' ';
  Result := TrimRight(FJSON);
  FJSON := '';
end;

end.
