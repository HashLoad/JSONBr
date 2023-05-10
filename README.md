# JSONBr Library for Delphi

JSON BRASIL é uma library opensource que provê escritas arquivos JSON, de forma funcional e orientada a objeto, além dos recursos de gerar um JSON de um objeto e popular o objeto com base em um arquivo JSON, seu diferencial são os eventos onGetValue() e onSetValue() que dão a dinâmica de tratar seu próprio tipo de campo, alimentado assim o JSON e lendo esse campo dele.

Essa classe estava enraizada ao projeto ORMBr, nela foi feito vários testes em questão de performance, o qual ela se saiu muito bem com as que foi confrontada, visto isso, foi visto a possibilidade de ser uma library independente, que pudesse ser usado até mesmo por outros projetos opensource, mas para isso, o primeiro passo a ser dado seria remover qualquer vínculo com framework ORMBr, então com um pouco de esforço e tempo de dedicação, nasceu o JSONBr.

A cereja do bolo desse projeto é a dinâmica que ele oferece para outros projetos tratar seus tipos de campos criados, através dos dois eventos onGetValue e onSetValue, esses eventos quando usados intercepta o dado do evento interno, possibilitando assim, a verificação do tipo e o tratamento do valor do campo e como ele deve ser aplicado na tag no arquivo

<p align="center">
  <a href="https://www.isaquepinheiro.com.br">
    <img src="https://www.isaquepinheiro.com.br/projetos/jsonbr-framework-for-delphi-opensource-95504.png" width="200" height="200">
  </a>
</p>

## 🏛 Delphi Versions
Embarcadero Delphi XE e superior.

## ⚙️ Instalação
Instalação usando o [`boss install`]
```sh
boss install "https://github.com/HashLoad/jsonbr"
```

## ⚡️ Como usar

```Delphi
procedure TTestJSONBr.Loop50000;
var
  LList: TObjectList<TRootDTO>;
  LObject: TRootDTO;
  LFor: Integer;
  LInit, LEnd: Cardinal;
begin
  LList := TObjectList<TRootDTO>.Create;
  LList.OwnsObjects := True;
  try
    LInit := GetTickCount;
    for LFor := 1 to SAMPLE_JSON_1_COUNT do
    begin
      LObject := TJSONBr.JsonToObject<TRootDTO>(SAMPLE_JSON_1);
      LList.Add(LObject);
    end;
    LEnd := GetTickCount;
    //
    System.Writeln(Format('..gerando 50.000 objetos de um json object(' + 
                             cMESSAGE, [(LEnd - LInit) / 1000, (LEnd - LInit)]) + ')');
  finally
    LList.Clear;
    LList.Free;
  end;
end;
```

```Delphi
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

    TJSONBr.OnSetValue := nil; // Criando seu proprio tratamento de tipos
    TJSONBr.OnGetValue := nil; // Criando seu proprio tratamento de tipos
    Memo1.Lines.Text := TJSONBr.ObjectToJsonString(Person);

  finally
    Person.Free;
  end;
end;
```

```Delphi
procedure TTestJSONBr.AddPair_1;
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
end;
```

```Delphi
procedure TTestJSONBr.AddValue_1;
var
  LResult: String;
const
  LJSON = '{"nome":"Fulano","idade":90,"filmes_preferidos":["Pulp Fiction","Clube da Luta"],"contatos"
  :{"telefone":"(11)91111-2222","emails":["fulano@gmail.com","fulano@yahoo.com"]}}';
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
end;
```

## ✍️ License
[![License](https://img.shields.io/badge/Licence-LGPL--3.0-blue.svg)](https://opensource.org/licenses/LGPL-3.0)

## ⛏️ Contribuição

Nossa equipe adoraria receber contribuições para este projeto open source. Se você tiver alguma ideia ou correção de bug, sinta-se à vontade para abrir uma issue ou enviar uma pull request.

[![Issues](https://img.shields.io/badge/Issues-channel-orange)](https://github.com/HashLoad/ormbr/issues)

Para enviar uma pull request, siga estas etapas:

1. Faça um fork do projeto
2. Crie uma nova branch (`git checkout -b minha-nova-funcionalidade`)
3. Faça suas alterações e commit (`git commit -am 'Adicionando nova funcionalidade'`)
4. Faça push da branch (`git push origin minha-nova-funcionalidade`)
5. Abra uma pull request

## 📬 Contato
[![Telegram](https://img.shields.io/badge/Telegram-channel-blue)](https://t.me/hashload)

## 💲 Doação
[![Doação](https://img.shields.io/badge/PagSeguro-contribua-green)](https://pag.ae/bglQrWD)
