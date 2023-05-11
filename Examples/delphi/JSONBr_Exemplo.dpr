program JSONBr_Exemplo;

uses
  Vcl.Forms,
  PUnit in 'PUnit.pas' {Form1},
  model.person in 'model.person.pas',
  jsonbr.builders in '..\Source\Core\jsonbr.builders.pas',
  jsonbr in '..\Source\Core\jsonbr.pas',
  jsonbr.writer in '..\Source\Core\jsonbr.writer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
