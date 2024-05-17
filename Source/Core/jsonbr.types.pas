unit jsonbr.types;

interface

uses
  Rtti,
  SysUtils;

type
  EJsonBrException = class(Exception);

//  PDynamicArrayKey = ^TDynamicArrayKey;
//  TDynamicArrayKey = array[0..MaxInt div SizeOf(String) - 1] of String;
  TDynamicArrayKey = array of String;

//  PDynamicArrayValue = ^TDynamicArrayValue;
//  TDynamicArrayValue = array[0..MaxInt div SizeOf(Variant) - 1] of Variant;
  TDynamicArrayValue = array of Variant;

  IEventMiddleware = interface
    ['{5B68F8AF-40FD-4056-A75E-D93A55A5BD6D}']
    procedure SetValue(const AInstance: TObject;
                       const AProperty: TRttiProperty;
                       var AResult: Variant;
                       var ABreak: Boolean);
    procedure GetValue(const AInstance: TObject;
                       const AProperty: TRttiProperty;
                       const AValue: Variant;
                       var ABreak: Boolean);
  end;

  {$SCOPEDENUMS ON}
  TJsonTypeKind = (jtkUndefined, jtkObject, jtkArray);
  TJsonValueKind = (jvkNone, jvkNull, jvkString, jvkInteger, jvkFloat,
                    jvkObject, jvkArray, jvkBoolean);
  {$SCOPEDENUMS OFF}

  PropWrap = packed record
    FillBytes: array [0..SizeOf(pointer)-2] of Byte;
    Kind: Byte;
  end;

  TNotifyEventGetValue = procedure(const AInstance: TObject;
                                   const AProperty: TRttiProperty;
                                   var AResult: Variant;
                                   var ABreak: Boolean) of object;
  TNotifyEventSetValue = procedure(const AInstance: TObject;
                                   const AProperty: TRttiProperty;
                                   const AValue: Variant;
                                   var ABreak: Boolean) of object;

  TStringBuilderHelper = class helper for TStringBuilder
  public
    procedure ReplaceLastChar(const AChar: Char);
  end;

implementation

{ TStringBuilderHelper }

procedure TStringBuilderHelper.ReplaceLastChar(const AChar: Char);
begin
  if Self.Length > 1 then
  begin
    if Self.Chars[Self.Length - 1] = ' ' then
      Self.Remove(Self.Length - 1, 1);
    Self.Chars[Self.Length - 1] := AChar;
  end;
end;

end.
