unit Horse.JsonBr;

interface

uses
  Web.HTTPApp,
  System.Classes,
  System.SysUtils,
  Horse;

type
  THorseRequestHelper = class helper for THorseRequest
  private
    class var Res: THorseResponse;
  public
    function Body<T: class, constructor>: T; overload;
  end;

function HorseJsonBr: THorseCallback; overload;
function HorseJsonBr(const ACharset: string): THorseCallback; overload;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);

implementation

uses jsonbr;

var
  Charset: string;

function HorseJsonBr: THorseCallback;
var
  LFormatSettings: TFormatSettings;
begin
  Result := HorseJsonBr('UTF-8');
  // Defina os formatos que sairam no JSON:
  LFormatSettings := TFormatSettings.Create('en_US');
//  LFormatSettings.ShortDateFormat := 'dd/MM/yyyy';
  TJSONBr.FormatSettings := LFormatSettings;
end;

function HorseJsonBr(const ACharset: string): THorseCallback;
begin
  Charset := ACharset;
  Result := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  if (Req.MethodType in [mtPost, mtPut, mtPatch]) and
     (Req.RawWebRequest.ContentType.Contains('application/jsonbr')) then
  begin
    THorseRequest.Res := Res;
  end;

  try
    Next;
  finally
    if (Res.Content <> nil) and
       (Req.RawWebRequest.ContentType.Contains('application/jsonbr')) then
    begin
      Res.RawWebResponse.Content := TJSONBr.ObjectToJsonString(Res.Content);
      Res.RawWebResponse.ContentType := 'application/json; charset=' + Charset;
    end;
    THorseRequest.Res := nil;
  end;
end;

{ THorseRequestHelper }

function THorseRequestHelper.Body<T>: T;
var
  LJSON: String;
begin
  Result := nil;

  if (MethodType in [mtPost, mtPut, mtPatch]) and
     (RawWebRequest.ContentType.Contains('application/jsonbr')) then
  begin
    LJSON := RawWebRequest.Content;
    try
      if (LJSON.StartsWith('[') and LJSON.EndsWith(']')) then
        Result := T(TJSONBr.JsonToObjectList<T>(LJSON))
      else
        Result := T(TJSONBr.JsonToObject<T>(LJSON));
    except
      Res.Send('Invalid JSON').Status(THTTPStatus.BadRequest);
      raise EHorseCallbackInterrupted.Create;
    end;
  end;
end;

end.
