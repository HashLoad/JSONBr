unit jsonbr.utils;

interface

uses
  StrUtils,
  DateUtils,
  SysUtils;

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: Boolean): String;
function Iso8601ToDateTime(const AValue: String;
  const AUseISO8601DateFormat: Boolean): TDateTime;

var
  GJsonBrFormatSettings: TFormatSettings;

implementation

function DateTimeToIso8601(const AValue: TDateTime;
  const AUseISO8601DateFormat: Boolean): String;
var
  LDatePart: String;
  LTimePart: String;
begin
  Result := '';
  if AValue = 0 then
    exit;

  if AUseISO8601DateFormat then
    LDatePart := FormatDateTime('yyyy-mm-dd', AValue)
  else
    LDatePart := DateToStr(AValue, GJsonBrFormatSettings);

  if Frac(AValue) = 0 then
    Result := ifThen(AUseISO8601DateFormat, LDatePart, TimeToStr(AValue, GJsonBrFormatSettings))
  else
  begin
    LTimePart := FormatDateTime('hh:nn:ss', AValue);
    Result := ifThen(AUseISO8601DateFormat, LDatePart + 'T' + LTimePart, LDatePart + ' ' + LTimePart);
  end;
end;

function Iso8601ToDateTime(const AValue: String;
  const AUseISO8601DateFormat: Boolean): TDateTime;
var
  LYYYY: Integer;
  LMM: Integer;
  LDD: Integer;
  LHH: Integer;
  LMI: Integer;
  LSS: Integer;
  LMS: Integer;
begin
  if not AUseISO8601DateFormat then
  begin
    Result := StrToDateTimeDef(AValue, 0);
    exit;
  end;
  LYYYY := 0; LMM := 0; LDD := 0; LHH := 0; LMI := 0; LSS := 0; LMS := 0;
  if TryStrToInt(Copy(AValue, 1, 4), LYYYY) and
     TryStrToInt(Copy(AValue, 6, 2), LMM) and
     TryStrToInt(Copy(AValue, 9, 2), LDD) and
     TryStrToInt(Copy(AValue, 12, 2), LHH) and
     TryStrToInt(Copy(AValue, 15, 2), LMI) and
     TryStrToInt(Copy(AValue, 18, 2), LSS) then
  begin
    Result := EncodeDateTime(LYYYY, LMM, LDD, LHH, LMI, LSS, LMS);
  end
  else
    Result := 0;
end;

initialization
  GJsonBrFormatSettings := TFormatSettings.Create('en_US');

end.
