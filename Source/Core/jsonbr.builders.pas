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
  Classes,
  Variants,
  TypInfo,
  Types,
  Generics.Collections;

type
  TJSONBrObject = class;

  TNotifyEventGetValue = procedure(const Sender: TJSONBrObject; 
                                   const AInstance: TObject; 
								   const AProperty: TRttiProperty; 
								   var AResult: Variant; 
								   var ABreak: Boolean) of Object;
  TNotifyEventSetValue = procedure(const AInstance: TObject; 
                                   const AProperty: TRttiProperty; 
								   const AValue: Variant; 
								   var ABreak: Boolean) of Object;
//  TJSONBrOption = (joIgnoreEmptyStrings,
//                   joIgnoreEmptyArrays,
//                   joDateIsUTC,
//                   joDateFormatUnix,
//                   joDateFormatISO8601,
//                   joDateFormatMongo,
//                   joDateFormatParse);
//  TJSONBrOptions = set of TJSONBrOption;

  EJSONBrException = class(Exception);

  TStringDynamicArray = array of String;
  TVariantDynamicArray = array of Variant;

  TJSONBrVariantKind = (vkUndefined, vkObject, vkArray);
  TJSONBrParserKind = (pkNone, pkNull, pkFalse, pkTrue, pkString, pkInteger, pkFloat, pkObject, pkArray);

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

  // Used in TJSONBrVariantData.FromJSON()
  TJSONBrParser = record
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
    class var
    FNotifyEventSetValue: TNotifyEventSetValue;
    FNotifyEventGetValue: TNotifyEventGetValue;
  private
    FJSON: String;
    function JSONVariant(const AJson: String): Variant; overload;
    function JSONVariant(const AValues: TVariantDynamicArray): Variant; overload;
    function GetInstanceProp(AInstance: TObject; AProperty: TRttiProperty): Variant;
    class procedure SetInstanceProp(const AInstance: TObject; const AProperty:
      TRttiProperty; const AValue: Variant);
    class function IsBlob(const ATypeInfo: PTypeInfo): Boolean;
    class function JSONVariantData(const JSONVariant: Variant): TJSONBrVariantData;
    class function StringToJSON(const AText: string): string;
    class function ValueToJSON(const AValue: Variant): string;
    class function DateTimeToJSON(AValue: TDateTime): string;
    class procedure DoubleToJSON(AValue: Double; out AResult: string);
    class procedure AppendChar(var AStr: string; AChr: char);
    class function DateTimeToIso8601(const AValue: TDateTime): string; static;
    class function Iso8601ToDateTime(const AValue: string): TDateTime;
  public
    function ObjectToJSON(AObject: TObject; AStoreClassName: Boolean = False): String;
    function JSONToObject(AObject: TObject; const AJson: String): Boolean; overload;
    function JSONToObject<T: class, constructor>(const AJson: String): T; overload;
    function JSONToObjectList<T: class, constructor>(const AJson: String): TObjectList<T>;

    function BeginObject(const AValue: String = ''): TJSONBrObject;
    function BeginArray: TJSONBrObject;
    function EndObject: TJSONBrObject;
    function EndArray: TJSONBrObject;
    function AddPair(const APair: String; const AValue: String): TJSONBrObject; overload;
    function AddPair(const APair: String; const AValue: Integer): TJSONBrObject; overload;
    function AddPair(const APair: String; const AValue: TJSONBrObject): TJSONBrObject; overload;
    function AddPairArray(const APair: String; const AValue: array of string): TJSONBrObject; overload;
    function AddPairArray(const APair: String; const AValue: array of Integer): TJSONBrObject; overload;
    function ToJSON: String;

    class property OnSetValue: TNotifyEventSetValue read FNotifyEventSetValue write FNotifyEventSetValue;
    class property OnGetValue: TNotifyEventGetValue read FNotifyEventGetValue write FNotifyEventGetValue;
  end;

var
  JSONVariantType: TJSONVariant;
  FSettingsUS: TFormatSettings;

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

class function TJSONBrObject.JSONVariantData(const JSONVariant: Variant): TJSONBrVariantData;
begin
  with TVarData(JSONVariant) do
  begin
    if VType = JSONVariantType.VarType then
      Result := TJSONBrVariantData(JSONVariant)
    else
    if VType = varByRef or varVariant then
      Result := TJSONBrVariantData(PVariant(VPointer)^)
    else
      raise EJSONBrException.CreateFmt('JSONBrVariantData.Data(%d<>JSONVariant)', [VType]);
  end;
end;

function TJSONBrObject.BeginArray: TJSONBrObject;
begin
  Result := Self;
  FJSON := FJSON + '[';
end;

function TJSONBrObject.BeginObject(const AValue: String): TJSONBrObject;
begin
  Result := Self;
  if Length(AValue) > 0 then
    FJSON := FJSON + StringToJSON(AValue) + ':{'
  else
    FJSON := FJSON + '{';
end;

function TJSONBrObject.AddPair(const APair: String; const AValue: String): TJSONBrObject;
begin
  Result := Self;
  FJSON := FJSON + StringToJSON(APair) + ':' + ValueToJSON(AValue) + ',';
end;

function TJSONBrObject.AddPairArray(const APair: String; const AValue: array of string): TJSONBrObject;
var
  LFor: Integer;
begin
  Result := Self;
  FJSON := FJSON + StringToJSON(APair) + ':[';
  for LFor := Low(AValue) to High(AValue) do
    FJSON := FJSON + ValueToJSON(AValue[LFor]) + ',';
  FJSON[Length(FJSON)] := ']';
  FJSON := FJSON + ',';
end;

function TJSONBrObject.AddPairArray(const APair: String; const AValue: array of Integer): TJSONBrObject;
var
  LFor: Integer;
begin
  Result := Self;
  FJSON := FJSON + StringToJSON(APair) + ':[';
  for LFor := Low(AValue) to High(AValue) do
    FJSON := FJSON + ValueToJSON(AValue[LFor]) + ',';
  FJSON[Length(FJSON)] := ']';
  FJSON := FJSON + ',';
end;

function TJSONBrObject.AddPair(const APair: String; const AValue: TJSONBrObject): TJSONBrObject;
begin
  Result := Self;
  FJSON := FJSON + StringToJSON(APair) + ':' + AValue.ToJSON;
end;

function TJSONBrObject.AddPair(const APair: String; const AValue: Integer): TJSONBrObject;
begin
  Result := Self;
  FJSON := FJSON + StringToJSON(APair) + ':' + ValueToJSON(AValue) + ',';
end;

class procedure TJSONBrObject.AppendChar(var AStr: String; AChr: Char);
begin
  AStr := AStr + String(AChr);
end;

function TJSONBrObject.ToJSON: String;
begin
  if FJSON[Length(FJSON)] = ',' then
    FJSON[Length(FJSON)] := ' ';
  Result := TrimRight(FJSON);
  FJSON := '';
end;

class function TJSONBrObject.StringToJSON(const AText: String): String;
var
  LLen, LFor: Integer;

  procedure DoEscape;
  var
    LChr: Integer;
  begin
    Result := '"' + Copy(AText, 1, LFor - 1);
    for LChr := LFor to LLen do
    begin
      case AText[LChr] of
        #8:  Result := Result + '\b';
        #9:  Result := Result + '\t';
        #10: Result := Result + '\n';
        #12: Result := Result + '\f';
        #13: Result := Result + '\r';
        '\': Result := Result + '\\';
        '"': Result := Result + '\"';
      else
        if AText[LChr] < ' ' then
          Result := Result + '\u00' + IntToHex(Ord(AText[LChr]), 2)
        else
          AppendChar(Result, AText[LChr]);
      end;
    end;
    AppendChar(Result, '"');
  end;

begin
  LLen := Length(AText);
  for LFor := 1 to LLen do
    case AText[LFor] of
      #0 .. #31, '\', '"':
        begin
          DoEscape;
          Exit;
        end;
    end;
  Result := AnsiQuotedStr(AText, '"');
end;

class procedure TJSONBrObject.DoubleToJSON(AValue: Double;
  out AResult: string);
begin
  AResult := FloatToStr(AValue, FSettingsUS);
end;

function TJSONBrObject.EndArray: TJSONBrObject;
begin
  Result := Self;
  if FJSON[Length(FJSON)] = ',' then
    FJSON[Length(FJSON)] := ']'
  else
    FJSON := FJSON + ']';
end;

function TJSONBrObject.EndObject: TJSONBrObject;
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

// "YYYY-MM-DD" "Thh:mm:ss" or "YYYY-MM-DDThh:mm:ss"
class function TJSONBrObject.DateTimeToJSON(AValue: TDateTime): String;
begin
  Result := AnsiQuotedStr(DateTimeToIso8601(AValue), '"');
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
        Result := DateTimeToJSON(TVarData(AValue).VDouble);
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
        DoubleToJSON(LDouble, Result)
      end
      else
      if VarIsStr(AValue) then
        Result := StringToJSON(VarToStr(AValue))
      else
        Result := VarToStr(AValue);
    end;
  end;
end;

function TJSONBrObject.GetInstanceProp(AInstance: TObject;
  AProperty: TRttiProperty): Variant;
var
  LPtr: Pointer;
  LValBool: Boolean;
  LValI32: Int32;
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
    FNotifyEventGetValue(Self, AInstance, AProperty, Result, LBreak);
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
              Result := StrToFloat(AProperty.GetValue(AInstance).AsString, FSettingsUS);
            end;
          ftDouble:
            begin
              if (LTypeInfo = TypeInfo(TDateTime)) or
                 (LTypeInfo = TypeInfo(TDate))     or
                 (LTypeInfo = TypeInfo(TTime))     then
              begin
                Result := DateTimeToIso8601(AProperty.GetValue(AInstance).AsExtended);
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
        // Fazer tratamento em base64 para devolver o valor
        if IsBlob(AProperty.PropertyType.Handle) then
          Result := Null;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro no GetValue() da propriedade [' + AProperty.Name + ']' + sLineBreak + E.Message);
  end;
end;

class procedure TJSONBrObject.SetInstanceProp(const AInstance: TObject; const AProperty:
      TRttiProperty; const AValue: Variant);
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
  if (AProperty <> nil) and (AInstance <> nil) then
  begin
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
            AProperty.SetValue(AInstance, Iso8601ToDateTime(AValue))
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
          // Fazer tratamento em base64 para devolver o valor
//          if IsBlob(AProperty.PropertyType.Handle) then
      end;
    except
      on E: Exception do
        raise Exception.Create('Erro no SetValue() da propriedade [' + AProperty.Name + ']' + sLineBreak + E.Message);
    end;
  end;
end;

class function TJSONBrObject.DateTimeToIso8601(const AValue: TDateTime): string;
begin
  if AValue = 0 then
    Result := ''
  else
  if Frac(AValue) = 0 then
    Result := FormatDateTime('yyyy"-"mm"-"dd', AValue)
  else
  if Trunc(AValue) = 0 then
    Result := FormatDateTime('"T"hh":"nn":"ss', AValue)
  else
    Result := FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss', AValue);
end;

class function TJSONBrObject.IsBlob(const ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo = TypeInfo(TByteDynArray)) and
            (PropWrap(ATypeInfo).Kind = $FF);
end;

class function TJSONBrObject.Iso8601ToDateTime(const AValue: string): TDateTime;
var
  Y, M, D, HH, MI, SS: Cardinal;
begin
  // YYYY-MM-DD   Thh:mm:ss  or  YYYY-MM-DDThh:mm:ss
  // 1234567890   123456789      1234567890123456789
  Result := StrToDateTimeDef(AValue, 0);
  case Length(AValue) of
    9:
      if (AValue[1] = 'T') and (AValue[4] = ':') and (AValue[7] = ':') then
      begin
        HH := Ord(AValue[2]) * 10 + Ord(AValue[3]) - (48 + 480);
        MI := Ord(AValue[5]) * 10 + Ord(AValue[6]) - (48 + 480);
        SS := Ord(AValue[8]) * 10 + Ord(AValue[9]) - (48 + 480);
        if (HH < 24) and (MI < 60) and (SS < 60) then
          Result := EncodeTime(HH, MI, SS, 0);
      end;
    10:
      if (AValue[5] = AValue[8]) and (Ord(AValue[8]) in [Ord('-'), Ord('/')]) then
      begin
        Y := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        M := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        D := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        if (Y <= 9999) and ((M - 1) < 12) and ((D - 1) < 31) then
          Result := EncodeDate(Y, M, D);
      end;
    19,24:
      if (AValue[5] = AValue[8]) and
         (Ord(AValue[8]) in [Ord('-'), Ord('/')]) and
         (Ord(AValue[11]) in [Ord(' '), Ord('T')]) and
         (AValue[14] = ':') and
         (AValue[17] = ':') then
      begin
        Y := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        M := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        D := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        HH := Ord(AValue[12]) * 10 + Ord(AValue[13]) - (48 + 480);
        MI := Ord(AValue[15]) * 10 + Ord(AValue[16]) - (48 + 480);
        SS := Ord(AValue[18]) * 10 + Ord(AValue[19]) - (48 + 480);
        if (Y <= 9999) and ((M - 1) < 12) and ((D - 1) < 31) and (HH < 24) and (MI < 60) and (SS < 60) then
          Result := EncodeDate(Y, M, D) + EncodeTime(HH, MI, SS, 0);
      end;
  end;
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

function TJSONBrObject.ObjectToJSON(AObject: TObject;
  AStoreClassName: Boolean): String;
var
  FContext: TRttiContext;
  LTypeInfo: TRttiType;
  LProperty: TRttiProperty;
  {$IFDEF DELPHI15_UP}
  LMethodToArray: TRttiMethod;
  {$ENDIF DELPHI15_UP}
  LFor: Integer;
  LValue: TValue;
begin
  LValue := nil;
  if AObject = nil then
  begin
    Result := 'null';
    Exit;
  end;
  if AObject.InheritsFrom(TList) then
  begin
    if TList(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      Result := '[';
      for LFor := 0 to TList(AObject).Count - 1 do
        Result := Result +
                  ObjectToJSON(TObject(TList(AObject).List[LFor]),
                  AStoreClassName) + ',';
      Result[Length(Result)] := ']';
    end;
    Exit;
  end;
  if AObject.InheritsFrom(TStrings) then
  begin
    if TStrings(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      Result := '[';
      for LFor := 0 to TStrings(AObject).Count - 1 do
        Result := Result +
                  StringToJSON(TStrings(AObject).Strings[LFor]) + ',';
      Result[Length(Result)] := ']';
    end;
    Exit;
  end;
  if AObject.InheritsFrom(TCollection) then
  begin
    if TCollection(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      Result := '[';
      for LFor := 0 to TCollection(AObject).Count - 1 do
        Result := Result +
                  ObjectToJSON(TCollection(AObject).Items[LFor],
                  AStoreClassName) + ',';
      Result[Length(Result)] := ']';
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
        Result := '[';
        for LFor := 0 to LValue.GetArrayLength -1 do
          Result := Result +
                    ObjectToJSON(LValue.GetArrayElement(LFor).AsObject, AStoreClassName) + ',';
         Result[Length(Result)] := ']';
      end
    end;
    {$ELSE DELPHI15_UP}
    if TList(AObject).Count = 0 then
      Result := '[]'
    else
    begin
      Result := '[';
      for LFor := 0 to TList(AObject).Count -1 do
        Result := Result +
                  ObjectToJSON(TList(AObject).Items[LFor], AStoreClassName) + ',';
      Result[Length(Result)] := ']';
    end;
    {$ENDIF DELPHI15_UP}
    Exit;
  end;

  if AStoreClassName then
    Result := '{"ClassName":"' + AObject.ClassName + '",'
  else
    Result := '{';

  for LProperty in LTypeInfo.GetProperties do
  begin
    if LProperty.IsWritable then
      Result := Result + StringToJSON(LProperty.Name) + ':' +
                         ValueToJSON(GetInstanceProp(AObject, LProperty)) + ',';
  end;
  Result[Length(Result)] := '}';
end;

{ TJSONBrParser }

procedure TJSONBrParser.Init(const AJson: String; AIndex: Integer);
begin
  FJson := AJson;
  FJsonLength := Length(FJson);
  FIndex := AIndex;
end;

function TJSONBrParser.GetNextChar: Char;
begin
  Result := #0;
  if FIndex <= FJsonLength then
  begin
    Result := Char(FJson[FIndex]);
    Inc(FIndex);
  end;
end;

function TJSONBrParser.GetNextNonWhiteChar: Char;
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

function TJSONBrParser.CheckNextNonWhiteChar(AChar: Char): Boolean;
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

function TJSONBrParser.CopyIndex: Integer;
begin
  {$IFDEF NEXTGEN}
  Result := FIndex +1;
  {$ELSE}
  Result := FIndex;
  {$ENDIF}
end;

procedure TJSONBrParser.GetNextStringUnEscape(var AStr: String);
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

function TJSONBrParser.GetNextString(out AStr: String): Boolean;
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

function TJSONBrParser.GetNextString: String;
begin
  if not GetNextString(Result) then
    Result := '';
end;

function TJSONBrParser.GetNextAlphaPropName(out AFieldName: String): Boolean;
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

function TJSONBrParser.GetNextJSON(out AValue: Variant): TJSONBrParserKind;
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

function TJSONBrParser.CheckNextIdent(const AExpectedIdent: String): Boolean;
begin
  Result := (GetNextNonWhiteChar = '"') and
            (CompareText(GetNextString, AExpectedIdent) = 0) and
            (GetNextNonWhiteChar = ':');
end;

function TJSONBrParser.ParseJSONArray(out AData: TJSONBrVariantData): Boolean;
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

function TJSONBrParser.ParseJSONObject(out AData: TJSONBrVariantData): Boolean;
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
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and
    (FVKind = vkObject) then
  begin
    LFor := Cardinal(NameIndex(AName));
    if LFor < Cardinal(Length(FValues)) then
      Result := FValues[LFor];
  end;
end;

function TJSONBrVariantData.GetItem(AIndex: Integer): Variant;
begin
  VarClear(Result);
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and (FVKind = vkArray)
    then
    if Cardinal(AIndex) < Cardinal(FVCount) then
      Result := FValues[AIndex];
end;

procedure TJSONBrVariantData.SetItem(AIndex: Integer; const AItem: Variant);
begin
  if (@Self <> nil) and (FVType = JSONVariantType.VarType) and (FVKind = vkArray)
    then
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
begin
  case FVKind of
    vkObject:
      if FVCount = 0 then
        Result := '{}'
      else
      begin
        Result := '{';
        for LFor := 0 to FVCount - 1 do
          Result := Result +
                    TJSONBrObject.StringToJSON(FNames[LFor]) + ':' +
                    TJSONBrObject.ValueToJSON(FValues[LFor]) + ',';
        Result[Length(Result)] := '}';
      end;
    vkArray:
      if FVCount = 0 then
        Result := '[]'
      else
      begin
        Result := '[';
        for LFor := 0 to FVCount - 1 do
          Result := Result +
                    TJSONBrObject.ValueToJSON(FValues[LFor]) + ',';
        Result[Length(Result)] := ']';
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
  LMethod: TRttiMethod;
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

initialization
  JSONVariantType := TJSONVariant.Create;
  {$IFDEF FORMATSETTINGS}
  FSettingsUS := TFormatSettings.Create('en_US');
  {$ELSE FORMATSETTINGS}
  GetLocaleFormatSettings($0409, FSettingsUS);
  {$ENDIF FORMATSETTINGS}

end.
