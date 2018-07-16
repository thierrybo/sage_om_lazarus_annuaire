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
    btnBqValider: TButton;
    btnCtcVald: TButton;
    cbCtcService: TComboBox;
    chkBqPrincipale: TCheckBox;
    cbBqDevise: TComboBox;
    cbCivilite: TComboBox;
    edtCtcNom: TEdit;
    gb1: TGroupBox;
    gb2: TGroupBox;
    gbCtc: TGroupBox;
    ledtCtcCopie: TLabeledEdit;
    lbl30: TLabel;
    lbl19: TLabel;
    lbl20: TLabel;
    lbl21: TLabel;
    lbl22: TLabel;
    lbl23: TLabel;
    lbl24: TLabel;
    lbl32: TLabel;
    ledtBqNumCpte: TLabeledEdit;
    ledtBqGuichet: TLabeledEdit;
    ledtBqCode: TLabeledEdit;
    ledtBqIntitule: TLabeledEdit;
    lbl13: TLabel;
    lbl34: TLabel;
    lbl33: TLabel;
    ledtBqCle: TLabeledEdit;
    ledtBqCommentaire: TLabeledEdit;
    ledtCtcPortable: TLabeledEdit;
    ledtCtcFonction: TLabeledEdit;
    ledtCtcTel: TLabeledEdit;
    ledtCtcPrenom: TLabeledEdit;
    ledtCtcMail: TLabeledEdit;
    ledtTelephone: TLabeledEdit;
    ledtTelecopie: TLabeledEdit;
    ledtSite: TLabeledEdit;
    ledtEMail: TLabeledEdit;
    ledtVille: TLabeledEdit;
    ledtRegion: TLabeledEdit;
    ledtPays: TLabeledEdit;
    ledtCP: TLabeledEdit;
    ledtComplement: TLabeledEdit;
    ledtAdresse: TLabeledEdit;
    ledtContact: TLabeledEdit;
    ledtIntitule: TLabeledEdit;
    lblType: TLabel;
    lblTypeTiers: TLabel;
    lblTxtNum: TLabel;
    lblNum: TLabel;
    lvContact: TListView;
    lvBanque: TListView;
    pgcTiers: TPageControl;
    pmMnuBqe: TPopupMenu;
    pmMnuCtc: TPopupMenu;
    tshContact: TTabSheet;
    tshBanque: TTabSheet;
    tshCoord: TTabSheet;
  private
    { Déclarations privées }
    F_Origine       : TListeTiersForm;
    FiOpen          : Integer;
    FBaseCpta       : BSCPTAApplication100c;
    FTiersCourant   : IBOTiers3;
    FBanqueCourante : IBOTiersBanque3;
    FTiersContact   : IBIContact2;
    FContactCourant : IBIContact2;
  public
    { Déclarations publiques }
    constructor Create(AOwner: TComponent; var ATiers: IBOTiers3);
    class var FDetailForm: TDetailForm;
  end;

var
  DetailForm: TDetailForm;

implementation

//uses ;

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

{$endregion}

end.

