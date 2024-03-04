program JSONBr_Exemplo;

uses
  Vcl.Forms,
  PUnit in 'PUnit.pas' {Form1},
  model.person in 'model.person.pas',
  jsonbr in '..\..\Source\jsonbr.pas',
  jsonbr.builders in '..\..\Source\Core\jsonbr.builders.pas',
  jsonbr.reader in '..\..\Source\Core\jsonbr.reader.pas',
  jsonbr.utils in '..\..\Source\Core\jsonbr.utils.pas',
  jsonbr.writer in '..\..\Source\Core\jsonbr.writer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
