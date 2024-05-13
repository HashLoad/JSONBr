unit PUnit;

interface

uses
  DB, Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Rtti,

  jsonbr;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  model.person;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  // Criar JSON de forma funcinal
  Memo1.Clear;
  Memo1.Lines.Add(
                  TJsonBr
                   .BeginArray
                     .BeginObject('object0')
                       .Add('ID', 1)
                       .Add('Name', 'Json')
                     .EndObject
                     .BeginArray
                       .BeginObject('object1')
                         .Add('ID', 2)
                         .Add('Name', 'Json 2')
                       .EndObject
                       .BeginObject('object2')
                         .Add('ID', 3)
                         .Add('Name', 'Json 3')
                         .Add('Salary', 111.50)
                         .AddDate('Date', Now)
                         .Add('Active', True)
                         .AddNull('Nulo', Null)
                       .EndObject
                     .EndArray
                   .EndArray
                  .ToJSON);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Person: TPerson;
  Person1: TpersonSub;
  Person2: TpersonSub;
begin
  Person := TPerson.Create;
  try
    Person.Id := 1;
    Person.FirstName := '';
    Person.LastName := 'Json';
    Person.Age := 10;
    Person.Salary := 100.10;
    Person.Date := Now;

    Person.Pessoa.Id := 2;
    Person.Pessoa.FirstName := 'Json 2';
    Person.Pessoa.LastName := 'Parse 2';
    Person.Pessoa.Age := 20;
    Person.Pessoa.Salary := 200.20;
    Person.Imagem := '12345678901234567890';

    Person1 := TPersonSub.Create;
    Person1.Id := 3;
    Person1.FirstName := 'Json 3';
    Person1.LastName := 'Parse 3';
    Person1.Age := 30;
    Person1.Salary := 300.30;

    Person2 := TPersonSub.Create;
    Person2.Id := 4;
    Person2.FirstName := 'Json 4';
    Person2.LastName := 'Parse 4';
    Person2.Age := 40;
    Person2.Salary := 400.40;

    Person.Pessoas.Add(Person1);
    Person.Pessoas.Add(Person2);

    TJsonBr.OnSetValue := nil; // Criando seu proprio tratamento
    TJsonBr.OnGetValue := nil; // Criando seu proprio tratamento
    Memo1.Lines.Text := TJsonBr.ObjectToJsonString(Person);

  finally
    Person.Free;
  end;
end;

end.
