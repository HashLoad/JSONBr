program JSONBr_Exemplo;

uses
  Vcl.Forms,
  PUnit in 'PUnit.pas' {Form1},
  model.person in 'model.person.pas',
  jsonbr.builders in 'D:\PROJETOS-Brasil\JSONBr\Source\Core\jsonbr.builders.pas',
  jsonbr in 'D:\PROJETOS-Brasil\JSONBr\Source\Core\jsonbr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
