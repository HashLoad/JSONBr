program Samples;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  DB,
  Horse,
  JSON,
  Horse.JsonBr;

type
  TMyClass = class
  private
    FName: String;
  public
    property Name: String read FName write FName;
  end;

var
  F: TMyClass;
begin
  ReportMemoryLeaksOnShutdown := True;

  THorse.Use(HorseJsonBr);

  THorse.Get('/method',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LObj: TMyClass;
    begin
      LObj := TMyClass.Create;
      LObj.Name := 'JSONBr Middleware for Horse Demonstração';
      Res.Send<TMyClass>(LObj);
    end);

  THorse.Post('/method',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LObj: TMyClass;
    begin
      LObj := Req.Body<TMyClass>;
      Res.Send(LObj.Name).Status(THTTPStatus.BadRequest);
    end);

  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor Rodando...');
    end);
end.
