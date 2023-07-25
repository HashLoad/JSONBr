unit jsonbr.utils;

interface

uses
  StrUtils,
  SysUtils;

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: Boolean): string;
function Iso8601ToDateTime(const AValue: string;
  const AUseISO8601DateFormat: Boolean): TDateTime;

var
  JsonBrFormatSettings: TFormatSettings;

implementation

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: boolean): string;
var
  LDatePart, LTimePart: string;
begin
  Result := '';
  if AValue = 0 then
    exit;
  if AUseISO8601DateFormat then
    LDatePart := FormatDateTime('yyyy-mm-dd', AValue)
  else
    LDatePart := DateToStr(AValue, JsonBrFormatSettings);
  if Frac(AValue) = 0 then
    Result := ifThen(AUseISO8601DateFormat, LDatePart, TimeToStr(AValue, JsonBrFormatSettings))
  else
  begin
    LTimePart := FormatDateTime('hh:nn:ss', AValue);
    Result := ifThen(AUseISO8601DateFormat, LDatePart + 'T' + LTimePart, LDatePart + ' ' + LTimePart);
  end;
end;

function Iso8601ToDateTime(const AValue: string;
  const AUseISO8601DateFormat: boolean): TDateTime;
var
  LYYYY, LMM, LDD, LHH, LMI, LSS: Cardinal;
begin
  if AUseISO8601DateFormat then
    Result := StrToDateTimeDef(AValue, 0)
  else
    Result := StrToDateTimeDef(AValue, 0, JsonBrFormatSettings);

  if Length(AValue) = 19 then
  begin
    LYYYY := StrToIntDef(Copy(AValue, 1, 4), 0);
    LMM := StrToIntDef(Copy(AValue, 6, 2), 0);
    LDD := StrToIntDef(Copy(AValue, 9, 2), 0);
    LHH := StrToIntDef(Copy(AValue, 12, 2), 0);
    LMI := StrToIntDef(Copy(AValue, 15, 2), 0);
    LSS := StrToIntDef(Copy(AValue, 18, 2), 0);
    if (LYYYY <= 9999) and (LMM <= 12) and (LDD <= 31) and
       (LHH < 24) and (LMI < 60) and (LSS < 60) then
      Result := EncodeDate(LYYYY, LMM, LDD) + EncodeTime(LHH, LMI, LSS, 0);
  end;
end;

initialization
  JsonBrFormatSettings := TFormatSettings.Create('en_US');

end.
