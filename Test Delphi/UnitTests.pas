unit UnitTests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestJSONBr = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // Sample Methods
    // Simple single Test
    [Test]
    procedure TestAddPair_1;
    [Test]
    procedure TestAddValue_1;
    [Test]
    procedure TestObject_Empty;
    [Test]
    procedure TestArray_Empty;
  end;

implementation

uses
  jsonbr;

procedure TTestJSONBr.Setup;
begin
end;

procedure TTestJSONBr.TearDown;
begin
end;

procedure TTestJSONBr.TestAddPair_1;
var
  LResult: String;
const
  LJSON = '[{"ID":1,"Name":"Json"},[{"ID":2,"Name":"Json 2"},{"ID":3,"Name":"Json 3"}]]';
begin
  LResult := TJSONBr
               .BeginArray
                 .BeginObject
                   .AddPair('ID', 1)
                   .AddPair('Name', 'Json')
                 .EndObject
                 .BeginArray
                   .BeginObject
                     .AddPair('ID', 2)
                     .AddPair('Name', 'Json 2')
                   .EndObject
                   .BeginObject
                     .AddPair('ID', 3)
                     .AddPair('Name', 'Json 3')
                   .EndObject
                 .EndArray
               .EndArray
             .ToJSON;

  Assert.AreEqual(LResult, LJSON, 'Não gerou conforme valor da constante!');
end;

procedure TTestJSONBr.TestAddValue_1;
var
  LResult: String;
const
  LJSON = '{"nome":"Fulano","idade":90,"filmes_preferidos":["Pulp Fiction","Clube da Luta"],"contatos":{"telefone":"(11)91111-2222","emails":["fulano@gmail.com","fulano@yahoo.com"]}}';
begin
  LResult := TJSONBr
              .BeginObject
                .AddPair('nome', 'Fulano')
                .AddPair('idade', 90)
                .AddPairArray('filmes_preferidos', ['Pulp Fiction', 'Clube da Luta'])
                .BeginObject('contatos')
                  .AddPair('telefone', '(11)91111-2222')
                  .AddPairArray('emails', ['fulano@gmail.com', 'fulano@yahoo.com'])
                .EndObject
              .EndObject
            .ToJSON;

  Assert.AreEqual(LResult, LJSON, 'Não gerou conforme valor da constante!');
end;

procedure TTestJSONBr.TestArray_Empty;
var
  LResult: String;
const
  LJSON = '[]';
begin
  LResult := TJSONBr
               .BeginArray
               .EndArray
             .ToJSON;

  Assert.AreEqual(LResult, LJSON, 'Não gerou conforme valor da constante!');
end;

procedure TTestJSONBr.TestObject_Empty;
var
  LResult: String;
const
  LJSON = '{}';
begin
  LResult := TJSONBr
               .BeginObject
               .EndObject
             .ToJSON;

  Assert.AreEqual(LResult, LJSON, 'Não gerou conforme valor da constante!');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestJSONBr);

end.
