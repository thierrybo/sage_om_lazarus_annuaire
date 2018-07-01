unit commun;

interface

uses
  Classes, SysUtils,
  Objets100cLib_3_0_TLB,
  StrUtils {pour "case AnsiIndexStr"},
  Forms {pour "Application.MessageBox"},
  ComCtrls { pour FreeListViewObjects },
  LCLType { pour MB_OK + MB_ICONERROR };

procedure MessageErreur(AMessage: string);
function TypeTiers(AType: string): TiersType; overload;
function TypeTiers(AType: TiersType): String; overload;
function CaseString(AChaine: string; ATableauChaines: array of string): integer;
function ComponentToStringProc(Component: TComponent): string;
function StringToComponentProc(Value: string): TComponent;
procedure FreeListViewObjects(const AListItems: TListItems);
function SearchExactString(Items: TStrings; const Value: string;
      CaseSensitive: Boolean = True; StartIndex: Integer = -1): Integer;

implementation

procedure MessageErreur(AMessage: string);
begin
  Application.MessageBox(PChar(AMessage), 'Erreur', MB_OK + MB_ICONERROR);
end;
function CaseString(AChaine: string; ATableauChaines: array of string): integer;
begin
  { Permet d'utiliser instruction Case avec des chaines }
  Result := AnsiIndexStr(AnsiLowerCase(AChaine), ATableauChaines);
end;
function ComponentToStringProc(Component: TComponent): string;
var
  BinStream: TMemoryStream;
  StrStream: TStringStream;
  s: string;
begin
  BinStream := TMemoryStream.Create;
  try
    StrStream := TStringStream.Create(s);
    try
      BinStream.WriteComponent(Component);
      BinStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(BinStream, StrStream);
      StrStream.Seek(0, soFromBeginning);
      Result:= StrStream.DataString;
    finally
      StrStream.Free;
    end;
  finally
    BinStream.Free
  end;
end;
function StringToComponentProc(Value: string): TComponent;
var
  StrStream: TStringStream;
  BinStream: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    BinStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, BinStream);
      BinStream.Seek(0, soFromBeginning);
      Result:= BinStream.ReadComponent(nil);
    finally
      BinStream.Free;
    end;
  finally
    StrStream.Free;
  end;
end;
procedure FreeListViewObjects(const AListItems: TListItems);
var
  idx: integer;
  Temp : TObject;
begin
  for idx := 0 to Pred(AListItems.Count) do
  begin
//    Temp := TObject(AListItems.Item[idx].Data);
//    AListItems.Item[idx].Data := nil;
//    Temp.Free;

    TObject(AListItems.Item[idx].Data).Free;
    AListItems.Item[idx].Data := nil;
  end;
end;
function SearchExactString(Items: TStrings; const Value: string;
  CaseSensitive: Boolean; StartIndex: Integer): Integer;
var
  I: Integer;
  HasLooped: Boolean;
begin
{ Source JVCL class function TTJvItemsSearchs.SearchExactString }
  Result := -1;
  I := StartIndex + 1;
  HasLooped := False;
  if CaseSensitive then
  begin
    while not HasLooped or (I <= StartIndex) do
      if I >= Items.Count then
      begin
        I := 0;
        HasLooped := True;
      end
      else
      if AnsiCompareStr(Value, Items[I]) = 0 then
      begin
        Result := I;
        Exit;
      end
      else
        Inc(I);
  end
  else
  begin
    while not HasLooped or (I <= StartIndex) do
      if I >= Items.Count then
      begin
        I := 0;
        HasLooped := True;
      end
      else
      if AnsiSameText(Value, Items[I]) then
      begin
        Result := I;
        Exit;
      end
      else
        Inc(I);
  end;
end;

{$region 'Contrôles Type Tiers'}

function TypeTiers(AType: TiersType): String;
begin
  try
    case AType of
      TiersTypeAutre : Result := 'Autre';
      TiersTypeClient : Result := 'Client';
      TiersTypeFournisseur : Result := 'Fournisseur';
      TiersTypeSalarie : Result := 'Salarié';
      else raise Exception.Create('Type tiers incorrect !');
    end;
  except on E: Exception do
    begin
    MessageErreur(E.Message);
    Result := '';
    end;
  end;
end;
function TypeTiers(AType: string): TiersType;
begin
  try
    { Permet d'utiliser Case avec des Strings }
    case AnsiIndexStr(AnsiLowerCase(AType),
        ['client', 'fournisseur', 'salarié', 'autre']) of
      0 : Result := TiersTypeClient;
      1 : Result := TiersTypeFournisseur;
      2 : Result := TiersTypeSalarie;
      3 : Result := TiersTypeAutre;
      -1: raise Exception.Create('Type tiers incorrect !');
    end;
  except on E: Exception do
    begin
      MessageErreur(E.Message);
      Result := TiersTypeClient;
    end;
  end;
end;

{$endregion}

end.
