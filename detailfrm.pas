unit detailfrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, StdCtrls, ExtCtrls,
  Objets100cLib_3_0_TLB,
  listetiersfrm;

type

  { TDetailForm }

  TDetailForm = class(TForm)
    pgcTiers: TPageControl;
    tshCoord: TTabSheet;
    tshBanque: TTabSheet;
    tshContact: TTabSheet;
    lblNum: TLabel;
    lblTxtNum: TLabel;
    lblTypeTiers: TLabel;
    ledtIntitule: TLabeledEdit;
    ledtContact: TLabeledEdit;
    gb1: TGroupBox;
    gb2: TGroupBox;
    ledtAdresse: TLabeledEdit;
    ledtComplement: TLabeledEdit;
    ledtCP: TLabeledEdit;
    ledtVille: TLabeledEdit;
    ledtRegion: TLabeledEdit;
    ledtPays: TLabeledEdit;
    ledtTelephone: TLabeledEdit;
    ledtTelecopie: TLabeledEdit;
    ledtEMail: TLabeledEdit;
    ledtSite: TLabeledEdit;
    lblType: TLabel;
    lbl32: TLabel;
    lbl33: TLabel;
    lbl34: TLabel;
    ledtBqIntitule: TLabeledEdit;
    ledtBqCode: TLabeledEdit;
    ledtBqGuichet: TLabeledEdit;
    ledtBqNumCpte: TLabeledEdit;
    ledtBqCle: TLabeledEdit;
    ledtBqCommentaire: TLabeledEdit;
    chkBqPrincipale: TCheckBox;
    cbBqDevise: TComboBox;
    lbl13: TLabel;
    btnBqValider: TButton;
    lbl19: TLabel;
    lbl20: TLabel;
    lbl21: TLabel;
    lbl22: TLabel;
    lbl23: TLabel;
    lbl26: TLabel;
    cbCivilite: TComboBox;
    cbCtcService: TComboBox;
    edtCtcNom: TEdit;
    ledtCtcPrenom: TLabeledEdit;
    ledtCtcFonction: TLabeledEdit;
    gbCtc: TGroupBox;
    lbl30: TLabel;
    ledtCtcTel: TLabeledEdit;
    ledtCtcPortable: TLabeledEdit;
    ledtCtcCopie: TLabeledEdit;
    ledtCtcMail: TLabeledEdit;
    btnCtcVald: TButton;
    pmMnuBqe: TPopupMenu;
    pmMnuCtc: TPopupMenu;
    lvContact: TListView;
    lvBanque: TListView;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lvBanqueSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvContactSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure pgcTiersChange(Sender: TObject);
    procedure btnBqValiderClick(Sender: TObject);
    procedure btnCtcValdClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
    F_Origine       : TListeTiersForm;
    FiOpen          : Integer;
    FBaseCpta       : BSCPTAApplication100c;
    FTiersCourant   : IBOTiers3;
    FBanqueCourante : IBOTiersBanque3;
    FTiersContact   : IBIContact2;
    FContactCourant : IBIContact2;
    procedure InitForm; virtual;
    procedure InitListeBanque; virtual;
    procedure InitSaisieBanque; virtual;
    procedure InitContact; virtual;
    procedure InitTxtContact; virtual;
    procedure CreeBanque(Sender: TObject); virtual;
    procedure SuppBanque(Sender: TObject); virtual;
    procedure CreateCtc(Sender: TObject); virtual;
    procedure DelCtc(Sender: TObject); virtual;
    function CiviliteContact(Civilite: String): ContactCivilite; overload; virtual;
    function CiviliteContact(AiType: ContactCivilite): String; overload; virtual;
  public
    { Déclarations publiques }
    constructor Create(AOwner: TComponent; var ATiers: IBOTiers3);
    class var FDetailForm: TDetailForm;
  end;

implementation

uses commun, mainfrm { pour accéder aux menus }, Adapter ;

{$R *.lfm}

{ TDetailForm }

{$region 'Events Frm'}

constructor TDetailForm.Create(AOwner: TComponent; var ATiers: IBOTiers3);
begin
  inherited Create(AOwner);
  F_Origine     := TListeTiersForm(AOwner);
  FTiersCourant := ATiers;
  FBaseCpta     := ATiers.Stream as IBSCPTAApplication3;
  Screen.Cursor := crDefault;
end;

procedure TDetailForm.FormShow(Sender: TObject);
begin
  InitForm();
  InitListeBanque();
  InitSaisieBanque();
  InitContact();
  inc(FiOpen);
  pgcTiersChange(Self);
end;

procedure TDetailForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  try
    with FTiersCourant do
    begin
      CT_Intitule        := ledtIntitule.Text;
      CT_Contact         := ledtContact.Text;
      Adresse.Adresse    := ledtAdresse.Text;
      Adresse.Complement := ledtComplement.Text;
      Adresse.CodePostal := ledtCP.Text;
      Telecom.EMail      := ledtEMail.Text;
      Adresse.CodeRegion := ledtRegion.Text;
      Telecom.Site       := ledtSite.Text;
      Telecom.Telecopie  := ledtTelecopie.Text;
      Telecom.Telephone  := ledtTelephone.Text;
      Adresse.Ville      := ledtVille.Text;
      Adresse.Pays       := ledtPays.Text;
      SetDefault();
      WriteDefault();
    end;
    F_Origine.InitListe();
    CloseAction := caFree;
    FDetailForm := nil;
  except on E: Exception do
    begin
      MessageErreur(E.Message);
      CloseAction := caFree;
    end;
  end;
end;

procedure TDetailForm.InitForm;
begin
  try
    { Pour être sur que le premier onglet soit sélectionné sinon enregistre le
      dernier onglet sélectionné en mode conception comme onglet actif }
    pgcTiers.ActivePage := tshCoord;
    if assigned(FTiersCourant) then
    begin
      with FTiersCourant do
      begin
        Caption               := 'Tiers : ' + CT_Intitule;
        lblNum.Caption        := CT_Num;
        lblTypeTiers.Caption  := TypeTiers(CT_Type);
        ledtIntitule.Text     := CT_Intitule;
        ledtContact.Text      := CT_Contact;
        ledtAdresse.Text      := Adresse.Adresse;
        ledtComplement.Text   := Adresse.Complement;
        ledtContact.Text      := CT_Contact;
        ledtCP.Text           := Adresse.CodePostal;
        ledtEMail.Text        := Telecom.EMail;
        ledtRegion.Text       := Adresse.CodeRegion;
        ledtSite.Text         := Telecom.Site;
        ledtTelecopie.Text    := Telecom.Telecopie;
        ledtTelephone.Text    := Telecom.Telephone;
        ledtVille.Text        := Adresse.Ville;
        ledtPays.Text         := Adresse.Pays;
      end;
    end else begin
      Close();
    end;
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

procedure TDetailForm.pgcTiersChange(Sender: TObject);
begin
  // Necessaire sous Lazarus sinon erreur "Class 'TMenuItem' not found" à l'éxécution
  // http://forum.lazarus-ide.org/index.php?topic=42047.msg292872
  RegisterClass(TMenuItem);
  case pgcTiers.TabIndex of
//    0 : ;  { Coordonnées }
    1 :  { Banque }
      begin
        MainForm.mmiEditionNouveau.OnClick := @Self.CreeBanque;
        Mainform.mmiEditionSupp.OnClick    := @Self.SuppBanque;
        pmMnuBqe.Items.Clear();
        pmMnuBqe.Items.Add(CloneMenuItem(MainForm.mmiEditionNouveau));
        pmMnuBqe.Items.Add(CloneMenuItem(MainForm.mmiEditionSupp));
        { J'ai affecté le menu en conception }
//        lvBanque.PopupMenu := pmMnuBqe;
      { Delphi/Lazarus qu'un seul bouton Valider par défaut PAR FORM, il faut donc le changer quand on change de tab }
      btnBqValider.Default := True;
      end;
    2 :  { Contact }
      begin
        MainForm.mmiEditionNouveau.OnClick := @Self.CreateCtc;
        Mainform.mmiEditionSupp.OnClick    := @Self.DelCtc;
        pmMnuCtc.Items.Clear();
        pmMnuCtc.Items.Add(CloneMenuItem(MainForm.mmiEditionNouveau));
        pmMnuCtc.Items.Add(CloneMenuItem(MainForm.mmiEditionSupp));
        { J'ai affecté le menu en conception }
//        lvContact.PopupMenu := pmMnuCtc;
        { Delphi/Lazarus qu'un seul bouton Valider par défaut PAR FORM, il faut donc le changer quand on change de tab }
        btnCtcVald.Default := true;
      end;
  end;
  { TODO : A priori ne sert à rien !? }
  inc(FiOpen);
end;

procedure TDetailForm.FormDestroy(Sender: TObject);
begin
  { TODO :
A priori pas besoin de libérer les objets associés aux combos, ne généère
pas de leak ? }
  FreeListViewObjects(LvContact.Items);
end;

{$endregion}

{$region 'Méthodes Banques'}

procedure TDetailForm.btnBqValiderClick(Sender: TObject);
begin
  try
    If not assigned(FBanqueCourante) Then
      FBanqueCourante := FTiersCourant.FactoryTiersBanque.Create() as IBOTiersBanque3;
    With FBanqueCourante do
    begin
      BT_Struct       := RibTypeLocal;
      BT_Intitule     := ledtBqIntitule.Text;
      { TODO : .Devise = Me.cmbBqDevise.SelectedItem.GetInterface }
//      Devise          := IBPDevise2(cbBqDevise.Text);
//      Devise          := IBPDevise2(cbBqDevise.Items[cbBqDevise.ItemIndex]);
//      Devise          := (cbBqDevise.Items.Objects[cbBqDevise.ItemIndex] as
//                          TCBODevise).GetInterface;
      Devise          := FBaseCpta.FactoryDevise.ReadIntitule(cbBqDevise.
                          Items[cbBqDevise.ItemIndex]);
      BT_Banque       := ledtBqCode.Text;
      BT_Guichet      := ledtBqGuichet.Text;
      BT_Compte       := ledtBqNumCpte.Text;
      BT_Cle          := ledtBqCle.Text;
      BT_Commentaire  := ledtBqCommentaire.Text;
      SetDefault();
      WriteDefault();
    End;
    If chkBqPrincipale.Checked Then
    begin
      FTiersCourant.BanquePrincipale := FBanqueCourante;
      FTiersCourant.Write_();
    End;
    InitListeBanque();
    InitSaisieBanque();
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

procedure TDetailForm.InitListeBanque;
var I : Integer;
begin
  try
    lvBanque.Items.BeginUpdate();
    lvBanque.Items.Clear();
    with FTiersCourant.FactoryTiersBanque.List do
    begin
      if Count > 0 then
      begin
        for I := 1 to Count do
        begin
          with lvBanque.Items.Add() do
          begin
            Caption := (Item[I] as IBOTiersBanque3).BT_Intitule;
            SubItems.Add(
                (Item[I] as IBOTiersBanque3).BT_Banque +
                ' ' +
                (Item[I] as IBOTiersBanque3).BT_Guichet +
                ' ' +
                (Item[I] as IBOTiersBanque3).BT_Compte +
                ' ' +
                (Item[I] as IBOTiersBanque3).BT_Cle);
            SubItems.Add((Item[I] as IBOTiersBanque3).Devise.D_Intitule);
          end;
        end;
      end;
    end;
    lvBanque.Items.EndUpdate();
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

procedure TDetailForm.InitSaisieBanque;
var
  I : Integer;
begin
  try
    with FBaseCpta.FactoryDevise.List do
    begin
      for I := 1 to Count do
{ Me.cmbBqDevise.Items.Add(New CBODevise(CDevise))
Stocké directement la chaine D_Intitule plutôt que de mettre un objet CBODevise
contenant un IBPDevise2, j'avais toujours des erreurs.
En mettant directement une chaîne, plus simple à gérer, et à partir
de l'intitulé en sortie on peut recréer l'objet IBPDevise2
}
//        CBODevise := TCBODevise.Create(Item[I] as IBPDevise2);
//        try
//          cbBqDevise.Items.AddObject(CBODevise.ToString, CBODevise);
//        finally
//          CBODevise.Free;
//        end;

      cbBqDevise.Items.Add((Item[I]as IBPDevise2).D_Intitule);
    end;
    {
     Comme pour la liste des tiers qui ne récupérait pas l'index de sélection apres fermeture du tiersdetail
     (object nil), obligé par rapport à Delphi de tester Assigned(lvBanque.Selected). Pas grave qu'aucune banque ne
     soit sélectionnée car on recliquera dessus.
    }
    if (lvBanque.SelCount = 1) and (Assigned(lvBanque.Selected)) then
    begin
      FBanqueCourante         := (
          FTiersCourant.FactoryTiersBanque.List.Item[lvBanque.selected.Index + 1]
          ) as IBOTiersBanque3;
      if cbBqDevise.Items.Count > 0 then
//        cbBqDevise.ItemIndex  := cbBqDevise.SearchExactString(
//            FBanqueCourante.Devise.D_Intitule, False);
        cbBqDevise.ItemIndex  := SearchExactString(cbBqDevise.Items,
            FBanqueCourante.Devise.D_Intitule, False);
      ledtBqIntitule.Text     := FBanqueCourante.BT_Intitule;
      chkBqPrincipale.Checked := (FTiersCourant.BanquePrincipale = FBanqueCourante);
      ledtBqCode.Text         := FBanqueCourante.BT_Banque;
      ledtBqGuichet.Text      := FBanqueCourante.BT_Guichet;
      ledtBqNumCpte.Text      := FBanqueCourante.BT_Compte;
      ledtBqCle.Text          := FBanqueCourante.BT_Cle;
      ledtBqCommentaire.Text  := FBanqueCourante.BT_Commentaire;
    end else begin
      FBanqueCourante := nil;
      If cbBqDevise.Items.Count > 0 Then cbBqDevise.ItemIndex := 0;
      ledtBqIntitule.Clear();
      chkBqPrincipale.Checked := False;
      ledtBqCode.Clear();
      ledtBqGuichet.Clear();
      ledtBqNumCpte.Clear();
      ledtBqCle.Clear();
      ledtBqCommentaire.Clear();
    end;
    chkBqPrincipale.Enabled := Not chkBqPrincipale.Checked;
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

procedure TDetailForm.lvBanqueSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  InitSaisieBanque();
end;

procedure TDetailForm.CreeBanque(Sender: TObject);
begin
  FBanqueCourante := nil;
  InitListeBanque();
  InitSaisieBanque();
end;

procedure TDetailForm.SuppBanque(Sender: TObject);
begin
  try
    if assigned(FBanqueCourante) then
    begin
      { Pour éviter message 'Impossible de trouver la procédure stockée
        'CB_Prev' lors du Remove si Write préalable. }
      FBanqueCourante.Read_();
      FBanqueCourante.Remove();
      InitListeBanque();
      InitSaisieBanque();
    end;
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

{$endregion}

{$region 'Méthodes Contacts'}

procedure TDetailForm.CreateCtc(Sender: TObject);
begin
  FContactCourant := nil;
  InitTxtContact();
  edtCtcNom.SetFocus();
end;

procedure TDetailForm.DelCtc(Sender: TObject);
begin
  try
    If assigned(FContactCourant) Then
    begin
      FContactCourant.Read_();
      FContactCourant.Remove();
      InitContact();
    end;
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

procedure TDetailForm.InitContact;
var
  I             : Integer;
  IbiColContact : IBICollection;
  Objet : TObject;
begin
  try
    { Libérer les objets associés du ListView avant d'en affecter de nouveau,
      sinon leak. }
    FreeListViewObjects(LvContact.Items);
    lvContact.Clear();
    for i := 0 to 3 do
    begin
      with lvContact.Columns.Add() do
      begin
        Caption   := '';
        Width     := 96;
        Alignment := taLeftJustify;
      end;
    end;
    { Ne sert plus à rien vu qu'en Delphi je réutilise I pour la boucle }
//    I := 0;
    IbiColContact := FBaseCpta.FactoryTiers.ReadNumero(
        FTiersCourant.CT_Num).FactoryTiersContact.List;
    for I := 1 to IbiColContact.Count do
    begin
      with (IbiColContact.Item[I] as IBIContact2) do
      begin
        { Contrairement à VB je suis obligé de passer par un Objet Delphi
          (TTiersContact) pour stocker l'OID de l'IBIContact2 }
//        LvContact.AddItem(Nom, TObject(OID) );
        LvContact.AddItem(Nom, TTiersContact.Create(IbiColContact.Item[I] as IBIContact2));
        LvContact.Items[I - 1].ImageIndex := I - 1;
        LvContact.Items[I - 1].SubItems.Add(Fonction);
        LvContact.Items[I - 1].SubItems.Add(Telecom.Telephone);
        LvContact.Items[I - 1].SubItems.Add(Telecom.Portable);
      end;
    end;
    FContactCourant := nil;
    InitTxtContact();
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

procedure TDetailForm.InitTxtContact;
var
  i: integer;
  CBPService : TCBPService;
begin
  ledtCtcCopie.Text     := '';
  ledtCtcFonction.Text  := '';
  ledtCtcMail.Text      := '';
  edtCtcNom.Text        := '';
  ledtCtcPortable.Text  := '';
  ledtCtcPrenom.Text    := '';
  ledtCtcTel.Text       := '';
  cbCtcService.Items.Clear();
  with FBaseCpta.FactoryServiceContact.List do
  begin
    for i := 1 to Count do
    begin
      CBPService := TCBPService.Create(Item[I] as IBPServiceContact);
      try
        cbCtcService.Items.AddObject(CBPService.ToString, CBPService);
      finally
        CBPService.Free;
      end;
    end;
  end;
  cbCtcService.ItemIndex := 0;
  cbCivilite.Items.Clear();
  cbCivilite.Items.Add('M.');
  cbCivilite.Items.Add('Mme');
  cbCivilite.Items.Add('Mlle');
  cbCivilite.ItemIndex := 0;
end;

procedure TDetailForm.lvContactSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  ObjectID : IBIObjectID;
begin
  InitTxtContact();
  if (lvContact.SelCount > 0) and (Assigned(lvContact.Selected)) then
  begin
    { VB :
Me.ContactCourant = BaseCpta.FactoryTiers.ReadNumero(Me.TiersCourant.CT_Num)
.FactoryTiersContact.Read(Me.LvContact.SelectedItems(0).Tag) }

//    ObjectID := IBIObjectID(lvContact.Selected.Data);
//    FContactCourant := FBaseCpta.FactoryTiers.ReadNumero(FTiersCourant.CT_Num)
//        .FactoryTiersContact.Read(ObjectID) as IBIContact2;

    { Passé par un objet TTiersContact (n'existait en VB) }
    ObjectID := TTiersContact(lvContact.Selected.Data).GetOID;
    FContactCourant := FBaseCpta.FactoryTiers.ReadNumero(FTiersCourant.CT_Num)
        .FactoryTiersContact.Read_(ObjectID) as IBIContact2;
    with FContactCourant do
    begin
      edtCtcNom.Text       := Nom;
      ledtCtcPrenom.Text   := Prenom;
      ledtCtcFonction.Text := Fonction;
      ledtCtcTel.Text      := Telecom.Telephone;
      ledtCtcPortable.Text := Telecom.Portable;
      ledtCtcCopie.Text    := Telecom.Telecopie;
      ledtCtcMail.Text     := Telecom.EMail;

      { VB:
        Me.cbCtcService.Text = New CBPService(.ServiceContact).ToString
        Je n'ai pas réussi enutilisant l'objet CBPService, mais pas besoin }
//      CBPService       := TCBPService.Create(FContactCourant.ServiceContact);
//      try
//        cbCtcService.ItemIndex := cbCtcService.Items.IndexOf(CBPService.ToString);
//      finally
//        CBPService.Free;
//      end;
      cbCtcService.ItemIndex    := cbCtcService.Items.IndexOf(ServiceContact.
                                   S_Intitule);
      cbCivilite.Text   := CiviliteContact(Civilite);
    end;
  end else
    FContactCourant := nil;
end;

procedure TDetailForm.btnCtcValdClick(Sender: TObject);
begin
  try
    if not assigned(FContactCourant) then
      FContactCourant := FTiersCourant.FactoryTiersContact.Create() as IBIContact2;
    With FContactCourant do
    begin
      Nom       := edtCtcNom.Text;
      Prenom    := ledtCtcPrenom.Text;
      Fonction  := ledtCtcFonction.Text;
      { VB:
      .ServiceContact = Me.cbCtcService.SelectedItem.GetInterface
      Je n'ai pas réussit en passant par CBPService }
//      ServiceContact  := IBPServiceContact(cbCtcService.Items[cbCtcService.ItemIndex]);
//      ServiceContact  := (cbCtcService.Items.Objects[cbCtcService.ItemIndex] as
//                          TCBPService).GetInterface;
      ServiceContact  := FContactCourant.ServiceContact.FactoryServiceContact.
                          ReadIntitule(cbCtcService.Items[cbCtcService.ItemIndex]);
      Telecom.Telephone := ledtCtcTel.Text;
      Telecom.Telecopie := ledtCtcCopie.Text;
      Telecom.Portable  := ledtCtcPortable.Text;
      Telecom.EMail     := ledtCtcMail.Text;
      Civilite          := CiviliteContact(cbCivilite.Text);
      SetDefault();
      WriteDefault();
    end;
    FContactCourant.Read_();
    FContactCourant := nil;
    InitContact();
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

function TDetailForm.CiviliteContact(Civilite: String): ContactCivilite;
begin
  try
    case CaseString(Civilite, ['M.', 'Mme', 'Mlle']) of
      0 : Result := ContactCiviliteMonsieur;
      1 : Result := ContactCiviliteMadame;
      2 : Result := ContactCiviliteMademoiselle;
    else
      Result := ContactCiviliteMonsieur;
    end;
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

function TDetailForm.CiviliteContact(AiType: ContactCivilite): String;
begin
  try
    case AiType of
      ContactCiviliteMonsieur     : Result := 'M.';
      ContactCiviliteMadame       : Result := 'Mme';
      ContactCiviliteMademoiselle : Result := 'Mlle';
    else
      Result := 'M.';
    end;
  except on E: Exception do
    MessageErreur(E.Message);
  end;
end;

{$endregion}

end.

