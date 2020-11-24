unit JSONBr_Tests;

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

initialization
  TDUnitX.RegisterTestFixture(TTestJSONBr);

end.
