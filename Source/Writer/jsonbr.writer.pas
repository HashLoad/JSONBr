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

{
  @abstract(JSONBr Framework)
  @created(23 Nov 2020)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Telegram : @IsaquePinheiro)
}

{$INCLUDE ..\jsonbr.inc}

unit jsonbr.writer;

interface

uses
  Rtti,
  Variants,
  SysUtils,
  Classes,
  jsonbr.utils,
  jsonbr.builders;

type
  TJsonWriter = class
  private
    FJsonBuilder: TJsonBuilder;
    FJson: TStringBuilder;
    procedure _BeginJson;
    procedure _EndJson;
  public
    constructor Create(const AJsonBuilder: TJsonBuilder);
    function BeginObject(const AValue: String = ''): TJsonWriter; inline;
    function BeginArray: TJsonWriter; inline;
    function EndObject: TJsonWriter; inline;
    function EndArray: TJsonWriter; inline;
    function AddPair(const APair: String; const AValue: String): TJsonWriter; overload; inline;
    function AddPair(const APair: String; const AValue: Integer): TJsonWriter; overload; inline;
    function AddPair(const APair: String; const AValue: TJsonWriter): TJsonWriter; overload; inline;
    function AddPairArray(const APair: String; const AValue: array of TValue): TJsonWriter;
    function ToJson: String; inline;
  end;

implementation

{ TJsonWriter }

constructor TJsonWriter.Create(const AJsonBuilder: TJsonBuilder);
begin
  FJsonBuilder := AJsonBuilder;
end;

function TJsonWriter.BeginObject(const AValue: String): TJsonWriter;
begin
  _BeginJson;
  if Length(AValue) > 0 then
    FJson.Append(FJsonBuilder.StringToJSON(AValue) + ':{')
  else
    FJson.Append('{');
  Result := Self;
end;

function TJsonWriter.BeginArray: TJsonWriter;
begin
  _BeginJson;
  FJson.Append('[');
  Result := Self;
end;

function TJsonWriter.EndObject: TJsonWriter;
begin
  _BeginJson;
  if FJson.Length > 1 then
    FJson.Chars[FJson.Length - 1] := '}'
  else
    FJson.Append('}');
  FJson.Append(',');
  Result := Self;
end;

function TJsonWriter.EndArray: TJsonWriter;
begin
  _BeginJson;
  if FJson.Chars[FJson.Length - 1] = ',' then
    FJson.Length := FJson.Length - 1;
  FJson.Append(']');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: String): TJsonWriter;
begin
  _BeginJson;
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: Integer): TJsonWriter;
begin
  _BeginJson;
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: TJsonWriter): TJsonWriter;
begin
  _BeginJson;
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' + AValue.ToJson);
  Result := Self;
end;

function TJsonWriter.AddPairArray(const APair: String;
  const AValue: array of TValue): TJsonWriter;
var
  LFor: Integer;
begin
  _BeginJson;
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':[ ');
  for LFor := Low(AValue) to High(AValue) do
    FJson.Append(FJsonBuilder.ValueToJSON(AValue[LFor].ToString) + ',');
  if Length(AValue) > 0 then
    FJson.Length := FJson.Length - 1;
  FJson.Append(']');
  Result := Self;
end;

function TJsonWriter.ToJson: String;
begin
  _BeginJson;
  if FJson.Chars[FJson.Length - 1] = ',' then
    FJson.Chars[FJson.Length - 1] := ' ';
  Result := TrimRight(FJson.ToString);
  _EndJson;
end;

procedure TJsonWriter._BeginJson;
begin
  if not Assigned(FJson) then
    FJson := TStringBuilder.Create;
end;

procedure TJsonWriter._EndJson;
begin
  if Assigned(FJson) then
    FJson.Free;
end;

end.
