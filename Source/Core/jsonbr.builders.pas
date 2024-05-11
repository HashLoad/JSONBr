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
  Types,
  TypInfo,
  Classes,
  SysUtils,
  StrUtils,
  Variants,
  Generics.Collections,
  jsonbr.utils,
  jsonbr.types;

type
  TJsonBuilder = class;

  TJsonData = record
  private
    FVType: TVarType;
    FVKind: TJsonTypeKind;
    FVCount: Integer;
    FNames: TDynamicArrayKey;
    FValues: TDynamicArrayValue;
    procedure _SetKind(const Value: TJsonTypeKind);
    procedure _SetValue(const AName: String; const AValue: Variant);
    procedure _SetItem(AIndex: Integer; const AItem: Variant);
    function _GetKind: TJsonTypeKind;
    function _GetCount: Integer;
    function _GetVarData(const AName: String; var ADest: TVarData): Boolean;
    function _GetValueCopy(const AName: String): Variant;
    function _GetValue(const AName: String): Variant;
    function _GetItem(AIndex: Integer): Variant;
    function _GetListType(LRttiType: TRttiType): TRttiType;
    function _GetDataType: TJsonValueKind;
    type
      TJsonParser = record
      private
        FJson: String;
        FIndex: Integer;
        FJsonLength: Integer;
        function _GetNextChar: Char;
        function _GetNextNonWhiteChar: Char; inline;
        function _CheckNextNonWhiteChar(AChar: Char): Boolean; inline;
        function _GetNextString(out AStr: String): Boolean;
        function _GetNextJson(out AValue: Variant): TJsonValueKind;
        function _GetNextAlphaPropName(out AFieldName: String): Boolean;
        function _ParseJsonObject(out AData: TJsonData): Boolean;
        function _ParseJsonArray(out AData: TJsonData): Boolean;
        procedure _Init(const AJson: String; AIndex: Integer = 1);
        procedure _GetNextStringUnEscape(var AStr: String);
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
    property Kind: TJsonTypeKind read _GetKind write _SetKind;
    property DataType: TJsonValueKind read _GetDataType;
    property Count: Integer read _GetCount;
    property Value[const AName: String]: Variant read _GetValue write _SetValue; default;
    property ValueCopy[const AName: String]: Variant read _GetValueCopy;
    property Item[AIndex: Integer]: Variant read _GetItem write _SetItem;
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

  TJsonBuilder = class
  strict private
    class var FNotifyEventSetValue: TNotifyEventSetValue;
    class var FNotifyEventGetValue: TNotifyEventGetValue;
    class var FMiddlwareList: TList<IEventMiddleware>;
  strict private
    class function _ResolveValueArrayString(const AValue: Variant): TArray<String>; inline;
    class function _ResolveValueArrayInteger(const AValue: Variant): TArray<Integer>; inline;
    class function _ResolveValueArrayInt64(const AValue: Variant): TArray<int64>; inline;
    class function _ResolveValueArrayDouble(const AValue: Variant): TArray<double>; inline;
    class function _ResolveValueArrayCurrency(const AValue: Variant): TArray<currency>; inline;
    class function _IsBlob(const ATypeInfo: PTypeInfo): Boolean; inline;
    class function _GetValueArray(const ATypeInfo: PTypeInfo; const AValue: Variant): TValue; inline;
  private
    function _GetInstanceProp(AInstance: TObject; AProperty: TRttiProperty): Variant;
    class procedure _SetInstanceProp(const AInstance: TObject; const AProperty: TRttiProperty; const AValue: Variant);
    class function _JsonVariantData(const AValue: Variant): TJsonData; inline;
  public
    class var UseISO8601DateFormat: Boolean;
  public
    class constructor Create;
    class destructor Destroy;
    procedure AddMiddleware(const AEventMiddleware: IEventMiddleware);
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
  GJsonVariantType: TInvokeableVariantType;

implementation

{ TJsonBrObject }

function TJsonBuilder.JsonVariant(const AJson: String): Variant;
begin
  VarClear(Result);
  TJsonData(Result).FromJson(AJson);
end;

function TJsonBuilder.JsonVariant(const AValues: TDynamicArrayValue): Variant;
begin
  VarClear(Result);
  TJsonData(Result).Init;
  TJsonData(Result).FVKind := TJsonTypeKind.jtkArray;
  TJsonData(Result).FVCount := Length(AValues);
  TJsonData(Result).FValues := AValues;
end;

class function TJsonBuilder._JsonVariantData(const AValue: Variant): TJsonData;
var
  LVarData: TVarData;
begin
  LVarData := TVarData(AValue);
  if LVarData.VType = GJsonVariantType.VarType then
    Result := TJsonData(AValue)
  else
  if LVarData.VType = varByRef or varVariant then
    Result := TJsonData(PVariant(LVarData.VPointer)^)
  else
    raise EJsonBrException.CreateFmt('JSONBrVariantData.Data(%d<>JSONVariant)', [LVarData.VType]);
end;

class function TJsonBuilder.StringToJson(const AText: String): String;
var
  LLen, LFor: Integer;

  procedure L_DoEscape;
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
//     '[', ']': Continue;
//    end;
    case AText[LFor] of
      #0 .. #31, '\', '"':
      begin
        L_DoEscape;
        Exit;
      end;
    end;
  Result := '"' + AText + '"';
end;

class function TJsonBuilder.ValueToJson(const AValue: Variant): String;
var
  LDouble: Double;
begin
  if TVarData(AValue).VType = GJsonVariantType.VarType then
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
        Result := FloatToStr(LDouble, GJsonBrFormatSettings)
      end
      else
      if VarIsStr(AValue) then
        Result :=  StringToJson(VarToStr(AValue))
      else
        Result := VarToStr(AValue);
    end;
  end;
end;

function TJsonBuilder._GetInstanceProp(AInstance: TObject;
  AProperty: TRttiProperty): Variant;
var
  LObject: TObject;
  LTypeInfo: PTypeInfo;
  LBreak: Boolean;
  LMiddleware: IEventMiddleware;

  function L_IsBoolean: Boolean;
  var
    LTypeName: String;
  begin
    LTypeName := AProperty.PropertyType.Handle.NameFld.ToString;
    Result := SameText(LTypeName, 'Boolean') or SameText(LTypeName, 'bool');
  end;

begin
  VarClear(Result);
  // Notify Event - deprecated
  if Assigned(FNotifyEventGetValue) then
  begin
    LBreak := False;
    FNotifyEventGetValue(AInstance, AProperty, Result, LBreak);
    if LBreak then
      Exit;
  end;

  // Middlewares GetValue
  LBreak := False;
  for LMiddleware in FMiddlwareList do
  begin
    LMiddleware.GetValue(AInstance, AProperty, Result, LBreak);
    if LBreak then
      Exit;
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
              Result := StrToFloat(AProperty.GetValue(AInstance).AsString, GJsonBrFormatSettings);
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
          if L_IsBoolean() then
            Result := AProperty.GetValue(AInstance).AsBoolean
          else
            Result := GetEnumValue(LTypeInfo, AProperty.GetValue(AInstance).AsString) >= 0;
        end;
      tkArray, tkDynArray:
        begin
          if _IsBlob(LTypeInfo) then
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

class function TJsonBuilder._GetValueArray(const ATypeInfo: PTypeInfo;
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
    Result := TValue.From(_ResolveValueArrayString(LValue))
  else if EndsText('<System.Integer>', String(ATypeInfo.Name)) then
    Result := TValue.From(_ResolveValueArrayInteger(LValue))
  else if EndsText('<System.Int64>', String(ATypeInfo.Name)) then
    Result := TValue.From(_ResolveValueArrayInt64(LValue))
  else if EndsText('<System.Double>', String(ATypeInfo.Name)) then
    Result := TValue.From(_ResolveValueArrayDouble(LValue))
  else if EndsText('<System.Currency>', String(ATypeInfo.Name)) then
    Result := TValue.From(_ResolveValueArrayCurrency(LValue));
end;

class procedure TJsonBuilder._SetInstanceProp(const AInstance: TObject;
  const AProperty: TRttiProperty; const AValue: Variant);
var
  LBreak: Boolean;
  LTypeInfo: PTypeInfo;
  LObject: TObject;
  LMiddleware: IEventMiddleware;
  LValue: Variant;

  function L_IsBoolean: Boolean;
  var
    LTypeName: String;
  begin
    LTypeName := AProperty.PropertyType.Handle.NameFld.ToString;
    Result := SameText(LTypeName, 'Boolean') or SameText(LTypeName, 'bool');
  end;

begin
  if (AProperty = nil) and (AInstance = nil) then
    Exit;

  LValue := AValue;
  // Notify Event - deprecated
  LBreak := False;
  if Assigned(FNotifyEventSetValue) then
  begin
    FNotifyEventSetValue(AInstance, AProperty, LValue, LBreak);
    if LBreak then
      Exit;
  end;

  // Middlewares SetValue
  for LMiddleware in FMiddlwareList do
  begin
    LBreak := False;
    LMiddleware.SetValue(AInstance, AProperty, LValue, LBreak);
    if LBreak then
      Exit;
  end;

  LTypeInfo := AProperty.PropertyType.Handle;
  try
    case AProperty.PropertyType.TypeKind of
      tkString, tkWString, tkUString, tkWChar, tkLString, tkChar:
        if TVarData(LValue).VType <= varNull then
          AProperty.SetValue(AInstance, TValue.From<String>(''))
        else
          AProperty.SetValue(AInstance, TValue.From<String>(LValue));
      tkInteger, tkSet, tkInt64:
        AProperty.SetValue(AInstance, TValue.From<Integer>(LValue));
      tkFloat:
        if TVarData(LValue).VType <= varNull then
          AProperty.SetValue(AInstance, TValue.From<Double>(0.0))
        else
        if (LTypeInfo = TypeInfo(TDateTime)) or (LTypeInfo = TypeInfo(TDate)) or
           (LTypeInfo = TypeInfo(TTime)) then
          AProperty.SetValue(AInstance, Iso8601ToDateTime(LValue, UseISO8601DateFormat))
        else
          AProperty.SetValue(AInstance, TValue.From<Double>(LValue));
      tkVariant:
        AProperty.SetValue(AInstance, TValue.FromVariant(LValue));
      tkRecord:
        AProperty.SetValue(AInstance, TValue.FromVariant(LValue));
      tkClass:
        begin
          LObject := AProperty.GetValue(AInstance).AsObject;
          if LObject <> nil then
            _JsonVariantData(LValue).ToObject(LObject);
        end;
      tkEnumeration:
        begin
          if L_IsBoolean() then
            AProperty.SetValue(AInstance, TValue.From<Boolean>(LValue))
          else
            AProperty.SetValue(AInstance, TValue.FromVariant(LValue));
        end;
      tkArray, tkDynArray:
        begin
          if _IsBlob(LTypeInfo) then

          else
            AProperty.SetValue(AInstance, _GetValueArray(LTypeInfo, LValue));
        end;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro no SetValue() da propriedade [' + AProperty.Name + ']' + sLineBreak + E.Message);
  end;
end;

procedure TJsonBuilder.AddMiddleware(
  const AEventMiddleware: IEventMiddleware);
begin
  FMiddlwareList.Add(AEventMiddleware);
end;

class constructor TJsonBuilder.Create;
begin
  FMiddlwareList := TList<IEventMiddleware>.Create;
end;

class destructor TJsonBuilder.Destroy;
begin
  FMiddlwareList.Free;
end;

function TJsonBuilder.DynArrayDoubleToJson(const AValue: TValue): String;
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

function TJsonBuilder.DynArrayIntegerToJson(const AValue: TValue): String;
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

function TJsonBuilder.DynArrayStringToJson(const AValue: TValue): String;
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

class function TJsonBuilder._IsBlob(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo = TypeInfo(TByteDynArray)) and
            (PropWrap(ATypeInfo).Kind = $FF);
end;

function TJsonBuilder.JsonToObjectList(const AJson: String;
  const AType: TClass): TObjectList<TObject>;
var
  LData: TJsonData;
  LItem: TObject;
  LFor: Integer;
begin
  LData.Init(AJson);
  Result := nil;
  if (LData.FVKind <> TJsonTypeKind.jtkArray) then
    Exit;

  Result := TObjectList<TObject>.Create;
  //Result.OwnsObjects := True;
  for LFor := 0 to LData.Count - 1 do
  begin
    LItem := AType.Create;
    if not _JsonVariantData(LData.FValues[LFor]).ToObject(LItem) then
    begin
      Result.Free;
      Exit;
    end;
    Result.Add(LItem);
  end;
end;

function TJsonBuilder.JsonToObjectList<T>(const AJson: String): TObjectList<T>;
var
  LData: TJsonData;
  LItem: TObject;
  LFor: Integer;
begin
  LData.Init(AJson);
  Result := nil;
  if (LData.FVKind <> TJsonTypeKind.jtkArray) then
    Exit;

  Result := TObjectList<T>.Create;
  //Result.OwnsObjects := True;
  for LFor := 0 to LData.Count - 1 do
  begin
    LItem := T.Create;
    if not _JsonVariantData(LData.FValues[LFor]).ToObject(LItem) then
    begin
      Result.Free;
      Exit;
    end;
    Result.Add(LItem);
  end;
end;

function TJsonBuilder.JsonToObject(AObject: TObject; const AJson: String): Boolean;
var
  LData: TJsonData;
begin
  if AObject = nil then
    Result := False
  else
  begin
    LData.Init(AJson);
    Result := LData.ToObject(AObject);
  end;
end;

function TJsonBuilder.JsonToObject<T>(const AJson: String): T;
begin
  Result := T.Create;
  if not JsonToObject(TObject(Result), AJson) then
    raise Exception.Create('Error JSON to Object');
end;

function TJsonBuilder.ObjectToJson(const AObject: TObject;
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
    Exit;
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
    Exit;
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
    Exit;
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
    Exit;
  end;
  LTypeInfo := FContext.GetType(AObject.ClassType);
  if LTypeInfo = nil then
  begin
    Result := 'null';
    Exit;
  end;
  if Pos('List<', AObject.ClassName) > 0 then
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
      Exit;
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
    Exit;
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
        Continue;
      if LProperty.PropertyType.TypeKind in [tkArray, tkDynArray] then
        LResultBuilder.Append(StringToJson(LProperty.Name))
                      .Append(':')
                      .Append(VarToStr(_GetInstanceProp(AObject, LProperty)))
                      .Append(',')
      else
        LResultBuilder.Append(StringToJson(LProperty.Name))
                      .Append(':')
                      .Append(ValueToJson(_GetInstanceProp(AObject, LProperty)))
                      .Append(',');
    end;
    LResultBuilder.ReplaceLastChar('}');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

class function TJsonBuilder._ResolveValueArrayString(const AValue: Variant): TArray<String>;
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

class function TJsonBuilder._ResolveValueArrayCurrency(const AValue: Variant): TArray<currency>;
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
      Result[LFor] := StrToCurr(LSplitList[LFor], GJsonBrFormatSettings);
  finally
    LSplitList.Free;
  end;
end;

class function TJsonBuilder._ResolveValueArrayDouble(const AValue: Variant): TArray<double>;
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
      Result[LFor] := StrToFloat(LSplitList[LFor], GJsonBrFormatSettings);
  finally
    LSplitList.Free;
  end;
end;

class function TJsonBuilder._ResolveValueArrayInt64(const AValue: Variant): TArray<int64>;
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

class function TJsonBuilder._ResolveValueArrayInteger(const AValue: Variant): TArray<Integer>;
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

procedure TJsonData.TJsonParser._Init(const AJson: String; AIndex: Integer);
begin
  FJson := AJson;
  FJsonLength := Length(FJson);
  FIndex := AIndex;
end;

function TJsonData.TJsonParser._GetNextChar: Char;
begin
  Result := #0;
  if FIndex > FJsonLength then
    Exit;
  Result := Char(FJson[FIndex]);
  Inc(FIndex);
end;

function TJsonData.TJsonParser._GetNextNonWhiteChar: Char;
begin
  Result := #0;
  if FIndex > FJsonLength then
    Exit;
  repeat
    if FJson[FIndex] > ' ' then
    begin
      Result := Char(FJson[FIndex]);
      Inc(FIndex);
      Exit;
    end;
    Inc(FIndex);
  until FIndex > FJsonLength;
end;

function TJsonData.TJsonParser._CheckNextNonWhiteChar(AChar: Char): Boolean;
begin
  Result := False;
  if FIndex > FJsonLength then
    Exit;
  repeat
    if FJson[FIndex] > ' ' then
    begin
      Result := FJson[FIndex] = AChar;
      if Result then
        Inc(FIndex);
      Exit;
    end;
    Inc(FIndex);
  until FIndex > FJsonLength;
end;

procedure TJsonData.TJsonParser._GetNextStringUnEscape(var AStr: String);
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
      LChar := _GetNextChar;
      case LChar of
        #0:  Exit;
        '"': Break;
        '\': begin
             LChar := _GetNextChar;
             case LChar of
               #0 : Exit;
               'b': LStringBuilder.Append(#08);
               't': LStringBuilder.Append(#09);
               'n': LStringBuilder.Append(#$0a);
               'f': LStringBuilder.Append(#$0c);
               'r': LStringBuilder.Append(#$0d);
               'u':
               begin
                 LCopy := Copy(FJson, FIndex, 4);
                 if Length(LCopy) <> 4 then
                   Exit;
                 Inc(FIndex, 4);
                 Val('$' + LCopy, LUnicode, LErr);
                 if LErr <> 0 then
                   Exit;
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

function TJsonData.TJsonParser._GetNextString(out AStr: String): Boolean;
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
             Exit;
           end;
      '\': begin // need unescaping
             AStr := Copy(FJson, FIndex, LFor - FIndex);
             FIndex := LFor;
             _GetNextStringUnEscape(AStr);
             Result := True;
             Exit;
           end;
    end;
  end;
end;

function TJsonData.TJsonParser._GetNextAlphaPropName(out AFieldName: String): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  if (FIndex >= FJsonLength) or not (Ord(FJson[FIndex]) in [Ord('A') .. Ord('Z'),
                                                            Ord('a') .. Ord('z'),
                                                            Ord('_'),
                                                            Ord('$')]) then
    Exit;
  for LFor := FIndex + 1 to FJsonLength do
  begin
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
        Exit;
      end;
    else
      Exit;
    end;
  end;
end;

function TJsonData.TJsonParser._GetNextJson(out AValue: Variant): TJsonValueKind;
var
  LStr: String;
  LInt64: Int64;
  LValue: Double;
  LStart, LErr: Integer;
begin
  Result := TJsonValueKind.jvkNone;
  case _GetNextNonWhiteChar of
    'n': if Copy(FJson, FIndex, 3) = 'ull' then
         begin
           Inc(FIndex, 3);
           Result := TJsonValueKind.jvkNull;
           AValue := Null;
         end;
    'f': if Copy(FJson, FIndex, 4) = 'alse' then
         begin
           Inc(FIndex, 4);
           Result := TJsonValueKind.jvkBoolean;
           AValue := False;
         end;
    't': if Copy(FJson, FIndex, 3) = 'rue' then
         begin
           Inc(FIndex, 3);
           Result := TJsonValueKind.jvkBoolean;
           AValue := True;
         end;
    '"': if _GetNextString(LStr) then
         begin
           Result := TJsonValueKind.jvkString;
           AValue := LStr;
         end;
    '{': if _ParseJsonObject(TJsonData(AValue)) then
           Result := TJsonValueKind.jvkObject;
    '[': if _ParseJsonArray(TJsonData(AValue)) then
           Result := TJsonValueKind.jvkArray;
    '-', '0'..'9':
         begin
           LStart := FIndex - 1;
           while True do
           begin
             case FJson[FIndex] of
               '-', '+', '0' .. '9', '.', 'E', 'e':
                 Inc(FIndex);
             else
               Break;
             end;
           end;
           LStr := Copy(FJson, LStart, FIndex - LStart);
           Val(LStr, LInt64, LErr);
           if LErr = 0 then
           begin
             Result := TJsonValueKind.jvkInteger;
             AValue := LInt64;
           end
           else
           begin
             Val(LStr, LValue, LErr);
             if LErr <> 0 then
               Exit;
             AValue := LValue;
             Result := TJsonValueKind.jvkFloat;
           end;
         end;
  end;
end;

function TJsonData.TJsonParser._ParseJsonArray(out AData: TJsonData): Boolean;
var
  LItem: Variant;
begin
  Result := False;
  AData.Init;
  if not _CheckNextNonWhiteChar(']') then
  begin
    repeat
      if _GetNextJson(LItem) = TJsonValueKind.jvkNone then
        Exit;
      AData.AddValue(LItem);
      case _GetNextNonWhiteChar of
        ',': Continue;
        ']': Break;
      else
        Exit;
      end;
    until False;
    SetLength(AData.FValues, AData.FVCount);
  end;
  AData.FVKind := TJsonTypeKind.jtkArray;
  Result := True;
end;

function TJsonData.TJsonParser._ParseJsonObject(out AData: TJsonData): Boolean;
var
  LKey: String;
  LItem: Variant;
begin
  Result := False;
  AData.Init;
  if not _CheckNextNonWhiteChar('}') then
  begin
    repeat
      if _CheckNextNonWhiteChar('"') then
      begin
        if (not _GetNextString(LKey)) or (_GetNextNonWhiteChar <> ':') then
          Exit;
      end
      else
      if not _GetNextAlphaPropName(LKey) then
        Exit;
      if _GetNextJson(LItem) = TJsonValueKind.jvkNone then
        Exit;
      AData.AddNameValue(LKey, LItem);
      case _GetNextNonWhiteChar of
        ',': Continue;
        '}': Break;
      else
        Exit;
      end;
    until False;
    SetLength(AData.FNames, AData.FVCount);
  end;
  SetLength(AData.FValues, AData.FVCount);
  AData.FVKind := TJsonTypeKind.jtkObject;
  Result := True;
end;

{ TJSONBrVariantData }

procedure TJsonData.Init;
begin
  FVType := GJsonVariantType.VarType;
  FVKind := TJsonTypeKind.jtkUndefined;
  FVCount := 0;
  Finalize(FNames);
  Finalize(FValues);
  Pointer(FNames) := nil;
  Pointer(FValues) := nil;
end;

procedure TJsonData.Init(const AJson: String);
begin
  Init;
  FromJson(AJson);
  if FVType = varNull then
    FVKind := TJsonTypeKind.jtkObject
  else
  if FVType <> GJsonVariantType.VarType then
    Init;
end;

procedure TJsonData.InitFrom(const AValues: TDynamicArrayValue);
begin
  Init;
  FVKind := TJsonTypeKind.jtkArray;
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
  if FVKind = TJsonTypeKind.jtkUndefined then
    FVKind := TJsonTypeKind.jtkObject
  else
  if FVKind <> TJsonTypeKind.jtkObject then
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
  if FVKind = TJsonTypeKind.jtkUndefined then
    FVKind := TJsonTypeKind.jtkArray
  else
  if FVKind <> TJsonTypeKind.jtkArray then
    raise EJsonBrException.Create('AddValue() over object');
  if FVCount <= Length(FValues) then
  begin
    SetLength(FNames, FVCount + FVCount shr 3 + 32);
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
  end;
  FNames[FVCount] := IntToStr(FVCount);
  FValues[FVCount] := AValue;
  Inc(FVCount);
end;

function TJsonData.FromJson(const AJson: String): Boolean;
var
  LParser: TJsonParser;
begin
  LParser._Init(AJson, {$IFDEF NEXTGEN}2{$ELSE}1{$ENDIF});
  Result := LParser._GetNextJson(Variant(Self)) in [TJsonValueKind.jvkObject, TJsonValueKind.jvkArray];
end;

function TJsonData._GetKind: TJsonTypeKind;
begin
  Result := FVKind;
  if (@Self = nil) or (FVType <> GJsonVariantType.VarType) then
    Result := TJsonTypeKind.jtkUndefined
end;

function TJsonData._GetCount: Integer;
begin
  Result := FVCount;
  if (@Self = nil) or (FVType <> GJsonVariantType.VarType) then
    Result := 0
end;

function TJsonData._GetDataType: TJsonValueKind;
begin
  case VarType(FVType) of
    varEmpty, varNull: Result := TJsonValueKind.jvkNull;
    varBoolean: Result := TJsonValueKind.jvkBoolean;
    varString, varUString, varOleStr: Result := TJsonValueKind.jvkString;
    varInteger, varSmallint, varShortint,
    varByte, varWord, varLongWord, varInt64: Result := TJsonValueKind.jvkInteger;
    varSingle, varDouble, varCurrency, varDate: Result := TJsonValueKind.jvkFloat;
    varDispatch: Result := TJsonValueKind.jvkObject;
    varUnknown, varError: Result := TJsonValueKind.jvkNone;
    varVariant: Result := TJsonValueKind.jvkNone;
    varArray: Result := TJsonValueKind.jvkArray;
  else
    Result := TJsonValueKind.jvkNone;
  end;
end;

function TJsonData._GetValue(const AName: String): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = GJsonVariantType.VarType) and (FVKind = TJsonTypeKind.jtkObject) then
    _GetVarData(AName, TVarData(Result));
end;

function TJsonData._GetValueCopy(const AName: String): Variant;
var
  LFor: Cardinal;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = GJsonVariantType.VarType) and (FVKind = TJsonTypeKind.jtkObject) then
  begin
    LFor := Cardinal(NameIndex(AName));
    if LFor < Cardinal(Length(FValues)) then
      Result := FValues[LFor];
  end;
end;

function TJsonData._GetItem(AIndex: Integer): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = GJsonVariantType.VarType) and (FVKind = TJsonTypeKind.jtkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      Result := FValues[AIndex];
end;

procedure TJsonData._SetItem(AIndex: Integer; const AItem: Variant);
begin
  if (@Self <> nil) and (FVType = GJsonVariantType.VarType) and (FVKind = TJsonTypeKind.jtkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      FValues[AIndex] := AItem;
end;

procedure TJsonData._SetKind(const Value: TJsonTypeKind);
begin
  FVKind := Value;
end;

function TJsonData._GetVarData(const AName: String; var ADest: TVarData): Boolean;
var
  LFor: Cardinal;
begin
  Result := False;
  LFor := Cardinal(NameIndex(AName));
  if LFor > Cardinal(Length(FValues)) then
    Exit;
  ADest.VType := varVariant or varByRef;
  ADest.VPointer := @FValues[LFor];
  Result := True;
end;

function TJsonData.NameIndex(const AName: String): Integer;
begin
  if (@Self <> nil) and (FVType = GJsonVariantType.VarType) and (FNames <> nil) then
    for Result := 0 to FVCount - 1 do
      if FNames[Result] = AName then
        Exit;
  Result := -1;
end;

function TJsonData.Names: TDynamicArrayKey;
begin
  Result := FNames;
end;

procedure TJsonData._SetValue(const AName: String; const AValue: Variant);
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
      TJsonTypeKind.jtkObject:
        if FVCount = 0 then
          Result := '{}'
        else
        begin
          LBuilder.Append('{');
          for LFor := 0 to FVCount - 1 do
          begin
            LBuilder.Append(TJsonBuilder.StringToJson(FNames[LFor]))
                          .Append(':')
                          .Append(TJsonBuilder.ValueToJson(FValues[LFor]));
            if LFor < FVCount - 1 then
              LBuilder.Append(', ');
          end;
          LBuilder.Append('}');
          Result := LBuilder.ToString;
        end;
      TJsonTypeKind.jtkArray:
        if FVCount = 0 then
          Result := '[]'
        else
        begin
          LBuilder.Append('[');
          for LFor := 0 to FVCount - 1 do
          begin
            LBuilder.Append(TJsonBuilder.ValueToJson(FValues[LFor]));
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

  function L_MethodCall(const AObject: TObject; const AMethodName: String;
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
    Exit;
  case FVKind of
    TJsonTypeKind.jtkObject:
      begin
        LListType := FContext.GetType(AObject.ClassType);
        if LListType <> nil then
        begin
          for LFor := 0 to FVCount - 1 do
          begin
            LProperty := LListType.GetProperty(FNames[LFor]);
            if LProperty <> nil then
              TJsonBuilder._SetInstanceProp(AObject, LProperty, FValues[LFor]);
          end;
        end;
      end;
    TJsonTypeKind.jtkArray:
      begin
        if AObject.InheritsFrom(TCollection) then
        begin
          TCollection(AObject).Clear;
          for LFor := 0 to FVCount - 1 do
          begin
            LItem := TCollection(AObject).Add;
            if not TJsonBuilder._JsonVariantData(FValues[LFor]).ToObject(LItem) then
              Exit;
          end;
        end
        else
        if AObject.InheritsFrom(TStrings) then
        begin
          try
            TStrings(AObject).BeginUpdate;
            TStrings(AObject).Clear;
            for LFor := 0 to FVCount - 1 do
              TStrings(AObject).Add(FValues[LFor]);
          finally
            TStrings(AObject).EndUpdate;
          end
        end
        else
        if Pos('List<', AObject.ClassName) > 0 then
        begin
          LListType := FContext.GetType(AObject.ClassType);
          LListType := _GetListType(LListType);
          if LListType.IsInstance then
          begin
            for LFor := 0 to FVCount - 1 do
            begin
              LObjectType := LListType.AsInstance.MetaclassType.Create;
              L_MethodCall(LObjectType, 'Create', []);
              if not TJsonBuilder._JsonVariantData(FValues[LFor]).ToObject(LObjectType) then
                Exit;
              L_MethodCall(AObject, 'Add', [LObjectType]);
            end;
          end;
        end
        else
          Exit;
      end;
    else
      Exit;
  end;
  Result := True;
end;

function TJsonData.Values: TDynamicArrayValue;
begin
  Result := FValues;
end;

function TJsonData._GetListType(LRttiType: TRttiType): TRttiType;
var
  LTypeName: String;
  LContext: TRttiContext;
  LPosI: Int16;
  LPosF: Int16;
begin
  Result := nil;
  LContext := TRttiContext.Create;
  try
    LTypeName := LRttiType.ToString;
    LPosI := Pos('<', LTypeName);
    if LPosI < 0 then
      Exit;
    LPosF := PosEx('>', LTypeName, LPosI);
    if LPosF < 0 then
      Exit;
    LTypeName := Copy(LTypeName, LPosI + 1, LPosF - LPosI - 1);
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
  if not TJsonData(AVarData)._GetVarData(AName, ADest) then
    ADest.VType := varNull;
  Result := True;
end;

function TJsonVariant.SetProperty(const AVarData: TVarData; const AName: String;
  const AValue: TVarData): Boolean;
begin
  TJsonData(AVarData)._SetValue(AName, Variant(AValue));
  Result := True;
end;

initialization
  GJsonVariantType := TJsonVariant.Create;
  TJsonBuilder.UseISO8601DateFormat := True;

end.
