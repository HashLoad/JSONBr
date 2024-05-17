program JSONBr_Exemplo;

uses
  Vcl.Forms,
  PUnit in 'PUnit.pas' {Form1},
  jsonbr in '..\..\Source\jsonbr.pas',
  model.person in 'model.person.pas',
  jsonbr.reader in '..\..\Source\Reader\jsonbr.reader.pas',
  jsonbr.writer in '..\..\Source\Writer\jsonbr.writer.pas',
  jsonbr.builders in '..\..\Source\Core\jsonbr.builders.pas',
  jsonbr.types in '..\..\Source\Core\jsonbr.types.pas',
  jsonbr.utils in '..\..\Source\Core\jsonbr.utils.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
