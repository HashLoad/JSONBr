unit jsonbr.utils;

interface

uses
  SysUtils;

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: Boolean): string;
function Iso8601ToDateTime(const AValue: string;
  const AUseISO8601DateFormat: Boolean): TDateTime;

var
  JsonBrFormatSettings: TFormatSettings;

implementation

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: Boolean): string;
begin
  if AValue = 0 then
    Result := ''
  else
  if Frac(AValue) = 0 then
  begin
    if AUseISO8601DateFormat then
      Result := FormatDateTime('yyyy"-"mm"-"dd', AValue)
    else
      Result := DateToStr(AValue, JsonBrFormatSettings)
  end
  else
  if Trunc(AValue) = 0 then
  begin
    if AUseISO8601DateFormat then
      Result := FormatDateTime('"T"hh":"nn":"ss', AValue)
  else
      Result := TimeToStr(AValue, JsonBrFormatSettings)
  end
  else
  begin
    if AUseISO8601DateFormat then
      Result := FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss', AValue)
    else
      Result := DateTimeToStr(AValue, JsonBrFormatSettings);
  end;
end;

function Iso8601ToDateTime(const AValue: string;
  const AUseISO8601DateFormat: Boolean): TDateTime;
var
  LYYYY, LMM, LDD, LHH, LMI, LSS: Cardinal;
begin
  // YYYY-MM-DD   Thh:mm:ss  or  YYYY-MM-DDThh:mm:ss
  // 1234567890   123456789      1234567890123456789
  if AUseISO8601DateFormat then
    Result := StrToDateTimeDef(AValue, 0)
  else
  begin
    Result := StrToDateTimeDef(AValue, 0, JsonBrFormatSettings);
    Exit;
  end;

  case Length(AValue) of
    9:
      if (AValue[1] = 'T') and (AValue[4] = ':') and (AValue[7] = ':') then
      begin
        LHH := Ord(AValue[2]) * 10 + Ord(AValue[3]) - (48 + 480);
        LMI := Ord(AValue[5]) * 10 + Ord(AValue[6]) - (48 + 480);
        LSS := Ord(AValue[8]) * 10 + Ord(AValue[9]) - (48 + 480);
        if (LHH < 24) and (LMI < 60) and (LSS < 60) then
          Result := EncodeTime(LHH, LMI, LSS, 0);
      end;
    10:
      if (AValue[5] = AValue[8]) and (Ord(AValue[8]) in [Ord('-'), Ord('/')]) then
      begin
        LYYYY := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        LMM := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        LDD := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        if (LYYYY <= 9999) and ((LMM - 1) < 12) and ((LDD - 1) < 31) then
          Result := EncodeDate(LYYYY, LMM, LDD);
      end;
    19,25:
      if (AValue[5] = AValue[8]) and
         (Ord(AValue[8]) in [Ord('-'), Ord('/')]) and
         (Ord(AValue[11]) in [Ord(' '), Ord('T')]) and
         (AValue[14] = ':') and
         (AValue[17] = ':') then
      begin
        LYYYY := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        LMM := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        LDD := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        LHH := Ord(AValue[12]) * 10 + Ord(AValue[13]) - (48 + 480);
        LMI := Ord(AValue[15]) * 10 + Ord(AValue[16]) - (48 + 480);
        LSS := Ord(AValue[18]) * 10 + Ord(AValue[19]) - (48 + 480);
        if (LYYYY <= 9999) and ((LMM - 1) < 12) and ((LDD - 1) < 31) and (LHH < 25) and (LMI < 60) and (LSS < 60) then
          Result := EncodeDate(LYYYY, LMM, LDD) + EncodeTime(LHH, LMI, LSS, 0);
      end;
  end;
end;

initialization
  JsonBrFormatSettings := TFormatSettings.Create('en_US');

end.
