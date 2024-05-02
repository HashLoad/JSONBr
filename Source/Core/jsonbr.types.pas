unit jsonbr.types;

interface

uses
  Rtti,
  SysUtils;

type
  EJsonBrException = class(Exception);
  TDynamicArrayKey = array of String;
  TDynamicArrayValue = array of Variant;

  TStringBuilderHelper = class helper for TStringBuilder
  public
    procedure ReplaceLastChar(const AChar: Char);
  end;

  TJsonTypeKind = (jtkUndefined, jtkObject, jtkArray);
  TJsonValueKind = (jvkNone, jvkNull, jvkString, jvkInteger, jvkFloat,
                    jvkObject, jvkArray, jvkBoolean);

  PropWrap = packed record
    FillBytes: array [0..SizeOf(pointer)-2] of byte;
    Kind: byte;
  end;

  TNotifyEventGetValue = procedure(const AInstance: TObject;
                                   const AProperty: TRttiProperty;
                                   var AResult: Variant;
                                   var ABreak: Boolean) of object;
  TNotifyEventSetValue = procedure(const AInstance: TObject;
                                   const AProperty: TRttiProperty;
                                   const AValue: Variant;
                                   var ABreak: Boolean) of object;
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
