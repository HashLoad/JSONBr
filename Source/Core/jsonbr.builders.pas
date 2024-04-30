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
  @abstract(JSONBr Framework.)
  @created(23 Nov 2020)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Telegram : @IsaquePinheiro)
}

{$INCLUDE ..\jsonbr.inc}

unit jsonbr.builders;

interface

uses
  Rtti,
  SysUtils,
  StrUtils,
  Classes,
  Variants,
  TypInfo,
  Types,
  Generics.Collections,
  jsonbr.utils;

type
  TStringBuilderHelper = class helper for TStringBuilder
  public
    procedure ReplaceLastChar(const AChar: Char);
  end;

  TJsonBrObject = class;
  TNotifyEventGetValue = procedure(const AInstance: TObject;
                                   const AProperty: TRttiProperty;
                                   var AResult: Variant;
                                   var ABreak: Boolean) of Object;
  TNotifyEventSetValue = procedure(const AInstance: TObject;
                                   const AProperty: TRttiProperty;
                                   const AValue: Variant;
                                   var ABreak: Boolean) of Object;
  EJsonBrException = class(Exception);
  TDynamicArrayKey = array of String;
  TDynamicArrayValue = array of Variant;
  TJsonTypeKind = (jtkUndefined, jtkObject, jtkArray);
  TJsonValueKind = (jvkNone, jvkNull, jvkString, jvkInteger, jvkFloat,
                    jvkObject, jvkArray, jvkBoolean);
  PropWrap = packed record
    FillBytes: array [0..SizeOf(pointer)-2] of byte;
    Kind: byte;
  end;

  TJsonData = record
  private
    FVType: TVarType;
    FVKind: TJsonTypeKind;
    FVCount: Integer;
    FNames: TDynamicArrayKey;
    FValues: TDynamicArrayValue;
    procedure SetKind(const Value: TJsonTypeKind);
    procedure SetValue(const AName: String; const AValue: Variant);
    procedure SetItem(AIndex: Integer; const AItem: Variant);
    function GetKind: TJsonTypeKind;
    function GetCount: Integer;
    function GetVarData(const AName: String; var ADest: TVarData): Boolean;
    function GetValueCopy(const AName: String): Variant;
    function GetValue(const AName: String): Variant;
    function GetItem(AIndex: Integer): Variant;
    function GetListType(LRttiType: TRttiType): TRttiType;
    function GetDataType: TJsonValueKind;
    type
      TJsonParser = record
      private
        FJson: String;
        FIndex: Integer;
        FJsonLength: Integer;
        function GetNextChar: Char;
        function GetNextNonWhiteChar: Char; inline;
        function CheckNextNonWhiteChar(AChar: Char): Boolean; inline;
        function GetNextString(out AStr: String): Boolean;
        function GetNextJson(out AValue: Variant): TJsonValueKind;
        function GetNextAlphaPropName(out AFieldName: String): Boolean;
        function ParseJsonObject(out AData: TJsonData): Boolean;
        function ParseJsonArray(out AData: TJsonData): Boolean;
        procedure Init(const AJson: String; AIndex: Integer = 1);
        procedure GetNextStringUnEscape(var AStr: String);
      end;
  public
    function NameIndex(const AName: String): Integer;
    function FromJson(const AJson: String): Boolean;
    function ToJson: String;
    function ToObject(AObject: TObject): Boolean;
    function Names: TDynamicArrayKey;
    function Values: TDynamicArrayValue;
    procedure Init; overload;
    procedure Init(const AJson: String); overload;
    procedure InitFrom(const AValues: TDynamicArrayValue); overload;
    procedure Clear;
    procedure AddValue(const AValue: Variant);
    procedure AddNameValue(const AName: String; const AValue: Variant);
    property Kind: TJsonTypeKind read GetKind write SetKind;
    property DataType: TJsonValueKind read GetDataType;
    property Count: Integer read GetCount;
    property Value[const AName: String]: Variant read GetValue write SetValue; default;
    property ValueCopy[const AName: String]: Variant read GetValueCopy;
    property Item[AIndex: Integer]: Variant read GetItem write SetItem;
  end;

  TJsonVariant = class(TInvokeableVariantType)
  public
    procedure Copy(var ADest: TVarData; const ASource: TVarData;
      const AIndirect: Boolean); override;
    procedure Clear(var AVarData: TVarData); override;
    function GetProperty(var ADest: TVarData; const AVarData: TVarData;
      const AName: String): Boolean; override;
    function SetProperty(const AVarData: TVarData; const AName: String;
      const AValue: TVarData): Boolean; override;
    procedure Cast(var ADest: TVarData; const ASource: TVarData); override;
    procedure CastTo(var ADest: TVarData; const ASource: TVarData;
      const AVarType: TVarType); override;
  end;

  TJsonBrObject = class
  private
    class var FNotifyEventSetValue: TNotifyEventSetValue;
    class var FNotifyEventGetValue: TNotifyEventGetValue;
  private
    function GetInstanceProp(AInstance: TObject; AProperty: TRttiProperty): Variant;
    class function ResolveValueArrayString(const AValue: Variant): TArray<String>; inline;
    class function ResolveValueArrayInteger(const AValue: Variant): TArray<Integer>; inline;
    class function ResolveValueArrayInt64(const AValue: Variant): TArray<int64>; inline;
    class function ResolveValueArrayDouble(const AValue: Variant): TArray<double>; inline;
    class function ResolveValueArrayCurrency(const AValue: Variant): TArray<currency>; inline;
    class function IsBlob(const ATypeInfo: PTypeInfo): Boolean; inline;
    class function GetValueArray(const ATypeInfo: PTypeInfo; const AValue: Variant): TValue; inline;
    class function JsonVariantData(const AValue: Variant): TJsonData; inline;
    class procedure SetInstanceProp(const AInstance: TObject; const AProperty: TRttiProperty; const AValue: Variant);
  public
    class var UseISO8601DateFormat: Boolean;
    function ObjectToJson(const AObject: TObject; const AStoreClassName: Boolean = False): String;
    function DynArrayStringToJson(const AValue: TValue): String;
    function DynArrayIntegerToJson(const AValue: TValue): String;
    function DynArrayDoubleToJson(const AValue: TValue): String;
    function JsonVariant(const AValues: TDynamicArrayValue): Variant; overload;
    function JsonVariant(const AJson: String): Variant; overload;
    function JsonToObject(AObject: TObject; const AJson: String): Boolean; overload;
    function JsonToObject<T: class, constructor>(const AJson: String): T; overload;
    function JsonToObjectList<T: class, constructor>(const AJson: String): TObjectList<T>; overload;
    function JsonToObjectList(const AJson: String; const AType: TClass): TObjectList<TObject>; overload;
    class function StringToJson(const AText: String): String;
    class function ValueToJson(const AValue: Variant): String; inline;
    class property OnSetValue: TNotifyEventSetValue read FNotifyEventSetValue write FNotifyEventSetValue;
    class property OnGetValue: TNotifyEventGetValue read FNotifyEventGetValue write FNotifyEventGetValue;
  end;

var
  JsonVariantType: TInvokeableVariantType;

implementation

{ TJsonBrObject }

function TJsonBrObject.JsonVariant(const AJson: String): Variant;
begin
  VarClear(Result);
  TJsonData(Result).FromJson(AJson);
end;

function TJsonBrObject.JsonVariant(const AValues: TDynamicArrayValue): Variant;
begin
  VarClear(Result);
  TJsonData(Result).Init;
  TJsonData(Result).FVKind := jtkArray;
  TJsonData(Result).FVCount := Length(AValues);
  TJsonData(Result).FValues := AValues;
end;

class function TJsonBrObject.JsonVariantData(const AValue: Variant): TJsonData;
var
  LVarData: TVarData;
begin
  LVarData := TVarData(AValue);
  if LVarData.VType = JsonVariantType.VarType then
    Result := TJsonData(AValue)
  else
  if LVarData.VType = varByRef or varVariant then
    Result := TJsonData(PVariant(LVarData.VPointer)^)
  else
    raise EJsonBrException.CreateFmt('JSONBrVariantData.Data(%d<>JSONVariant)', [LVarData.VType]);
end;

class function TJsonBrObject.StringToJson(const AText: String): String;
var
  LLen, LFor: Integer;

  procedure DoEscape;
  var
    LChr: Integer;
    LBuilder: TStringBuilder;
  begin
    LBuilder := TStringBuilder.Create;
    try
      LBuilder.Append('"' + Copy(AText, 1, LFor - 1));
      for LChr := LFor to LLen do
      begin
        case AText[LChr] of
          #8:  LBuilder.Append('\b');
          #9:  LBuilder.Append('\t');
          #10: LBuilder.Append('\n');
          #12: LBuilder.Append('\f');
          #13: LBuilder.Append('\r');
          '\': LBuilder.Append('\\');
          '"': LBuilder.Append('\"');
        else
          if AText[LChr] < ' ' then
            LBuilder.Append('\u00' + IntToHex(Ord(AText[LChr]), 2))
          else
            LBuilder.Append(AText[LChr]);
        end;
      end;
      LBuilder.Append('"');
      Result := LBuilder.ToString;
    finally
      LBuilder.Free;
    end;
  end;

begin
  LLen := Length(AText);
  for LFor := 1 to LLen do
//    case AText[Lfor] of
//     '[', ']': continue;
//    end;
    case AText[LFor] of
      #0 .. #31, '\', '"':
      begin
        DoEscape;
        exit;
      end;
    end;
  Result := '"' + AText + '"';
end;

class function TJsonBrObject.ValueToJson(const AValue: Variant): String;
var
  LDouble: Double;
begin
  if TVarData(AValue).VType = JsonVariantType.VarType then
    Result := TJsonData(AValue).ToJson
  else
  begin
    case TVarData(AValue).VType of
      varByRef, varVariant:
        Result := ValueToJson(PVariant(TVarData(AValue).VPointer)^);
      varNull:
        Result := 'null';
      varBoolean:
        begin
          if TVarData(AValue).VBoolean then
            Result := 'True'
          else
            Result := 'False';
        end;
      varDate:
        Result := '"' + DateTimeToIso8601(TVarData(AValue).VDouble, UseISO8601DateFormat) + '"';
    else
      if VarIsOrdinal(AValue) then
      begin
        Result := VarToStr(AValue);
      end
      else
      if VarIsFloat(AValue) then
      begin
        LDouble := AValue;
        Result := FloatToStr(LDouble, JsonBrFormatSettings)
      end
      else
      if VarIsStr(AValue) then
        Result :=  StringToJson(VarToStr(AValue))
      else
        Result := VarToStr(AValue);
    end;
  end;
end;

function TJsonBrObject.GetInstanceProp(AInstance: TObject;
  AProperty: TRttiProperty): Variant;
var
  LObject: TObject;
  LTypeInfo: PTypeInfo;
  LBreak: Boolean;

  function IsBoolean: Boolean;
  var
    LTypeName: String;
  begin
    LTypeName := AProperty.PropertyType.Handle.NameFld.ToString;
    Result := SameText(LTypeName, 'Boolean') or SameText(LTypeName, 'bool');
  end;

begin
  VarClear(Result);
  // Notify Event
  if Assigned(FNotifyEventGetValue) then
  begin
    LBreak := False;
    FNotifyEventGetValue(AInstance, AProperty, Result, LBreak);
    if LBreak then
      exit;
  end;

  LTypeInfo := AProperty.PropertyType.Handle;
  try
    case AProperty.PropertyType.TypeKind of
      tkInt64:
        Result := AProperty.GetValue(AInstance).AsInt64;
      tkInteger, tkSet:
        Result := AProperty.GetValue(AInstance).AsInteger;
      tkUString, tkLString, tkWString, tkString, tkChar, tkWChar:
        Result := AProperty.GetValue(AInstance).AsString;
      tkFloat:
        case GetTypeData(LTypeInfo)^.FloatType of
          ftSingle:
            begin
              Result := StrToFloat(AProperty.GetValue(AInstance).AsString, JsonBrFormatSettings);
            end;
          ftDouble:
            begin
              if (LTypeInfo = TypeInfo(TDateTime)) or (LTypeInfo = TypeInfo(TDate)) or
                 (LTypeInfo = TypeInfo(TTime)) then
              begin
                Result := DateTimeToIso8601(AProperty.GetValue(AInstance).AsExtended, UseISO8601DateFormat);
              end
              else
                Result := AProperty.GetValue(AInstance).AsExtended;
            end;
          ftExtended:
            Result := AProperty.GetValue(AInstance).AsExtended;
          ftComp:
            Result := AProperty.GetValue(AInstance).AsExtended;
          ftCurr:
            Result := AProperty.GetValue(AInstance).AsCurrency;
        end;
      tkVariant, tkRecord:
        Result := AProperty.GetValue(AInstance).AsVariant;
      tkClass:
        begin
          LObject := AProperty.GetValue(AInstance).AsObject;
          if LObject <> nil then
           TJsonData(Result).Init(ObjectToJson(LObject))
          else
            Result := Null;
        end;
      tkEnumeration:
        begin
          if IsBoolean() then
            Result := AProperty.GetValue(AInstance).AsBoolean
          else
            Result := GetEnumValue(LTypeInfo, AProperty.GetValue(AInstance).AsString) >= 0;
        end;
      tkArray, tkDynArray:
        begin
          if IsBlob(LTypeInfo) then
            Result := Null
          else
          if AProperty.GetValue(AInstance).IsArray then
          begin
            if EndsText('<System.String>', String(LTypeInfo.Name)) then
              Result := DynArrayStringToJson(AProperty.GetValue(AInstance))
            else
            if EndsText('<System.Integer>', String(LTypeInfo.Name)) then
              Result := DynArrayIntegerToJson(AProperty.GetValue(AInstance))
            else
              Result := DynArrayDoubleToJson(AProperty.GetValue(AInstance))
          end;
        end;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro no GetValue() da propriedade [' + AProperty.Name + ']' + sLineBreak + E.Message);
  end;
end;

class function TJsonBrObject.GetValueArray(const ATypeInfo: PTypeInfo;
  const AValue: Variant): TValue;
var
  LValue: String;
begin
  Result := nil;
  if not Assigned(ATypeInfo) or not (ATypeInfo.Kind in [tkArray, tkDynArray]) then
    Exit;
  LValue := VarToStr(AValue);
  LValue := StringReplace(LValue, '[', '', [rfReplaceAll]);
  LValue := StringReplace(LValue, ']', '', [rfReplaceAll]);
  LValue := StringReplace(LValue, '"', '', [rfReplaceAll]);
  if EndsText('<System.String>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayString(LValue))
  else if EndsText('<System.Integer>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayInteger(LValue))
  else if EndsText('<System.Int64>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayInt64(LValue))
  else if EndsText('<System.Double>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayDouble(LValue))
  else if EndsText('<System.Currency>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayCurrency(LValue));
end;

class procedure TJsonBrObject.SetInstanceProp(const AInstance: TObject;
  const AProperty: TRttiProperty; const AValue: Variant);
var
  LBreak: Boolean;
  LTypeInfo: PTypeInfo;
  LObject: TObject;

  function IsBoolean: Boolean;
  var
    LTypeName: String;
  begin
    LTypeName := AProperty.PropertyType.Handle.NameFld.ToString;
    Result := SameText(LTypeName, 'Boolean') or SameText(LTypeName, 'bool');
  end;

begin
  if (AProperty = nil) and (AInstance = nil) then
    exit;
  // Notify Event
  if Assigned(FNotifyEventSetValue) then
  begin
    LBreak := False;
    FNotifyEventSetValue(AInstance, AProperty, AValue, LBreak);
    if LBreak then
      exit;
  end;
  LTypeInfo := AProperty.PropertyType.Handle;
  try
    case AProperty.PropertyType.TypeKind of
      tkString, tkWString, tkUString, tkWChar, tkLString, tkChar:
        if TVarData(AValue).VType <= varNull then
          AProperty.SetValue(AInstance, TValue.From<String>(''))
        else
          AProperty.SetValue(AInstance, TValue.From<String>(AValue));
      tkInteger, tkSet, tkInt64:
        AProperty.SetValue(AInstance, TValue.From<Integer>(AValue));
      tkFloat:
        if TVarData(AValue).VType <= varNull then
          AProperty.SetValue(AInstance, TValue.From<double>(0.0))
        else
        if (LTypeInfo = TypeInfo(TDateTime)) or
           (LTypeInfo = TypeInfo(TDate)) or
           (LTypeInfo = TypeInfo(TTime)) then
          AProperty.SetValue(AInstance, Iso8601ToDateTime(AValue, UseISO8601DateFormat))
        else
          AProperty.SetValue(AInstance, TValue.From<double>(AValue));
      tkVariant:
        AProperty.SetValue(AInstance, TValue.FromVariant(AValue));
      tkRecord:
        AProperty.SetValue(AInstance, TValue.FromVariant(AValue));
      tkClass:
        begin
          LObject := AProperty.GetValue(AInstance).AsObject;
          if LObject <> nil then
            JsonVariantData(AValue).ToObject(LObject);
        end;
      tkEnumeration:
        begin
          if IsBoolean() then
            AProperty.SetValue(AInstance, TValue.From<Boolean>(AValue))
          else
            AProperty.SetValue(AInstance, TValue.FromVariant(AValue));
        end;
      tkArray, tkDynArray:
        begin
          if IsBlob(LTypeInfo) then

          else
            AProperty.SetValue(AInstance, GetValueArray(LTypeInfo, AValue));
        end;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro no SetValue() da propriedade [' + AProperty.Name + ']' + sLineBreak + E.Message);
  end;
end;

function TJsonBrObject.DynArrayDoubleToJson(const AValue: TValue): String;
var
  LFor: Integer;
  LValue: Double;
  LResultBuilder: TStringBuilder;
begin
  LResultBuilder := TStringBuilder.Create;
  try
    LResultBuilder.Append('[');
    for LFor := 0 to AValue.GetArrayLength -1 do
    begin
      LValue := AValue.GetArrayElement(LFor).AsExtended;
      LResultBuilder.Append(LValue.ToString);
      if LFor < AValue.GetArrayLength - 1 then
        LResultBuilder.Append(', ');
    end;
    LResultBuilder.Append(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

function TJsonBrObject.DynArrayIntegerToJson(const AValue: TValue): String;
var
  LFor: Integer;
  LValue: Integer;
  LResultBuilder: TStringBuilder;
begin
  LResultBuilder := TStringBuilder.Create;
  try
    LResultBuilder.Append('[');
    for LFor := 0 to AValue.GetArrayLength -1 do
    begin
      LValue := AValue.GetArrayElement(LFor).AsInteger;
      LResultBuilder.Append(LValue.ToString);
      if LFor < AValue.GetArrayLength - 1 then
        LResultBuilder.Append(', ');
    end;
    LResultBuilder.Append(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

function TJsonBrObject.DynArrayStringToJson(const AValue: TValue): String;
var
  LFor: Integer;
  LResultBuilder: TStringBuilder;
begin
  LResultBuilder := TStringBuilder.Create;
  try
    LResultBuilder.Append('[');
    for LFor := 0 to AValue.GetArrayLength -1 do
    begin
      LResultBuilder.Append('"' + AValue.GetArrayElement(LFor).AsString + '"');
      if LFor < AValue.GetArrayLength -1 then
        LResultBuilder.Append(', ');
    end;
    LResultBuilder.Append(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

class function TJsonBrObject.IsBlob(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo = TypeInfo(TByteDynArray)) and
            (PropWrap(ATypeInfo).Kind = $FF);
end;

function TJsonBrObject.JsonToObjectList(const AJson: String;
  const AType: TClass): TObjectList<TObject>;
var
  LDoc: TJsonData;
  LItem: TObject;
  LFor: Integer;
begin
  LDoc.Init(AJson);
  if (LDoc.FVKind <> jtkArray) then
    Result := nil
  else
  begin
    Result := TObjectList<TObject>.Create;
    //Result.OwnsObjects := True;
    for LFor := 0 to LDoc.Count - 1 do
    begin
      LItem := AType.Create;
      if not JsonVariantData(LDoc.FValues[LFor]).ToObject(LItem) then
      begin
        FreeAndNil(Result);
        exit;
      end;
      Result.Add(LItem);
    end;
  end;
end;

function TJsonBrObject.JsonToObjectList<T>(const AJson: String): TObjectList<T>;
var
  LDoc: TJsonData;
  LItem: TObject;
  LFor: Integer;
begin
  LDoc.Init(AJson);
  if (LDoc.FVKind <> jtkArray) then
    Result := nil
  else
  begin
    Result := TObjectList<T>.Create;
    //Result.OwnsObjects := True;
    for LFor := 0 to LDoc.Count - 1 do
    begin
      LItem := T.Create;
      if not JsonVariantData(LDoc.FValues[LFor]).ToObject(LItem) then
      begin
        FreeAndNil(Result);
        exit;
      end;
      Result.Add(LItem);
    end;
  end;
end;

function TJsonBrObject.JsonToObject(AObject: TObject; const AJson: String): Boolean;
var
  LDoc: TJsonData;
begin
  if AObject = nil then
    Result := False
  else
  begin
    LDoc.Init(AJson);
    Result := LDoc.ToObject(AObject);
  end;
end;

function TJsonBrObject.JsonToObject<T>(const AJson: String): T;
begin
  Result := T.Create;
  if not JsonToObject(TObject(Result), AJson) then
    raise Exception.Create('Error JSON to Object');
end;

function TJsonBrObject.ObjectToJson(const AObject: TObject;
  const AStoreClassName: Boolean = False): String;
var
  FContext: TRttiContext;
  LTypeInfo: TRttiType;
  LProperty: TRttiProperty;
  {$IFDEF DELPHI15_UP}
  LMethodToArray: TRttiMethod;
  {$ENDIF DELPHI15_UP}
  LFor: Integer;
  LValue: TValue;
  LStringBuilder: TStringBuilder;
  LResultBuilder: TStringBuilder;
begin
  LValue := nil;
  if AObject = nil then
  begin
    Result := 'null';
    exit;
  end;
  if AObject is TList then
  begin
    if TList(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      LStringBuilder := TStringBuilder.Create;
      try
        LStringBuilder.Append('[');
        for LFor := 0 to TList(AObject).Count - 1 do
        begin
          LStringBuilder.Append(ObjectToJson(TList(AObject).List[LFor],
                                AStoreClassName));
          if LFor < TList(AObject).Count - 1 then
            LStringBuilder.Append(', ');
        end;
        LStringBuilder.Append(']');
        Result := LStringBuilder.ToString;
      finally
        LStringBuilder.Free;
      end;
    end;
    exit;
  end;
  if AObject is TStrings then
  begin
    if TStrings(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      LStringBuilder := TStringBuilder.Create;
      try
        LStringBuilder.Append('[');
        for LFor := 0 to TStrings(AObject).Count - 1 do
        begin
          LStringBuilder.Append(StringToJson(TStrings(AObject).Strings[LFor]));
          if LFor < TStrings(AObject).Count - 1 then
            LStringBuilder.Append(', ');
        end;
        LStringBuilder.Append(']');
        Result := LStringBuilder.ToString;
      finally
        LStringBuilder.Free;
      end;
    end;
    exit;
  end;
  if AObject is TCollection then
  begin
    if TCollection(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      LStringBuilder := TStringBuilder.Create;
      try
        LStringBuilder.Append('[');
        for LFor := 0 to TCollection(AObject).Count - 1 do
        begin
          LStringBuilder.Append(ObjectToJson(TCollection(AObject).Items[LFor], AStoreClassName));
          if LFor < TCollection(AObject).Count - 1 then
            LStringBuilder.Append(', ');
        end;
        LStringBuilder.Append(']');
        Result := LStringBuilder.ToString;
      finally
        LStringBuilder.Free;
      end;
    end;
    exit;
  end;
  LTypeInfo := FContext.GetType(AObject.ClassType);
  if LTypeInfo = nil then
  begin
    Result := 'null';
    exit;
  end;
  if (Pos('TObjectList<', AObject.ClassName) > 0) or
     (Pos('TList<', AObject.ClassName) > 0) then
  begin
    {$IFDEF DELPHI15_UP}
    LMethodToArray := LTypeInfo.GetMethod('ToArray');
    if LMethodToArray <> nil then
    begin
      LValue := LMethodToArray.Invoke(AObject, []);
      Assert(LValue.IsArray);
      if LValue.GetArrayLength = 0 then
        Result := '[]'
      else
      begin
        LStringBuilder := TStringBuilder.Create;
        try
          LStringBuilder.Append('[');
          for LFor := 0 to LValue.GetArrayLength - 1 do
          begin
            LStringBuilder.Append(ObjectToJson(LValue.GetArrayElement(LFor).AsObject, AStoreClassName));
            if Lfor < LValue.GetArrayLength - 1 then
              LStringBuilder.Append(', ');
          end;
          LStringBuilder.Append(']');
          Result := LStringBuilder.ToString;
        finally
          LStringBuilder.Free;
        end;
      end;
      exit;
    end;
    {$ELSE DELPHI15_UP}
    if TList(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      LStringBuilder := TStringBuilder.Create;
      try
        LStringBuilder.Append('[');
        for LFor := 0 to TList(AObject).Count - 1 do
        begin
          LStringBuilder.Append(ObjectToJson(TList(AObject).Items[LFor], AStoreClassName));
          if Lfor < TList(AObject).Count - 1 then
            LStringBuilder.Append(', ');
        end;
        LStringBuilder.Append(']');
        Result := LStringBuilder.ToString;
      finally
        LStringBuilder.Free;
      end;
    end;
    exit;
    {$ENDIF DELPHI15_UP}
  end;
  LResultBuilder := TStringBuilder.Create;
  try
    if AStoreClassName then
      LResultBuilder.Append('{"ClassName":"' + AObject.ClassName + '",')
    else
      LResultBuilder.Append('{');

    for LProperty in LTypeInfo.GetProperties do
    begin
      if not LProperty.IsWritable then
        continue;
      if LProperty.PropertyType.TypeKind in [tkArray, tkDynArray] then
        LResultBuilder.Append(StringToJson(LProperty.Name))
                      .Append(':')
                      .Append(VarToStr(GetInstanceProp(AObject, LProperty)))
                      .Append(',')
      else
        LResultBuilder.Append(StringToJson(LProperty.Name))
                      .Append(':')
                      .Append(ValueToJson(GetInstanceProp(AObject, LProperty)))
                      .Append(',');
    end;
    LResultBuilder.ReplaceLastChar('}');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

class function TJsonBrObject.ResolveValueArrayString(const AValue: Variant): TArray<String>;
var
  LSplitList: TStringList;
  LValue: Variant;
  LFor: Integer;
begin
  LValue := AValue;
  LSplitList := TStringList.Create;
  try
    ExtractStrings([','], [' '], PChar(String(LValue)), LSplitList);
    SetLength(Result, LSplitList.Count);
    for LFor := 0 to LSplitList.Count -1 do
      Result[LFor] := LSplitList[LFor];
  finally
    LSplitList.Free;
  end;
end;

class function TJsonBrObject.ResolveValueArrayCurrency(const AValue: Variant): TArray<currency>;
var
  LSplitList: TStringList;
  LValue: Variant;
  LFor: Integer;
begin
  LValue := AValue;
  LSplitList := TStringList.Create;
  try
    ExtractStrings([','], [' '], PChar(String(LValue)), LSplitList);
    SetLength(Result, LSplitList.Count);
    for LFor := 0 to LSplitList.Count -1 do
      Result[LFor] := StrToCurr(LSplitList[LFor], JsonBrFormatSettings);
  finally
    LSplitList.Free;
  end;
end;

class function TJsonBrObject.ResolveValueArrayDouble(const AValue: Variant): TArray<double>;
var
  LSplitList: TStringList;
  LValue: Variant;
  LFor: Integer;
begin
  LValue := AValue;
  LSplitList := TStringList.Create;
  try
    ExtractStrings([','], [' '], PChar(String(LValue)), LSplitList);
    SetLength(Result, LSplitList.Count);
    for LFor := 0 to LSplitList.Count -1 do
      Result[LFor] := StrToFloat(LSplitList[LFor], JsonBrFormatSettings);
  finally
    LSplitList.Free;
  end;
end;

class function TJsonBrObject.ResolveValueArrayInt64(const AValue: Variant): TArray<int64>;
var
  LSplitList: TStringList;
  LValue: Variant;
  LFor: Integer;
begin
  LValue := AValue;
  LSplitList := TStringList.Create;
  try
    ExtractStrings([','], [' '], PChar(String(LValue)), LSplitList);
    SetLength(Result, LSplitList.Count);
    for LFor := 0 to LSplitList.Count -1 do
      Result[LFor] := StrToInt64(LSplitList[LFor]);
  finally
    LSplitList.Free;
  end;
end;

class function TJsonBrObject.ResolveValueArrayInteger(const AValue: Variant): TArray<Integer>;
var
  LSplitList: TStringList;
  LValue: Variant;
  LFor: Integer;
begin
  LValue := AValue;
  LSplitList := TStringList.Create;
  try
    ExtractStrings([','], [' '], PChar(String(LValue)), LSplitList);
    SetLength(Result, LSplitList.Count);
    for LFor := 0 to LSplitList.Count -1 do
      Result[LFor] := StrToInt(LSplitList[LFor]);
  finally
    LSplitList.Free;
  end;
end;

{ TJsonParser }

procedure TJsonData.TJsonParser.Init(const AJson: String; AIndex: Integer);
begin
  FJson := AJson;
  FJsonLength := Length(FJson);
  FIndex := AIndex;
end;

function TJsonData.TJsonParser.GetNextChar: Char;
begin
  Result := #0;
  if FIndex <= FJsonLength then
  begin
    Result := Char(FJson[FIndex]);
    Inc(FIndex);
  end;
end;

function TJsonData.TJsonParser.GetNextNonWhiteChar: Char;
begin
  Result := #0;
  if FIndex <= FJsonLength then
  begin
    repeat
      if FJson[FIndex] > ' ' then
      begin
        Result := Char(FJson[FIndex]);
        Inc(FIndex);
        exit;
      end;
      Inc(FIndex);
    until FIndex > FJsonLength;
  end;
end;

function TJsonData.TJsonParser.CheckNextNonWhiteChar(AChar: Char): Boolean;
begin
  Result := False;
  if FIndex <= FJsonLength then
  begin
    repeat
      if FJson[FIndex] > ' ' then
      begin
        Result := FJson[FIndex] = AChar;
        if Result then
          Inc(FIndex);
        exit;
      end;
      Inc(FIndex);
    until FIndex > FJsonLength;
  end;
end;

procedure TJsonData.TJsonParser.GetNextStringUnEscape(var AStr: String);
var
  LChar: Char;
  LCopy: String;
  LUnicode, LErr: Integer;
  LStringBuilder: TStringBuilder;
begin
  LStringBuilder := TStringBuilder.Create;
  try
    LStringBuilder.Append(AStr);
    repeat
      LChar := GetNextChar;
      case LChar of
        #0:  exit;
        '"': break;
        '\': begin
             LChar := GetNextChar;
             case LChar of
               #0 : exit;
               'b': LStringBuilder.Append(#08);
               't': LStringBuilder.Append(#09);
               'n': LStringBuilder.Append(#$0a);
               'f': LStringBuilder.Append(#$0c);
               'r': LStringBuilder.Append(#$0d);
               'u':
               begin
                 LCopy := Copy(FJson, FIndex, 4);
                 if Length(LCopy) <> 4 then
                   exit;
                 Inc(FIndex, 4);
                 Val('$' + LCopy, LUnicode, LErr);
                 if LErr <> 0 then
                   exit;
                 LStringBuilder.Append(Char(LUnicode));
               end;
             else
               LStringBuilder.Append(LChar);
             end;
           end;
      else
        LStringBuilder.Append(LChar);
      end;
    until False;
    AStr := LStringBuilder.ToString;
  finally
    LStringBuilder.Free;
  end;
end;

function TJsonData.TJsonParser.GetNextString(out AStr: String): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  for LFor := FIndex to FJsonLength do
  begin
    case FJson[LFor] of
      '"': begin // end of String without escape -> direct copy
             AStr := Copy(FJson, FIndex, LFor - FIndex);
             FIndex := LFor + 1;
             Result := True;
             exit;
           end;
      '\': begin // need unescaping
             AStr := Copy(FJson, FIndex, LFor - FIndex);
             FIndex := LFor;
             GetNextStringUnEscape(AStr);
             Result := True;
             exit;
           end;
    end;
  end;
end;

function TJsonData.TJsonParser.GetNextAlphaPropName(out AFieldName: String): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  if (FIndex >= FJsonLength) or not (Ord(FJson[FIndex]) in [Ord('A') .. Ord('Z'),
                                                            Ord('a') .. Ord('z'),
                                                            Ord('_'),
                                                            Ord('$')]) then
    exit;
  for LFor := FIndex + 1 to FJsonLength do
    case Ord(FJson[LFor]) of
         Ord('0') .. Ord('9'),
         Ord('A') .. Ord('Z'),
         Ord('a') .. Ord('z'),
         Ord('_'):;
         Ord(':'),
         Ord('='):
      begin
        AFieldName := Copy(FJson, FIndex, LFor - FIndex);
        FIndex := LFor + 1;
        Result := True;
        exit;
      end;
    else
      exit;
    end;
end;

function TJsonData.TJsonParser.GetNextJson(out AValue: Variant): TJsonValueKind;
var
  LStr: String;
  LInt64: int64;
  LValue: double;
  LStart, LErr: Integer;
begin
  Result := jvkNone;
  case GetNextNonWhiteChar of
    'n': if Copy(FJson, FIndex, 3) = 'ull' then
         begin
           Inc(FIndex, 3);
           Result := jvkNull;
           AValue := Null;
         end;
    'f': if Copy(FJson, FIndex, 4) = 'alse' then
         begin
           Inc(FIndex, 4);
           Result := jvkBoolean;
           AValue := False;
         end;
    't': if Copy(FJson, FIndex, 3) = 'rue' then
         begin
           Inc(FIndex, 3);
           Result := jvkBoolean;
           AValue := True;
         end;
    '"': if GetNextString(LStr) then
         begin
           Result := jvkString;
           AValue := LStr;
         end;
    '{': if ParseJsonObject(TJsonData(AValue)) then
           Result := jvkObject;
    '[': if ParseJsonArray(TJsonData(AValue)) then
           Result := jvkArray;
    '-', '0' .. '9':
         begin
           LStart := FIndex - 1;
           while True do
             case FJson[FIndex] of
               '-', '+', '0' .. '9', '.', 'E', 'e':
                 Inc(FIndex);
             else
               break;
             end;
           LStr := Copy(FJson, LStart, FIndex - LStart);
           Val(LStr, LInt64, LErr);
           if LErr = 0 then
           begin
             Result := jvkInteger;
             AValue := LInt64;
           end
           else
           begin
             Val(LStr, LValue, LErr);
             if LErr <> 0 then
               exit;
             AValue := LValue;
             Result := jvkFloat;
           end;
         end;
  end;
end;

function TJsonData.TJsonParser.ParseJsonArray(out AData: TJsonData): Boolean;
var
  LItem: Variant;
begin
  Result := False;
  AData.Init;
  if not CheckNextNonWhiteChar(']') then
  begin
    repeat
      if GetNextJson(LItem) = jvkNone then
        exit;
      AData.AddValue(LItem);
      case GetNextNonWhiteChar of
        ',': continue;
        ']': break;
      else
        exit;
      end;
    until False;
    SetLength(AData.FValues, AData.FVCount);
  end;
  AData.FVKind := jtkArray;
  Result := True;
end;

function TJsonData.TJsonParser.ParseJsonObject(out AData: TJsonData): Boolean;
var
  LKey: String;
  LItem: Variant;
begin
  Result := False;
  AData.Init;
  if not CheckNextNonWhiteChar('}') then
  begin
    repeat
      if CheckNextNonWhiteChar('"') then
      begin
        if (not GetNextString(LKey)) or (GetNextNonWhiteChar <> ':') then
          exit;
      end
      else
      if not GetNextAlphaPropName(LKey) then
        exit;
      if GetNextJson(LItem) = jvkNone then
        exit;
      AData.AddNameValue(LKey, LItem);
      case GetNextNonWhiteChar of
        ',': continue;
        '}': break;
      else
        exit;
      end;
    until False;
    SetLength(AData.FNames, AData.FVCount);
  end;
  SetLength(AData.FValues, AData.FVCount);
  AData.FVKind := jtkObject;
  Result := True;
end;

{ TJSONBrVariantData }

procedure TJsonData.Init;
begin
  FVType := JsonVariantType.VarType;
  FVKind := jtkUndefined;
  FVCount := 0;
  Finalize(FNames);
  Finalize(FValues);
  pointer(FNames) := nil;
  pointer(FValues) := nil;
end;

procedure TJsonData.Init(const AJson: String);
begin
  Init;
  FromJson(AJson);
  if FVType = varNull then
    FVKind := jtkObject
  else
  if FVType <> JsonVariantType.VarType then
    Init;
end;

procedure TJsonData.InitFrom(const AValues: TDynamicArrayValue);
begin
  Init;
  FVKind := jtkArray;
  FValues := AValues;
  FVCount := Length(AValues);
end;

procedure TJsonData.Clear;
begin
  FNames := nil;
  FValues := nil;
  Init;
end;

procedure TJsonData.AddNameValue(const AName: String;
  const AValue: Variant);
begin
  if FVKind = jtkUndefined then
    FVKind := jtkObject
  else
  if FVKind <> jtkObject then
    raise EJsonBrException.CreateFmt('AddNameValue(%s) over array', [AName]);
  if FVCount <= Length(FValues) then
  begin
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
    SetLength(FNames, FVCount + FVCount shr 3 + 32);
  end;
  FValues[FVCount] := AValue;
  FNames[FVCount] := AName;
  Inc(FVCount);
end;

procedure TJsonData.AddValue(const AValue: Variant);
begin
  if FVKind = jtkUndefined then
    FVKind := jtkArray
  else
  if FVKind <> jtkArray then
    raise EJsonBrException.Create('AddValue() over object');
  if FVCount <= Length(FValues) then
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
  FValues[FVCount] := AValue;
  Inc(FVCount);
end;

function TJsonData.FromJson(const AJson: String): Boolean;
var
  LParser: TJsonParser;
begin
  LParser.Init(AJson, {$IFDEF NEXTGEN}2{$ELSE}1{$ENDIF});
  Result := LParser.GetNextJson(Variant(Self)) in [jvkObject, jvkArray];
end;

function TJsonData.GetKind: TJsonTypeKind;
begin
  if (@Self = nil) or (FVType <> JsonVariantType.VarType) then
    Result := jtkUndefined
  else
    Result := FVKind;
end;

function TJsonData.GetCount: Integer;
begin
  if (@Self = nil) or (FVType <> JsonVariantType.VarType) then
    Result := 0
  else
    Result := FVCount;
end;

function TJsonData.GetDataType: TJsonValueKind;
begin
  case VarType(FVType) of
    varEmpty, varNull: Result := jvkNull;
    varBoolean: Result := jvkBoolean;
    varString, varUString, varOleStr: Result := jvkString;
    varInteger, varSmallint, varShortint, varByte, varWord, varLongWord, varInt64: Result := jvkInteger;
    varSingle, varDouble, varCurrency, varDate: Result := jvkFloat;
    varDispatch: Result := jvkObject;
    varUnknown, varError: Result := jvkNone;
    varVariant: Result := jvkNone;
    varArray: Result := jvkArray;
  else
    Result := jvkNone;
  end;
end;

function TJsonData.GetValue(const AName: String): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkObject) then
    GetVarData(AName, TVarData(Result));
end;

function TJsonData.GetValueCopy(const AName: String): Variant;
var
  LFor: Cardinal;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkObject) then
  begin
    LFor := Cardinal(NameIndex(AName));
    if LFor < Cardinal(Length(FValues)) then
      Result := FValues[LFor];
  end;
end;

function TJsonData.GetItem(AIndex: Integer): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      Result := FValues[AIndex];
end;

procedure TJsonData.SetItem(AIndex: Integer; const AItem: Variant);
begin
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FVKind = jtkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      FValues[AIndex] := AItem;
end;

procedure TJsonData.SetKind(const Value: TJsonTypeKind);
begin
  FVKind := Value;
end;

function TJsonData.GetVarData(const AName: String; var ADest: TVarData): Boolean;
var
  LFor: Cardinal;
begin
  LFor := Cardinal(NameIndex(AName));
  if LFor < Cardinal(Length(FValues)) then
  begin
    ADest.VType := varVariant or varByRef;
    ADest.VPointer := @FValues[LFor];
    Result := True;
  end
  else
    Result := False;
end;

function TJsonData.NameIndex(const AName: String): Integer;
begin
  if (@Self <> nil) and (FVType = JsonVariantType.VarType) and (FNames <> nil) then
    for Result := 0 to FVCount - 1 do
      if FNames[Result] = AName then
        exit;
  Result := -1;
end;

function TJsonData.Names: TDynamicArrayKey;
begin
  Result := FNames;
end;

procedure TJsonData.SetValue(const AName: String; const AValue: Variant);
var
  LFor: Integer;
begin
  if @Self = nil then
    raise EJsonBrException.Create('Unexpected Value[] access');
  if AName = '' then
    raise EJsonBrException.Create('Unexpected Value['''']');
  LFor := NameIndex(AName);
  if LFor < 0 then
    AddNameValue(AName, AValue)
  else
    FValues[LFor] := String(AValue);
end;

function TJsonData.ToJson: String;
var
  LFor: Integer;
  LBuilder: TStringBuilder;
begin
  LBuilder := TStringBuilder.Create;
  try
    case FVKind of
      jtkObject:
        if FVCount = 0 then
          Result := '{}'
        else
        begin
          LBuilder.Append('{');
          for LFor := 0 to FVCount - 1 do
          begin
            LBuilder.Append(TJsonBrObject.StringToJson(FNames[LFor]))
                          .Append(':')
                          .Append(TJsonBrObject.ValueToJson(FValues[LFor]));
            if LFor < FVCount - 1 then
              LBuilder.Append(', ');
          end;
          LBuilder.Append('}');
          Result := LBuilder.ToString;
        end;
      jtkArray:
        if FVCount = 0 then
          Result := '[]'
        else
        begin
          LBuilder.Append('[');
          for LFor := 0 to FVCount - 1 do
          begin
            LBuilder.Append(TJsonBrObject.ValueToJson(FValues[LFor]));
            if LFor < FVCount - 1 then
              LBuilder.Append(', ');
          end;
          LBuilder.Append(']');
          Result := LBuilder.ToString;
        end;
    else
      Result := 'null';
    end;
  finally
    LBuilder.Free;
  end;
end;

function TJsonData.ToObject(AObject: TObject): Boolean;
var
  LFor: Integer;
  FContext: TRttiContext;
  LItem: TCollectionItem;
  LListType: TRttiType;
  LProperty: TRttiProperty;
  LObjectType: TObject;

  function MethodCall(const AObject: TObject; const AMethodName: String;
    const AParameters: array of TValue): TValue;
  var
    LRttiType: TRttiType;
    LMethod: TRttiMethod;
  begin
    LRttiType := FContext.GetType(AObject.ClassType);
    LMethod   := LRttiType.GetMethod(AMethodName);
    if Assigned(LMethod) then
       Result := LMethod.Invoke(AObject, AParameters)
    else
       raise Exception.CreateFmt('Cannot find method "%s" in the object', [AMethodName]);
  end;

begin
  Result := False;
  if AObject = nil then
    exit;
  case FVKind of
    jtkObject:
      begin
        LListType := FContext.GetType(AObject.ClassType);
        if LListType <> nil then
        begin
          for LFor := 0 to Count - 1 do
          begin
            LProperty := LListType.GetProperty(FNames[LFor]);
            if LProperty <> nil then
              TJsonBrObject.SetInstanceProp(AObject, LProperty, FValues[LFor]);
          end;
        end;
      end;
    jtkArray:
      if AObject.InheritsFrom(TCollection) then
      begin
        TCollection(AObject).Clear;
        for LFor := 0 to Count - 1 do
        begin
          LItem := TCollection(AObject).Add;
          if not TJsonBrObject.JsonVariantData(FValues[LFor]).ToObject(LItem) then
            exit;
        end;
      end
      else
      if AObject.InheritsFrom(TStrings) then
        try
          TStrings(AObject).BeginUpdate;
          TStrings(AObject).Clear;
          for LFor := 0 to Count - 1 do
            TStrings(AObject).Add(FValues[LFor]);
        finally
          TStrings(AObject).EndUpdate;
        end
      else
      if (Pos('TObjectList<', AObject.ClassName) > 0) or
         (Pos('TList<', AObject.ClassName) > 0) then
      begin
        LListType := FContext.GetType(AObject.ClassType);
        LListType := GetListType(LListType);
        if LListType.IsInstance then
        begin
          for LFor := 0 to Count - 1 do
          begin
            LObjectType := LListType.AsInstance.MetaclassType.Create;
            MethodCall(LObjectType, 'Create', []);
            if not TJsonBrObject.JsonVariantData(FValues[LFor]).ToObject(LObjectType) then
              exit;
            MethodCall(AObject, 'Add', [LObjectType]);
          end;
        end;
      end
      else
        exit;
  else
    exit;
  end;
  Result := True;
end;

function TJsonData.Values: TDynamicArrayValue;
begin
  Result := FValues;
end;

function TJsonData.GetListType(LRttiType: TRttiType): TRttiType;
var
  LTypeName: String;
  LContext: TRttiContext;
begin
   LContext := TRttiContext.Create;
   try
     LTypeName := LRttiType.ToString;
     LTypeName := StringReplace(LTypeName,'TObjectList<','',[]);
     LTypeName := StringReplace(LTypeName,'TList<','',[]);
     LTypeName := StringReplace(LTypeName,'>','',[]);
     //
     Result := LContext.FindType(LTypeName);
   finally
     LContext.Free;
   end;
end;

{ TJsonVariant }

procedure TJsonVariant.Cast(var ADest: TVarData; const ASource: TVarData);
begin
  CastTo(ADest, ASource, VarType);
end;

procedure TJsonVariant.CastTo(var ADest: TVarData; const ASource: TVarData;
  const AVarType: TVarType);
begin
  if ASource.VType <> VarType then
    RaiseCastError;
  Variant(ADest) := TJsonData(ASource).ToJson;
end;

procedure TJsonVariant.Clear(var AVarData: TVarData);
begin
  AVarData.VType := varEmpty;
  Finalize(TJsonData(AVarData).FNames);
  Finalize(TJsonData(AVarData).FValues);
end;

procedure TJsonVariant.Copy(var ADest: TVarData; const ASource: TVarData;
  const AIndirect: Boolean);
begin
  if AIndirect then
    SimplisticCopy(ADest, ASource, True)
  else
  begin
    VarClear(Variant(ADest));
    TJsonData(ADest).Init;
    TJsonData(ADest) := TJsonData(ASource);
  end;
end;

function TJsonVariant.GetProperty(var ADest: TVarData; const AVarData: TVarData;
  const AName: String): Boolean;
begin
  if not TJsonData(AVarData).GetVarData(AName, ADest) then
    ADest.VType := varNull;
  Result := True;
end;

function TJsonVariant.SetProperty(const AVarData: TVarData; const AName: String;
  const AValue: TVarData): Boolean;
begin
  TJsonData(AVarData).SetValue(AName, Variant(AValue));
  Result := True;
end;

procedure TStringBuilderHelper.ReplaceLastChar(const AChar: Char);
begin
  if Self.Length > 1 then
  begin
    if Self.Chars[Self.Length - 1] = ' ' then
      Self.Remove(Self.Length - 1, 1);
    Self.Chars[Self.Length - 1] := AChar;
  end;
end;

initialization
  JsonVariantType := TJsonVariant.Create;
  TJsonBrObject.UseISO8601DateFormat := True;

end.
