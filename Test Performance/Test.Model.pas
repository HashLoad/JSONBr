unit Test.Model;

interface

uses
  System.Generics.Collections;

{$M+}

type
  TGlossDefDTO = class
  private
    FGlossSeeAlso: TArray<String>;
    FPara: string;
  published
    property GlossSeeAlso: TArray<String> read FGlossSeeAlso write FGlossSeeAlso;
    property Para: string read FPara write FPara;
  end;

  TGlossEntryDTO = class
  private
    FAbbrev: string;
    FAcronym: string;
    FGlossDef: TGlossDefDTO;
    FGlossSee: string;
    FGlossTerm: string;
    FID: string;
    FSortAs: string;
  published
    property Abbrev: string read FAbbrev write FAbbrev;
    property Acronym: string read FAcronym write FAcronym;
    property GlossDef: TGlossDefDTO read FGlossDef write FGlossDef;
    property GlossSee: string read FGlossSee write FGlossSee;
    property GlossTerm: string read FGlossTerm write FGlossTerm;
    property ID: string read FID write FID;
    property SortAs: string read FSortAs write FSortAs;
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
    FTitle: string;
  published
    property GlossList: TGlossListDTO read FGlossList write FGlossList;
    property Title: string read FTitle write FTitle;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TGlossaryDTO = class
  private
    FGlossDiv: TGlossDivDTO;
    FTitle: string;
  published
    property GlossDiv: TGlossDivDTO read FGlossDiv write FGlossDiv;
    property Title: string read FTitle write FTitle;
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
