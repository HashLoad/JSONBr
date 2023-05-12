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

  TJSONBrObject = class;
  TNotifyEventGetValue = procedure(const AInstance: TObject;
								   const AProperty: TRttiProperty;
								   var AResult: Variant;
								   var ABreak: Boolean) of Object;
  TNotifyEventSetValue = procedure(const AInstance: TObject;
                                   const AProperty: TRttiProperty;
								   const AValue: Variant;
								   var ABreak: Boolean) of Object;
  EJSONBrException = class(Exception);
  TStringDynamicArray = array of String;
  TVariantDynamicArray = array of Variant;
  TJSONBrVariantKind = (vkUndefined, vkObject, vkArray);
  TJSONBrParserKind = (pkNone, pkNull, pkFalse, pkTrue, pkString,
                       pkInteger, pkFloat, pkObject, pkArray);
  PropWrap = packed record
    FillBytes: array [0..SizeOf(Pointer)-2] of Byte;
    Kind: Byte;
  end;

  TJSONBrVariantData = record
  private
    FVType: TVarType;
    FVKind: TJSONBrVariantKind;
    FVCount: Integer;
    function GetKind: TJSONBrVariantKind;
    procedure SetKind(const Value: TJSONBrVariantKind);
    function GetCount: Integer;
    function GetVarData(const AName: String; var ADest: TVarData): Boolean;
    function GetValueCopy(const AName: String): Variant;
    function GetValue(const AName: String): Variant;
    procedure SetValue(const AName: String; const AValue: Variant);
    function GetItem(AIndex: Integer): Variant;
    procedure SetItem(AIndex: Integer; const AItem: Variant);
    function GetListType(LRttiType: TRttiType): TRttiType;
    type
      TJSONBrParser = record
      private
        FJson: String;
        FIndex: Integer;
        FJsonLength: Integer;
        procedure Init(const AJson: String; AIndex: Integer);
        function GetNextChar: Char; inline;
        function GetNextNonWhiteChar: Char; inline;
        function CheckNextNonWhiteChar(AChar: Char): Boolean; inline;
        function GetNextString(out AStr: String): Boolean; overload;
        function GetNextString: String; overload; inline;
        function GetNextJSON(out AValue: Variant): TJSONBrParserKind;
        function CheckNextIdent(const AExpectedIdent: string): Boolean;
        function GetNextAlphaPropName(out AFieldName: string): Boolean;
        function ParseJSONObject(out AData: TJSONBrVariantData): Boolean;
        function ParseJSONArray(out AData: TJSONBrVariantData): Boolean;
        function CopyIndex: Integer;
        procedure GetNextStringUnEscape(var AStr: string);
      end;
  public
    FNames: TStringDynamicArray;
    FValues: TVariantDynamicArray;
    procedure Init; overload;
    procedure Init(const AJson: String); overload;
    procedure InitFrom(const AValues: TVariantDynamicArray); overload;
    procedure Clear;
    function NameIndex(const AName: String): Integer;
    function FromJSON(const AJson: String): Boolean;
    function ToJSON: String;
    function ToObject(AObject: TObject): Boolean;
    procedure AddValue(const AValue: Variant);
    procedure AddNameValue(const AName: String; const AValue: Variant);
    property Kind: TJSONBrVariantKind read GetKind write SetKind;
    property Count: Integer read GetCount;
    property Value[const AName: String]: Variant read GetValue write SetValue; default;
    property ValueCopy[const AName: String]: Variant read GetValueCopy;
    property Item[AIndex: Integer]: Variant read GetItem write SetItem;
  end;

  TJSONVariant = class(TInvokeableVariantType)
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

  TJSONBrObject = class
  private
    class var FNotifyEventSetValue: TNotifyEventSetValue;
    class var FNotifyEventGetValue: TNotifyEventGetValue;
  private
    function GetInstanceProp(AInstance: TObject; AProperty: TRttiProperty): Variant;
    class function ResolveValueArrayString(const AValue: Variant): TArray<String>;
    class function ResolveValueArrayInteger(const AValue: Variant): TArray<Integer>;
    class function ResolveValueArrayInt64(const AValue: Variant): TArray<Int64>;
    class function ResolveValueArrayDouble(const AValue: Variant): TArray<Double>;
    class function ResolveValueArrayCurrency(const AValue: Variant): TArray<Currency>;

    class procedure SetInstanceProp(const AInstance: TObject; const AProperty:
      TRttiProperty; const AValue: Variant);
    class function IsBlob(const ATypeInfo: PTypeInfo): Boolean;
    class function GetValueArray(const ATypeInfo: PTypeInfo; const AValue: Variant): TValue;
    class function JSONVariantData(const AValue: Variant): TJSONBrVariantData;
    class procedure AppendChar(var AStr: string; AChr: char);
  public
    class var UseISO8601DateFormat: Boolean;
    function ObjectToJSON(const AObject: TObject; const AStoreClassName: Boolean = False): String;
    function DynArrayStringToJSON(const AValue: TValue): String;
    function DynArrayIntegerToJSON(const AValue: TValue): String;
    function DynArrayDoubleToJSON(const AValue: TValue): String;
    function JSONVariant(const AValues: TVariantDynamicArray): Variant; overload;
    function JSONVariant(const AJson: String): Variant; overload;
    function JSONToObject(AObject: TObject; const AJson: String): Boolean; overload;
    function JSONToObject<T: class, constructor>(const AJson: String): T; overload;
    function JSONToObjectList<T: class, constructor>(const AJson: String): TObjectList<T>;

    class function StringToJSON(const AText: string): string;
    class function ValueToJSON(const AValue: Variant): string;
    class property OnSetValue: TNotifyEventSetValue read FNotifyEventSetValue write FNotifyEventSetValue;
    class property OnGetValue: TNotifyEventGetValue read FNotifyEventGetValue write FNotifyEventGetValue;
  end;

var
  JSONVariantType: TInvokeableVariantType;

implementation

{ TJSONBrObject }

function TJSONBrObject.JSONVariant(const AJson: String): Variant;
begin
  VarClear(Result);
  TJSONBrVariantData(Result).FromJSON(AJson);
end;

function TJSONBrObject.JSONVariant(const AValues: TVariantDynamicArray): Variant;
begin
  VarClear(Result);
  TJSONBrVariantData(Result).Init;
  TJSONBrVariantData(Result).FVKind := vkArray;
  TJSONBrVariantData(Result).FVCount := Length(AValues);
  TJSONBrVariantData(Result).FValues := AValues;
end;

class function TJSONBrObject.JSONVariantData(const AValue: Variant): TJSONBrVariantData;
begin
  with TVarData(AValue) do
  begin
    if VType = JSONVariantType.VarType then
      Result := TJSONBrVariantData(AValue)
    else
    if VType = varByRef or varVariant then
      Result := TJSONBrVariantData(PVariant(VPointer)^)
    else
      raise EJSONBrException.CreateFmt('JSONBrVariantData.Data(%d<>JSONVariant)', [VType]);
  end;
end;

class procedure TJSONBrObject.AppendChar(var AStr: String; AChr: Char);
begin
  AStr := AStr + String(AChr);
end;

class function TJSONBrObject.StringToJSON(const AText: String): String;
var
  LLen, LFor: Integer;

  procedure DoEscape;
  var
    LChr: Integer;
    LResultBuilder: TStringBuilder;
  begin
    LResultBuilder := TStringBuilder.Create;
    try
      LResultBuilder.Append('"' + Copy(AText, 1, LFor - 1));
      for LChr := LFor to LLen do
      begin
        case AText[LChr] of
          #8:  LResultBuilder.Append('\b');
          #9:  LResultBuilder.Append('\t');
          #10: LResultBuilder.Append('\n');
          #12: LResultBuilder.Append('\f');
          #13: LResultBuilder.Append('\r');
          '\': LResultBuilder.Append('\\');
          '"': LResultBuilder.Append('\"');
        else
          if AText[LChr] < ' ' then
            LResultBuilder.Append('\u00' + IntToHex(Ord(AText[LChr]), 2))
          else
            LResultBuilder.Append(AText[LChr]);
        end;
      end;
      LResultBuilder.Append('"');
      Result := LResultBuilder.ToString;
    finally
      LResultBuilder.Free;
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
        Exit;
      end;
    end;
  Result := AnsiQuotedStr(AText, '"');
end;

class function TJSONBrObject.ValueToJSON(const AValue: Variant): String;
var
  LInt64: Int64;
  LDouble: Double;
begin
  if TVarData(AValue).VType = JSONVariantType.VarType then
    Result := TJSONBrVariantData(AValue).ToJSON
  else
  begin
    case TVarData(AValue).VType of
      varByRef, varVariant:
        Result := ValueToJSON(PVariant(TVarData(AValue).VPointer)^);
      varNull:
        Result := 'null';
      varBoolean:
        begin
          if TVarData(AValue).VBoolean then
            Result := 'true'
          else
            Result := 'false';
        end;
      varDate:
        Result := AnsiQuotedStr(DateTimeToIso8601(TVarData(AValue).VDouble, UseISO8601DateFormat), '"');
    else
      if VarIsOrdinal(AValue) then
      begin
        LInt64 := AValue;
        Result := IntToStr(LInt64);
      end
      else
      if VarIsFloat(AValue) then
      begin
        LDouble := AValue;
        Result := FloatToStr(LDouble, JsonBrFormatSettings)
      end
      else
      if VarIsStr(AValue) then
        Result :=  StringToJSON(VarToStr(AValue))
      else
        Result := VarToStr(AValue);
    end;
  end;
end;

function TJSONBrObject.GetInstanceProp(AInstance: TObject;
  AProperty: TRttiProperty): Variant;
var
  LObject: TObject;
  LTypeInfo: PTypeInfo;
  LBreak: Boolean;

  function IsBoolean: Boolean;
  var
    LTypeName: string;
  begin
    LTypeName := AProperty.PropertyType.Handle.NameFld.ToString;
    Result := SameText(LTypeName, 'boolean') or SameText(LTypeName, 'bool');
  end;

begin
  VarClear(Result);
  // Notify Event
  if Assigned(FNotifyEventGetValue) then
  begin
    LBreak := False;
    FNotifyEventGetValue(AInstance, AProperty, Result, LBreak);
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
              Result := StrToFloat(AProperty.GetValue(AInstance).AsString, JsonBrFormatSettings);
            end;
          ftDouble:
            begin
              if (LTypeInfo = TypeInfo(TDateTime)) or
                 (LTypeInfo = TypeInfo(TDate))     or
                 (LTypeInfo = TypeInfo(TTime))     then
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
      tkVariant:
        Result := AProperty.GetValue(AInstance).AsVariant;
      tkRecord:
        Result := AProperty.GetValue(AInstance).AsVariant;
      tkClass:
        begin
          LObject := AProperty.GetValue(AInstance).AsObject;
          if LObject <> nil then
            TJSONBrVariantData(Result).Init(ObjectToJSON(LObject))
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
      tkDynArray:
        begin
          if IsBlob(LTypeInfo) then
            Result := Null
          else
          if AProperty.GetValue(AInstance).IsArray then
          begin
            if EndsText('<System.String>', String(LTypeInfo.Name)) then
              Result := DynArrayStringToJSON(AProperty.GetValue(AInstance))
            else
            if EndsText('<System.Integer>', String(LTypeInfo.Name)) then
              Result := DynArrayIntegerToJSON(AProperty.GetValue(AInstance))
            else
              Result := DynArrayDoubleToJSON(AProperty.GetValue(AInstance))
          end;
        end;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro no GetValue() da propriedade [' + AProperty.Name + ']' + sLineBreak + E.Message);
  end;
end;

class function TJSONBrObject.GetValueArray(const ATypeInfo: PTypeInfo;
  const AValue: Variant): TValue;
var
  LValue: Variant;
begin
  if not Assigned(ATypeInfo) then
    Result := nil;
  if not (ATypeInfo.Kind = tkDynArray) then
    Result := nil;
  if not StartsText('TArray<', String(ATypeInfo.Name)) then
    Result := nil;

  LValue := AValue;
  LValue := ReplaceStr(LValue, '[', '');
  LValue := ReplaceStr(LValue, ']', '');
  LValue := ReplaceStr(LValue, '"', '');
  if EndsText('<System.String>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayString(LValue))
  else
  if EndsText('<System.Integer>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayInteger(LValue))
  else
  if EndsText('<System.Int64>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayInt64(LValue))
  else
  if EndsText('<System.Double>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayDouble(LValue))
  else
  if EndsText('<System.Currency>', String(ATypeInfo.Name)) then
    Result := TValue.From(ResolveValueArrayCurrency(LValue));
end;

class procedure TJSONBrObject.SetInstanceProp(const AInstance: TObject;
  const AProperty: TRttiProperty; const AValue: Variant);
var
  LBreak: Boolean;
  LTypeInfo: PTypeInfo;
  LObject: TObject;

  function IsBoolean: Boolean;
  var
    LTypeName: string;
  begin
    LTypeName := AProperty.PropertyType.Handle.NameFld.ToString;
    Result := SameText(LTypeName, 'boolean') or SameText(LTypeName, 'bool');
  end;

begin
  if (AProperty = nil) and (AInstance = nil) then
    Exit;
  // Notify Event
  if Assigned(FNotifyEventSetValue) then
  begin
    LBreak := False;
    FNotifyEventSetValue(AInstance, AProperty, AValue, LBreak);
    if LBreak then
      Exit;
  end;

  LTypeInfo := AProperty.PropertyType.Handle;
  try
    case AProperty.PropertyType.TypeKind of
      tkString, tkWString, tkUString, tkWChar, tkLString, tkChar:
        if TVarData(AValue).VType <= varNull then
          AProperty.SetValue(AInstance, '')
        else
          AProperty.SetValue(AInstance, String(AValue));
      tkInteger, tkSet, tkInt64:
        AProperty.SetValue(AInstance, Integer(AValue));
      tkFloat:
        if TVarData(AValue).VType <= varNull then
          AProperty.SetValue(AInstance, 0)
        else
        if (LTypeInfo = TypeInfo(TDateTime)) or
           (LTypeInfo = TypeInfo(TDate)) or
           (LTypeInfo = TypeInfo(TTime)) then
          AProperty.SetValue(AInstance, Iso8601ToDateTime(AValue, UseISO8601DateFormat))
        else
          AProperty.SetValue(AInstance, Double(AValue));
      tkVariant:
        AProperty.SetValue(AInstance, TValue.FromVariant(AValue));
      tkRecord:
        AProperty.SetValue(AInstance, TValue.FromVariant(AValue));
      tkClass:
        begin
          LObject := AProperty.GetValue(AInstance).AsObject;
          if LObject <> nil then
            JSONVariantData(AValue).ToObject(LObject);
        end;
      tkEnumeration:
        begin
          if IsBoolean() then
            AProperty.SetValue(AInstance, Boolean(AValue))
          else
            AProperty.SetValue(AInstance, TValue.FromVariant(AValue));
        end;
      tkDynArray:
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

function TJSONBrObject.DynArrayDoubleToJSON(const AValue: TValue): String;
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
    LResultBuilder.ReplaceLastChar(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

function TJSONBrObject.DynArrayIntegerToJSON(const AValue: TValue): String;
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
    LResultBuilder.ReplaceLastChar(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

function TJSONBrObject.DynArrayStringToJSON(const AValue: TValue): String;
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
    LResultBuilder.ReplaceLastChar(']');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

class function TJSONBrObject.IsBlob(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo = TypeInfo(TByteDynArray)) and
            (PropWrap(ATypeInfo).Kind = $FF);
end;

function TJSONBrObject.JSONToObjectList<T>(const AJson: String): TObjectList<T>;
var
  LDoc: TJSONBrVariantData;
  LItem: TObject;
  LFor: Integer;
begin
  LDoc.Init(AJson);
  if (LDoc.FVKind <> vkArray) then
    Result := nil
  else
  begin
    Result := TObjectList<T>.Create;
    //Result.OwnsObjects := True;
    for LFor := 0 to LDoc.Count - 1 do
    begin
      LItem := T.Create;
      if not JSONVariantData(LDoc.FValues[LFor]).ToObject(LItem) then
      begin
        FreeAndNil(Result);
        Exit;
      end;
      Result.Add(LItem);
    end;
  end;
end;

function TJSONBrObject.JSONToObject(AObject: TObject; const AJson: String): Boolean;
var
  LDoc: TJSONBrVariantData;
begin
  if AObject = nil then
    Result := False
  else
  begin
    LDoc.Init(AJson);
    Result := LDoc.ToObject(AObject);
  end;
end;

function TJSONBrObject.JSONToObject<T>(const AJson: String): T;
begin
  Result := T.Create;
  if not JSONToObject(TObject(Result), AJson) then
    raise Exception.Create('Error JSON to Object');
end;

function TJSONBrObject.ObjectToJSON(const AObject: TObject;
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
          LStringBuilder.Append(ObjectToJSON(TObject(TList(AObject).List[LFor]),
                                AStoreClassName))
                        .Append(',');
        LStringBuilder.ReplaceLastChar(']');
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
          LStringBuilder.Append(StringToJSON(TStrings(AObject).Strings[LFor]))
                        .Append(',');
        LStringBuilder.ReplaceLastChar(']');
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
          LStringBuilder.Append(ObjectToJSON(TCollection(AObject).Items[LFor], AStoreClassName))
                        .Append(',');
        LStringBuilder.ReplaceLastChar(']');
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
          for LFor := 0 to LValue.GetArrayLength -1 do
            LStringBuilder.Append(ObjectToJSON(LValue.GetArrayElement(LFor).AsObject, AStoreClassName)).Append(',');
          LStringBuilder.ReplaceLastChar(']');
          Result := LStringBuilder.ToString;
        finally
          LStringBuilder.Free;
        end;
      end;
      Exit;
    end;
    {$ELSE DELPHI15_UP}
    if TList(AObject).Count = 0 then
      Result := '[]';
    else
    begin
      LStringBuilder := TStringBuilder.Create;
      try
        LStringBuilder.Append('[');
        for LFor := 0 to TList(AObject).Count -1 do
            LStringBuilder.Append(ObjectToJSON(TList(AObject).Items[LFor], AStoreClassName)).Append(',');
          LStringBuilder.ReplaceLastChar(']');
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
      if (not LProperty.IsWritable) then
        Continue;
      if LProperty.PropertyType.TypeKind = tkArray then
        LResultBuilder.Append(StringToJSON(LProperty.Name))
                      .Append(':')
                      .Append(String(GetInstanceProp(AObject, LProperty)))
                      .Append(',')
      else
        LResultBuilder.Append(StringToJSON(LProperty.Name))
                      .Append(':')
                      .Append(ValueToJSON(GetInstanceProp(AObject, LProperty)))
                      .Append(',');
    end;
    LResultBuilder.ReplaceLastChar('}');
    Result := LResultBuilder.ToString;
  finally
    LResultBuilder.Free;
  end;
end;

class function TJSONBrObject.ResolveValueArrayString(const AValue: Variant): TArray<String>;
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

class function TJSONBrObject.ResolveValueArrayCurrency(const AValue: Variant): TArray<Currency>;
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

class function TJSONBrObject.ResolveValueArrayDouble(const AValue: Variant): TArray<Double>;
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

class function TJSONBrObject.ResolveValueArrayInt64(const AValue: Variant): TArray<Int64>;
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

class function TJSONBrObject.ResolveValueArrayInteger(const AValue: Variant): TArray<Integer>;
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

{ TJSONBrParser }

procedure TJSONBrVariantData.TJSONBrParser.Init(const AJson: String; AIndex: Integer);
begin
  FJson := AJson;
  FJsonLength := Length(FJson);
  FIndex := AIndex;
end;

function TJSONBrVariantData.TJSONBrParser.GetNextChar: Char;
begin
  Result := #0;
  if FIndex <= FJsonLength then
  begin
    Result := Char(FJson[FIndex]);
    Inc(FIndex);
  end;
end;

function TJSONBrVariantData.TJSONBrParser.GetNextNonWhiteChar: Char;
begin
  Result := #0;
  if FIndex <= FJsonLength then
  begin
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
end;

function TJSONBrVariantData.TJSONBrParser.CheckNextNonWhiteChar(AChar: Char): Boolean;
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
        Exit;
      end;
      Inc(FIndex);
    until FIndex > FJsonLength;
  end;
end;

function TJSONBrVariantData.TJSONBrParser.CopyIndex: Integer;
begin
  Result := {$IFDEF NEXTGEN}FIndex +1{$ELSE}FIndex{$ENDIF};
end;

procedure TJSONBrVariantData.TJSONBrParser.GetNextStringUnEscape(var AStr: String);
var
  LChar: Char;
  LCopy: String;
  LUnicode, LErr: Integer;
begin
  repeat
    LChar := GetNextChar;
    case LChar of
      #0:  Exit;
      '"': Break;
      '\': begin
           LChar := GetNextChar;
           case LChar of
             #0 : Exit;
             'b': TJSONBrObject.AppendChar(AStr, #08);
             't': TJSONBrObject.AppendChar(AStr, #09);
             'n': TJSONBrObject.AppendChar(AStr, #$0a);
             'f': TJSONBrObject.AppendChar(AStr, #$0c);
             'r': TJSONBrObject.AppendChar(AStr, #$0d);
             'u':
             begin
               LCopy := Copy(FJson, CopyIndex, 4);
               if Length(LCopy) <> 4 then
                 Exit;
               Inc(FIndex, 4);
               Val('$' + LCopy, LUnicode, LErr);
               if LErr <> 0 then
                 Exit;
               TJSONBrObject.AppendChar(AStr, Char(LUnicode));
             end;
           else
             TJSONBrObject.AppendChar(AStr, LChar);
           end;
         end;
    else
      TJSONBrObject.AppendChar(AStr, LChar);
    end;
  until False;
end;

function TJSONBrVariantData.TJSONBrParser.GetNextString(out AStr: String): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  for LFor := FIndex to FJsonLength do
  begin
    case FJson[LFor] of
      '"': begin // end of String without escape -> direct copy
             AStr := Copy(FJson, CopyIndex, LFor - FIndex);
             FIndex := LFor + 1;
             Result := True;
             Exit;
           end;
      '\': begin // need unescaping
             AStr := Copy(FJson, CopyIndex, LFor - FIndex);
             FIndex := LFor;
             GetNextStringUnEscape(AStr);
             Result := True;
             Exit;
           end;
    end;
  end;
end;

function TJSONBrVariantData.TJSONBrParser.GetNextString: String;
begin
  if not GetNextString(Result) then
    Result := '';
end;

function TJSONBrVariantData.TJSONBrParser.GetNextAlphaPropName(out AFieldName: String): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  if (FIndex >= FJsonLength) or not (Ord(FJson[FIndex]) in [Ord('A') ..
                                                            Ord('Z'),
                                                            Ord('a') ..
                                                            Ord('z'),
                                                            Ord('_'),
                                                            Ord('$')]) then
    Exit;
  for LFor := FIndex + 1 to FJsonLength do
    case Ord(FJson[LFor]) of
         Ord('0') ..
         Ord('9'),
         Ord('A') ..
         Ord('Z'),
         Ord('a') ..
         Ord('z'),
         Ord('_'):; // allow MongoDB extended syntax, e.g. {age:{$gt:18}}
         Ord(':'),
         Ord('='):
      begin
        AFieldName := Copy(FJson, CopyIndex, LFor - FIndex);
        FIndex := LFor + 1;
        Result := True;
        Exit;
      end;
    else
      Exit;
    end;
end;

function TJSONBrVariantData.TJSONBrParser.GetNextJSON(out AValue: Variant): TJSONBrParserKind;
var
  LStr: String;
  LInt64: Int64;
  LValue: Double;
  LStart, LErr: Integer;
begin
  Result := pkNone;
  case GetNextNonWhiteChar of
    'n': if Copy(FJson, CopyIndex, 3) = 'ull' then
         begin
           Inc(FIndex, 3);
           Result := pkNull;
           AValue := Null;
         end;
    'f': if Copy(FJson, CopyIndex, 4) = 'alse' then
         begin
           Inc(FIndex, 4);
           Result := pkFalse;
           AValue := False;
         end;
    't': if Copy(FJson, CopyIndex, 3) = 'rue' then
         begin
           Inc(FIndex, 3);
           Result := pkTrue;
           AValue := True;
         end;
    '"': if GetNextString(LStr) then
         begin
           Result := pkString;
           AValue := LStr;
         end;
    '{': if ParseJSONObject(TJSONBrVariantData(AValue)) then
           Result := pkObject;
    '[': if ParseJSONArray(TJSONBrVariantData(AValue)) then
           Result := pkArray;
    '-', '0' .. '9':
         begin
           LStart := CopyIndex - 1;
           while True do
             case FJson[FIndex] of
               '-', '+', '0' .. '9', '.', 'E', 'e':
                 Inc(FIndex);
             else
               Break;
             end;
           LStr := Copy(FJson, LStart, CopyIndex - LStart);
           Val(LStr, LInt64, LErr);
           if LErr = 0 then
           begin
             Result := pkInteger;
             AValue := LInt64;
           end
           else
           begin
             Val(LStr, LValue, LErr);
             if LErr <> 0 then
               Exit;
             AValue := LValue;
             Result := pkFloat;
           end;
         end;
  end;
end;

function TJSONBrVariantData.TJSONBrParser.CheckNextIdent(const AExpectedIdent: String): Boolean;
begin
  Result := (GetNextNonWhiteChar = '"') and
            (CompareText(GetNextString, AExpectedIdent) = 0) and
            (GetNextNonWhiteChar = ':');
end;

function TJSONBrVariantData.TJSONBrParser.ParseJSONArray(out AData: TJSONBrVariantData): Boolean;
var
  LItem: Variant;
begin
  Result := False;
  AData.Init;
  if not CheckNextNonWhiteChar(']') then
  begin
    repeat
      if GetNextJSON(LItem) = pkNone then
        Exit;
      AData.AddValue(LItem);
      case GetNextNonWhiteChar of
        ',': Continue;
        ']': Break;
      else
        Exit;
      end;
    until False;
    SetLength(AData.FValues, AData.FVCount);
  end;
  AData.FVKind := vkArray;
  Result := True;
end;

function TJSONBrVariantData.TJSONBrParser.ParseJSONObject(out AData: TJSONBrVariantData): Boolean;
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
          Exit;
      end
      else
      if not GetNextAlphaPropName(LKey) then
        Exit;
      if GetNextJSON(LItem) = pkNone then
        Exit;
      AData.AddNameValue(LKey, LItem);
      case GetNextNonWhiteChar of
        ',': Continue;
        '}': Break;
      else
        Exit;
      end;
    until False;
    SetLength(AData.FNames, AData.FVCount);
  end;
  SetLength(AData.FValues, AData.FVCount);
  AData.FVKind := vkObject;
  Result := True;
end;

{ TJSONBrVariantData }

procedure TJSONBrVariantData.Init;
begin
  FVType := JSONVariantType.VarType;
  FVKind := vkUndefined;
  FVCount := 0;
  Pointer(FNames) := nil;
  Pointer(FValues) := nil;
end;

procedure TJSONBrVariantData.Init(const AJson: String);
begin
  Init;
  FromJSON(AJson);
  if FVType = varNull then
    FVKind := vkObject
  else
  if FVType <> JSONVariantType.VarType then
    Init;
end;

procedure TJSONBrVariantData.InitFrom(const AValues: TVariantDynamicArray);
begin
  Init;
  FVKind := vkArray;
  FValues := AValues;
  FVCount := Length(AValues);
end;

procedure TJSONBrVariantData.Clear;
begin
  FNames := nil;
  FValues := nil;
  Init;
end;

procedure TJSONBrVariantData.AddNameValue(const AName: String;
  const AValue: Variant);
begin
  if FVKind = vkUndefined then
    FVKind := vkObject
  else
  if FVKind <> vkObject then
    raise EJSONBrException.CreateFmt('AddNameValue(%s) over array', [AName]);
  if FVCount <= Length(FValues) then
  begin
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
    SetLength(FNames, FVCount + FVCount shr 3 + 32);
  end;
  FValues[FVCount] := AValue;
  FNames[FVCount] := AName;
  Inc(FVCount);
end;

procedure TJSONBrVariantData.AddValue(const AValue: Variant);
begin
  if FVKind = vkUndefined then
    FVKind := vkArray
  else
  if FVKind <> vkArray then
    raise EJSONBrException.Create('AddValue() over object');
  if FVCount <= Length(FValues) then
    SetLength(FValues, FVCount + FVCount shr 3 + 32);
  FValues[FVCount] := AValue;
  Inc(FVCount);
end;

function TJSONBrVariantData.FromJSON(const AJson: String): Boolean;
var
  LParser: TJSONBrParser;
begin
  LParser.Init(AJson, 0);
  Result := LParser.GetNextJSON(Variant(Self)) in [pkObject, pkArray];
end;

function TJSONBrVariantData.GetKind: TJSONBrVariantKind;
begin
  if (@Self = nil) or (FVType <> JSONVariantType.VarType) then
    Result := vkUndefined
  else
    Result := FVKind;
end;

function TJSONBrVariantData.GetCount: Integer;
begin
  if (@Self = nil) or (FVType <> JSONVariantType.VarType) then
    Result := 0
  else
    Result := FVCount;
end;

function TJSONBrVariantData.GetValue(const AName: String): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and (FVKind = vkObject) then
    GetVarData(AName, TVarData(Result));
end;

function TJSONBrVariantData.GetValueCopy(const AName: String): Variant;
var
  LFor: Cardinal;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and (FVKind = vkObject) then
  begin
    LFor := Cardinal(NameIndex(AName));
    if LFor < Cardinal(Length(FValues)) then
      Result := FValues[LFor];
  end;
end;

function TJSONBrVariantData.GetItem(AIndex: Integer): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and (FVKind = vkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      Result := FValues[AIndex];
end;

procedure TJSONBrVariantData.SetItem(AIndex: Integer; const AItem: Variant);
begin
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and (FVKind = vkArray) then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      FValues[AIndex] := AItem;
end;

procedure TJSONBrVariantData.SetKind(const Value: TJSONBrVariantKind);
begin
  FVKind := Value;
end;

function TJSONBrVariantData.GetVarData(const AName: String;
  var ADest: TVarData): Boolean;
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

function TJSONBrVariantData.NameIndex(const AName: String): Integer;
begin
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and (FNames <> nil) then
    for Result := 0 to FVCount - 1 do
      if FNames[Result] = AName then
        Exit;
  Result := -1;
end;

procedure TJSONBrVariantData.SetValue(const AName: String; const AValue: Variant);
var
  LFor: Integer;
begin
  if @Self = nil then
    raise EJSONBrException.Create('Unexpected Value[] access');
  if AName = '' then
    raise EJSONBrException.Create('Unexpected Value['''']');
  LFor := NameIndex(AName);
  if LFor < 0 then
    AddNameValue(AName, AValue)
  else
    FValues[LFor] := String(AValue);
end;

function TJSONBrVariantData.ToJSON: String;
var
  LFor: Integer;
  LResultBuilder: TStringBuilder;
begin
  case FVKind of
    vkObject:
      if FVCount = 0 then
        Result := '{}'
      else
      begin
        LResultBuilder := TStringBuilder.Create;
        try
          LResultBuilder.Append('{');
          for LFor := 0 to FVCount - 1 do
            LResultBuilder.Append(TJSONBrObject.StringToJSON(FNames[LFor]))
                          .Append(':')
                          .Append(TJSONBrObject.ValueToJSON(FValues[LFor]))
                          .Append(',');
          LResultBuilder.ReplaceLastChar('}');
          Result := LResultBuilder.ToString;
        finally
          LResultBuilder.Free;
        end;
      end;
    vkArray:
      if FVCount = 0 then
        Result := '[]'
      else
      begin
        LResultBuilder := TStringBuilder.Create;
        try
          LResultBuilder.Append('[');
          for LFor := 0 to FVCount - 1 do
            LResultBuilder.Append(TJSONBrObject.ValueToJSON(FValues[LFor]))
                          .Append(',');
          LResultBuilder.ReplaceLastChar(']');
          Result := LResultBuilder.ToString;
        finally
          LResultBuilder.Free;
        end;
      end;
  else
    Result := 'null';
  end;
end;

function TJSONBrVariantData.ToObject(AObject: TObject): Boolean;
var
  LFor: Integer;
  FContext: TRttiContext;
  LItem: TCollectionItem;
  LListType: TRttiType;
  LProperty: TRttiProperty;
  LObjectType: TObject;

  function MethodCall(const AObject: TObject; const AMethodName: string;
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
    vkObject:
      begin
        LListType := FContext.GetType(AObject.ClassType);
        if LListType <> nil then
        begin
          for LFor := 0 to Count - 1 do
          begin
            LProperty := LListType.GetProperty(FNames[LFor]);
            if LProperty <> nil then
              TJSONBrObject.SetInstanceProp(AObject, LProperty, FValues[LFor]);
          end;
        end;
      end;
    vkArray:
      if AObject.InheritsFrom(TCollection) then
      begin
        TCollection(AObject).Clear;
        for LFor := 0 to Count - 1 do
        begin
          LItem := TCollection(AObject).Add;
          if not TJSONBrObject.JSONVariantData(FValues[LFor]).ToObject(LItem) then
            Exit;
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
            if not TJSONBrObject.JSONVariantData(FValues[LFor]).ToObject(LObjectType) then
              Exit;
            MethodCall(AObject, 'Add', [LObjectType]);
          end;
        end;
      end
      else
        Exit;
  else
    Exit;
  end;
  Result := True;
end;

function TJSONBrVariantData.GetListType(LRttiType: TRttiType): TRttiType;
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

{ TJSONVariant }

procedure TJSONVariant.Cast(var ADest: TVarData; const ASource: TVarData);
begin
  CastTo(ADest, ASource, VarType);
end;

procedure TJSONVariant.CastTo(var ADest: TVarData; const ASource: TVarData;
  const AVarType: TVarType);
begin
  if ASource.VType <> VarType then
    RaiseCastError;
  Variant(ADest) := TJSONBrVariantData(ASource).ToJSON;
end;

procedure TJSONVariant.Clear(var AVarData: TVarData);
begin
  AVarData.VType := varEmpty;
  Finalize(TJSONBrVariantData(AVarData).FNames);
  Finalize(TJSONBrVariantData(AVarData).FValues);
end;

procedure TJSONVariant.Copy(var ADest: TVarData; const ASource: TVarData;
  const AIndirect: Boolean);
begin
  if AIndirect then
    SimplisticCopy(ADest, ASource, True)
  else
  begin
    VarClear(Variant(ADest));
    TJSONBrVariantData(ADest).Init;
    TJSONBrVariantData(ADest) := TJSONBrVariantData(ASource);
  end;
end;

function TJSONVariant.GetProperty(var ADest: TVarData; const AVarData: TVarData;
  const AName: String): Boolean;
begin
  if not TJSONBrVariantData(AVarData).GetVarData(AName, ADest) then
    ADest.VType := varNull;
  Result := True;
end;

function TJSONVariant.SetProperty(const AVarData: TVarData; const AName: String;
  const AValue: TVarData): Boolean;
begin
  TJSONBrVariantData(AVarData).SetValue(AName, Variant(AValue));
  Result := True;
end;

procedure TStringBuilderHelper.ReplaceLastChar(const AChar: Char);
begin
  if Self.Length > 1 then
  begin
    // Remove espaço final vazio
    if Self.Chars[Self.Length - 1] = ' ' then
      Self.Remove(Self.Length - 1, 1);
    // Troca o último caracter
    Self.Chars[Self.Length - 1] := AChar;
  end;
end;

initialization
  JSONVariantType := TJSONVariant.Create;
  TJSONBrObject.UseISO8601DateFormat := True;

end.
