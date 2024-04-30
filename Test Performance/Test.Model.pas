unit Test.Model;

interface

uses
  System.Generics.Collections;

{$M+}

type
  TGlossDefDTO = class
  private
    FGlossSeeAlso: TArray<String>;
    FPara: String;
  published
    property GlossSeeAlso: TArray<String> read FGlossSeeAlso write FGlossSeeAlso;
    property Para: String read FPara write FPara;
  end;

  TGlossEntryDTO = class
  private
    FAbbrev: String;
    FAcronym: String;
    FGlossDef: TGlossDefDTO;
    FGlossSee: String;
    FGlossTerm: String;
    FID: String;
    FSortAs: String;
  published
    property Abbrev: String read FAbbrev write FAbbrev;
    property Acronym: String read FAcronym write FAcronym;
    property GlossDef: TGlossDefDTO read FGlossDef write FGlossDef;
    property GlossSee: String read FGlossSee write FGlossSee;
    property GlossTerm: String read FGlossTerm write FGlossTerm;
    property ID: String read FID write FID;
    property SortAs: String read FSortAs write FSortAs;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TGlossListDTO = class
  private
    FGlossEntry: TGlossEntryDTO;
  published
    property GlossEntry: TGlossEntryDTO read FGlossEntry write FGlossEntry;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TGlossDivDTO = class
  private
    FGlossList: TGlossListDTO;
    FTitle: String;
  published
    property GlossList: TGlossListDTO read FGlossList write FGlossList;
    property Title: String read FTitle write FTitle;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TGlossaryDTO = class
  private
    FGlossDiv: TGlossDivDTO;
    FTitle: String;
  published
    property GlossDiv: TGlossDivDTO read FGlossDiv write FGlossDiv;
    property Title: String read FTitle write FTitle;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TRootDTO = class
  private
    FGlossary: TGlossaryDTO;
  published
    property Glossary: TGlossaryDTO read FGlossary write FGlossary;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  
implementation

{ TGlossEntryDTO }

constructor TGlossEntryDTO.Create;
begin
  FGlossDef := TGlossDefDTO.Create;
end;

destructor TGlossEntryDTO.Destroy;
begin
  FGlossDef.Free;
  inherited;
end;

{ TGlossListDTO }

constructor TGlossListDTO.Create;
begin
  FGlossEntry := TGlossEntryDTO.Create;
end;

destructor TGlossListDTO.Destroy;
begin
  FGlossEntry.Free;
  inherited;
end;

{ TGlossDivDTO }

constructor TGlossDivDTO.Create;
begin
  FGlossList := TGlossListDTO.Create;
end;

destructor TGlossDivDTO.Destroy;
begin
  FGlossList.Free;
  inherited;
end;

{ TGlossaryDTO }

constructor TGlossaryDTO.Create;
begin
  FGlossDiv := TGlossDivDTO.Create;
end;

destructor TGlossaryDTO.Destroy;
begin
  FGlossDiv.Free;
  inherited;
end;

{ TRootDTO }

constructor TRootDTO.Create;
begin
  FGlossary := TGlossaryDTO.Create;
end;

destructor TRootDTO.Destroy;
begin
  FGlossary.Free;
  inherited;
end;

end.
