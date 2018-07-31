unit Adapter;

{ VB :
Implémentation VB cbCtcService contient une interface :
    'Les objets 100 étant sous la forme d'ActiveX et non de composant .net,
    'il est nécessaire d'écrire des classes encapsulant une interface Objets100 pour s'en servir
    'en tant que composant .net
    'En appelant la méthode ToString(), on peut directement ajouter l'objet BOXXX dans une ComboBox
    'comme dans notre exemple...
    'Par la méthode GetInterface, on pourra récupérer directement l'objet IBOTiers du CBOTiers
    'sélectionné dans la ComboBox. }

interface

uses
  Objets100cLib_3_0_TLB;

type
  TControlObjet100 = class
    private FPersistObject: IBIPersistObject;
    public
      constructor Create(AObj: IBIPersistObject);
      function GetObject: IBIPersistObject; virtual;
      function ToString: String; virtual;
  end;

//  TCBODevise = class(TControlObjet100)
//    public
//      function ToString: String; virtual;
//      function GetInterface: IBPDevise2; virtual;
//  end;

  TCBPService = class(TControlObjet100)
    public
      function ToString: String; virtual;
      function GetInterface: IBPServiceContact; virtual;
  end;

  TTiersContact = class(TControlObjet100)
    public
      function GetOID: IBIObjectID; virtual;
      function GetInterface: IBIContact2; virtual;
  end;

implementation

{$region 'Classe Maîtresse'}

{ TControlObjet100 }

constructor TControlObjet100.Create(AObj: IBIPersistObject);
begin
  FPersistObject := AObj;
end;

function TControlObjet100.GetObject: IBIPersistObject;
begin
  Result := FPersistObject;
end;

function TControlObjet100.ToString: String;
begin
  result := '';
end;

{$endregion}

{$region 'Classe Tiers'}


{$endregion}

{$region 'Classe Devise'}

{ TCBODevise }

{ Je ne l'ai pas utilisé pour Delphi :
Stocké directement la chaine D_Intitule plutôt que de mettre un objet CBODevise
contenant un IBPDevise2, j'avais toujours des erreurs.
En mettant directement une chaîne, plus simple à gérer, et à partir
de l'intitulé en sortie on peut recréer l'objet IBPDevise2
}

//function TCBODevise.ToString: String;
//begin
//  Result := GetInterface.D_Intitule;
//end;
//
//function TCBODevise.GetInterface: IBPDevise2;
//begin
//  Result := GetObject() as IBPDevise2;
//end;

{$endregion}

{$region 'Classe Service'}

{ TCBPService }

function TCBPService.ToString: String;
begin
  Result := GetInterface.S_Intitule;
end;

function TCBPService.GetInterface: IBPServiceContact;
begin
  Result := GetObject() as IBPServiceContact;
end;

{$endregion}

{$region 'Classe TiersContact'}

{ TTiersContact }

function TTiersContact.GetOID: IBIObjectID;
begin
  Result := GetInterface.OID;
end;

function TTiersContact.GetInterface: IBIContact2;
begin
  Result := GetObject() as IBIContact2;
end;

{$endregion}

end.
