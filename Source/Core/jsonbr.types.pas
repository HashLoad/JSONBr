unit jsonbr.types;

interface

uses
  SysUtils;

type
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
