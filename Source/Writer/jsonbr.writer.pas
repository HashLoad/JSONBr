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
  IJsonWriter = interface
    ['{F46189B4-3D01-4C59-837D-5DC747C633FA}']
    function BeginObject(const AValue: String = ''): IJsonWriter;
    function BeginArray: IJsonWriter;
    function EndObject: IJsonWriter;
    function EndArray: IJsonWriter;
    function AddPair(const APair: String; const AValue: String): IJsonWriter; overload;
    function AddPair(const APair: String; const AValue: Char): IJsonWriter; overload;
    function AddPair(const APair: String; const AValue: Integer): IJsonWriter; overload;
    function AddPair(const APair: String; const AValue: Double): IJsonWriter; overload;
    function AddPair(const APair: String; const AValue: Boolean): IJsonWriter; overload;
    function AddPair(const APair: String; const AValue: IJsonWriter): IJsonWriter; overload;
    function AddPairNull(const APair: String; const AValue: Variant): IJsonWriter; overload;
    function AddPairArray(const APair: String; const AValue: array of TValue): IJsonWriter;
    function AddPairDate(const APair: String; const AValue: TDateTime): IJsonWriter; overload;
    function ToJson: String;
  end;

  TJsonWriter = class(TInterfacedObject, IJsonWriter)
  private
    FJsonBuilder: TJsonBuilder;
    FJson: TStringBuilder;
    procedure _EndJson;
  public
    constructor Create(const AJsonBuilder: TJsonBuilder);
    destructor Destroy; override;
    function BeginObject(const AValue: String = ''): IJsonWriter; inline;
    function BeginArray: IJsonWriter; inline;
    function EndObject: IJsonWriter; inline;
    function EndArray: IJsonWriter; inline;
    function AddPair(const APair: String; const AValue: String): IJsonWriter; overload; inline;
    function AddPair(const APair: String; const AValue: Char): IJsonWriter; overload; inline;
    function AddPair(const APair: String; const AValue: Integer): IJsonWriter; overload; inline;
    function AddPair(const APair: String; const AValue: Double): IJsonWriter; overload; inline;
    function AddPair(const APair: String; const AValue: Boolean): IJsonWriter; overload; inline;
    function AddPair(const APair: String; const AValue: IJsonWriter): IJsonWriter; overload; inline;
    function AddPairNull(const APair: String; const AValue: Variant): IJsonWriter; overload; inline;
    function AddPairArray(const APair: String; const AValue: array of TValue): IJsonWriter;
    function AddPairDate(const APair: String; const AValue: TDateTime): IJsonWriter; overload; inline;
    function ToJson: String; inline;
  end;

implementation

{ TJsonWriter }

constructor TJsonWriter.Create(const AJsonBuilder: TJsonBuilder);
begin
  FJsonBuilder := AJsonBuilder;
  FJson := TStringBuilder.Create;
end;

destructor TJsonWriter.Destroy;
begin
  FJson.Free;
  inherited;
end;

function TJsonWriter.BeginObject(const AValue: String): IJsonWriter;
begin
  if Length(AValue) > 0 then
    FJson.Append(FJsonBuilder.StringToJSON(AValue) + ':{')
  else
    FJson.Append('{');
  Result := Self;
end;

function TJsonWriter.BeginArray: IJsonWriter;
begin
  FJson.Append('[');
  Result := Self;
end;

function TJsonWriter.EndObject: IJsonWriter;
begin
  if FJson.Length > 1 then
    FJson.Chars[FJson.Length - 1] := '}'
  else
    FJson.Append('}');
  FJson.Append(',');
  Result := Self;
end;

function TJsonWriter.EndArray: IJsonWriter;
begin
  if FJson.Chars[FJson.Length - 1] = ',' then
    FJson.Length := FJson.Length - 1;
  FJson.Append(']');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: String): IJsonWriter;
begin
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: Integer): IJsonWriter;
begin
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: IJsonWriter): IJsonWriter;
begin
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' + AValue.ToJson);
  Result := Self;
end;

function TJsonWriter.AddPairArray(const APair: String;
  const AValue: array of TValue): IJsonWriter;
var
  LFor: Integer;
begin
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':[ ');
  for LFor := Low(AValue) to High(AValue) do
    FJson.Append(FJsonBuilder.ValueToJSON(AValue[LFor].ToString) + ',');
  if Length(AValue) > 0 then
    FJson.Length := FJson.Length - 1;
  FJson.Append(']');
  Result := Self;
end;

function TJsonWriter.AddPairDate(const APair: String;
  const AValue: TDateTime): IJsonWriter;
begin
  if not VarIsType(AValue, varDate) then
    raise Exception.Create('The value provided for the pair "' + APair + '" is not a valid TDateTime.');
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.AddPairNull(const APair: String;
  const AValue: Variant): IJsonWriter;
begin
  if AValue <> Null then
    raise Exception.Create('The value provided for the pair "' + APair + '" is not Null.');
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.ToJson: String;
begin
  Result := EmptyStr;
  if not Assigned(FJson) then
    Exit;
  if FJson.Chars[FJson.Length - 1] = ',' then
    FJson.Chars[FJson.Length - 1] := ' ';
  Result := TrimRight(FJson.ToString);
  _EndJson;
end;

procedure TJsonWriter._EndJson;
begin
  if Assigned(FJson) then
    FJson.Clear;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: Boolean): IJsonWriter;
begin
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: Double): IJsonWriter;
begin
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

function TJsonWriter.AddPair(const APair: String;
  const AValue: Char): IJsonWriter;
begin
  FJson.Append(FJsonBuilder.StringToJSON(APair) + ':' +
               FJsonBuilder.ValueToJSON(AValue) + ',');
  Result := Self;
end;

end.
