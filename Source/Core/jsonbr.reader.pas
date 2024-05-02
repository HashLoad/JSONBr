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
  TypInfo,
  StrUtils,
  SysUtils,
  Classes,
  Variants,
  Generics.Collections,
  Generics.Defaults,
  jsonbr.types,
  jsonbr.builders;

type
  TJsonNode = class
  private
    FName: String;
    FField: String;
    FValue: Variant;
    FValueType: TJsonValueKind;
    FChildren: TObjectList<TJsonNode>;
  public
    constructor Create(const AValueType: TJsonValueKind;
      const AName: String; const AField: String; const AValue: Variant);
    destructor Destroy; override;
    function IsObject: Boolean;
    function IsArray: Boolean;
    function IsBoolean: Boolean;
    function IsEmpty: Boolean;
    function IsNull: Boolean;
    function IsInteger: Boolean;
    function IsString: Boolean;
    function IsFloat: Boolean;
    function ToString: String; override;
    function ToJson: String;
    property ValueType: TJsonValueKind read FValueType;
    property Name: String read FName;
    property Field: String read FField;
    property Value: Variant read FValue;
    property Children: TObjectList<TJsonNode> read FChildren;
  end;

  TListHelper = class helper for TList<TJsonNode>
  public
    function FindNode(const APredicate: TFunc<TJsonNode, Boolean>): TJsonNode;
  end;

  TJsonReader = class
  private
    FRootNode: TJsonNode;
    procedure _ParseJson(const AKey: String;
      const AData: TJsonData; const AParentNode: TJsonNode);
    function _GetValueType(const AValue: Variant): TJsonValueKind;
  public
    destructor Destroy; override;
    function GetValue(const APath: String): TJsonNode;
    function GetRoot: TJsonNode;
    function ToJson: String;
    function ParseFromFile(const AFileName: String;
      const AUtf8: Boolean = True): TJsonReader;
    procedure SaveJsonToFile(const AFileName: String;
      const AUtf8: Boolean = True);
   end;

implementation

{ TJsonReader }

destructor TJsonReader.Destroy;
begin
  FRootNode.Free;
  inherited;
end;

function TJsonReader.GetValue(const APath: string): TJsonNode;
var
  LFindNode: TJsonNode;
begin
  Result := nil;
  LFindNode := FRootNode.Children.FindNode(
    function(ANode: TJsonNode): Boolean
    begin
      Result := (ANode.Name = APath);
    end);
  if not Assigned(LFindNode) then
    Exit;
  Result := LFindNode;
end;

function TJsonReader.GetRoot: TJsonNode;
begin
  Result := FRootNode;
end;

function TJsonReader.ToJson: String;
begin
  Result := FRootNode.ToJson;
end;

function TJsonReader.ParseFromFile(const AFileName: String;
  const AUtf8: Boolean): TJsonReader;
var
  LStream: TFileStream;
  LStreamReader: TStreamReader;
  LJsonString: String;
  LData: TJsonData;
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
    // Parse Json
    LData.Init(LJsonString);
    if Assigned(FRootNode) then
      FRootNode.Free;

    case LData.Kind of
      jtkObject:
        FRootNode := TJsonNode.Create(TJsonValueKind.jvkObject, 'Root', '', Null);
      jtkArray:
        FRootNode := TJsonNode.Create(TJsonValueKind.jvkArray, 'Root', '', Null);
    end;
    //
    _ParseJson('/', LData, FRootNode);
  finally
    LStream.Free;
  end;
end;

procedure TJsonReader.SaveJsonToFile(const AFileName: String;
  const AUtf8: Boolean);
var
  LStreamWriter: TStreamWriter;
begin
  if AUtf8 then
    LStreamWriter := TStreamWriter.Create(AFileName, False, TEncoding.UTF8)
  else
    LStreamWriter := TStreamWriter.Create(AFileName, False);
  try
    LStreamWriter.Write(Self.ToJson);
  finally
    LStreamWriter.Free;
  end;
end;

function TJsonReader._GetValueType(const AValue: Variant): TJsonValueKind;
var
  LValueType: Integer;
begin
  LValueType := VarType(AValue);
  case LValueType of
    varEmpty: Result := TJsonValueKind.jvkNone;
    varNull: Result := TJsonValueKind.jvkNull;
    varSmallint, varInteger,
    varShortInt, varByte,
    varWord, varLongWord,
    varInt64: Result := TJsonValueKind.jvkInteger;
    varSingle, varDouble,
    varCurrency: Result := TJsonValueKind.jvkFloat;
    varDate: Result := TJsonValueKind.jvkFloat;
    varBoolean: Result := TJsonValueKind.jvkBoolean;
    varString, varUString,
    varOleStr: Result := TJsonValueKind.jvkString;
    varObject: Result := TJsonValueKind.jvkObject;
    varArray: Result := TJsonValueKind.jvkArray;
  else
     Result := TJsonValueKind.jvkNone;
  end;
end;

procedure TJsonReader._ParseJson(const AKey: string; const AData: TJsonData;
  const AParentNode: TJsonNode);
var
  LChildNode: TJsonNode;
  LFor: Int16;
  LKey: String;
begin
  for LFor := 0 to AData.Count - 1 do
  begin
    LKey := AKey + VarToStr(AData.Names[LFor]);
    case TJsonData(AData.Values[LFor]).Kind of
      TJsonTypeKind.jtkUndefined:
      begin
        LChildNode := TJsonNode.Create(_GetValueType(AData.Values[LFor]), LKey, VarToStr(AData.Names[LFor]), VarToStr(AData.Values[LFor]));
        AParentNode.Children.Add(LChildNode);
      end;
      TJsonTypeKind.jtkObject:
      begin
        LChildNode := TJsonNode.Create(TJsonValueKind.jvkObject, LKey, VarToStr(AData.Names[LFor]), Null);
        AParentNode.Children.Add(LChildNode);
        LKey := LKey + '/';
        //
        _ParseJson(LKey, TJsonData(AData.Values[LFor]), LChildNode);
      end;
      TJsonTypeKind.jtkArray:
      begin
        LChildNode := TJsonNode.Create(TJsonValueKind.jvkArray, LKey, VarToStr(AData.Names[LFor]), Null);
        AParentNode.Children.Add(LChildNode);
        LKey := LKey + '/';
        //
        _ParseJson(LKey, TJsonData(AData.Values[LFor]), LChildNode);
      end;
    end;
  end;
end;

constructor TJsonNode.Create(const AValueType: TJsonValueKind;
  const AName: String; const AField: String; const AValue: Variant);
begin
  FValueType := AValueType;
  FName := AName;
  FField := AField;
  FValue := AValue;
  FChildren := TObjectList<TJsonNode>.Create;
end;

destructor TJsonNode.Destroy;
begin
  FChildren.Free;
  inherited;
end;

function TJsonNode.IsArray: Boolean;
begin
  Result := FValueType in [TJsonValueKind.jvkArray];
end;

function TJsonNode.IsBoolean: Boolean;
begin
  Result := FValueType in [TJsonValueKind.jvkBoolean];
end;

function TJsonNode.IsEmpty: Boolean;
begin
  Result := False;
  if FValueType in [TJsonValueKind.jvkString] then
    if FValue = EmptyStr then
      Result := True;
end;

function TJsonNode.IsFloat: Boolean;
begin
  Result := FValueType in [TJsonValueKind.jvkFloat];
end;

function TJsonNode.IsInteger: Boolean;
begin
  Result := FValueType in [TJsonValueKind.jvkInteger];
end;

function TJsonNode.IsNull: Boolean;
begin
  Result := FValueType in [TJsonValueKind.jvkNull];
end;

function TJsonNode.IsObject: Boolean;
begin
  Result := FValueType in [TJsonValueKind.jvkObject];
end;

function TJsonNode.IsString: Boolean;
begin
  Result := FValueType in [TJsonValueKind.jvkString];
end;

function TJsonNode.ToString: String;
var
  LChild: TJsonNode;
  LValue: String;
begin
  case FValueType of
    jvkArray:
    begin
      Result := '"' + FField + '"' + ': [';
      for LChild in FChildren do
        Result := Result + LChild.ToString + ', ';
      if FChildren.Count > 0 then
        Result := Copy(Result, 1, Length(Result) - 2);
      Result := Result + ']';
    end;
    jvkObject:
    begin
      Result := '"' + FField + '"' + ': {';
      for LChild in FChildren do
        Result := Result + LChild.ToString + ', ';
      if FChildren.Count > 0 then
        Result := Copy(Result, 1, Length(Result) - 2);
      Result := Result + '}';
    end;
    else
    begin
      LValue := VarToStr(FValue);
      if FValueType in [TJsonValueKind.jvkString] then
        LValue := '"' + LValue + '"';
      Result := '"' + FField + '"' + ': ' + LValue;
    end;
  end;
end;

function TJsonNode.ToJson: string;
var
  LChild: TJsonNode;
  LItem: TJsonNode;
  LBuilder: TStringBuilder;
  LCommaNeeded: Boolean;
begin
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.Append(IfThen(FValueType in [TJsonValueKind.jvkObject], '{', '['));
    LCommaNeeded := False;
    for LChild in FChildren do
    begin
      if LCommaNeeded then
        LBuilder.Append(', ');

      if not (FValueType in [TJsonValueKind.jvkArray]) then
        LBuilder.Append('"').Append(LChild.Field).Append('": ');

      if LChild.ValueType in [TJsonValueKind.jvkObject, TJsonValueKind.jvkArray] then
        LBuilder.Append(LChild.ToJson);

      if LChild.ValueType = TJsonValueKind.jvkString then
        LBuilder.Append('"').Append(VarToStr(LChild.Value)).Append('"')
      else
      if LChild.ValueType = TJsonValueKind.jvkNull then
        LBuilder.Append('null')
      else
      if LChild.ValueType = TJsonValueKind.jvkFloat then
        LBuilder.Append(StringReplace(VarToStr(LChild.Value), ',', '.', [rfReplaceAll]))
      else
        LBuilder.Append(VarToStr(LChild.Value));
      LCommaNeeded := True;
    end;
    LBuilder.Append(IfThen(FValueType in [TJsonValueKind.jvkObject], '}', ']'));
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

function TListHelper.FindNode(const APredicate: TFunc<TJsonNode, Boolean>): TJsonNode;
var
  LNode: TJsonNode;
begin
  Result := nil;
  for LNode in Self do
  begin
    if APredicate(LNode) then
    begin
      Result := LNode;
      Exit;
    end;
    Result := LNode.Children.FindNode(APredicate);
    if Assigned(Result) then
      Exit;
  end;
end;

end.

